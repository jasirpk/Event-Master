import 'dart:convert';
import 'dart:io';

import 'package:event_master/data_layer/services/event_image_api_service.dart';
import 'package:event_master/data_layer/services/media_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Unit tests for the event-image upload client and the download routing.
///
/// Both the HTTP client and the token provider are injected, so these run
/// offline with no Firebase app and no backend. They verify the request this
/// app sends and what it does with the reply — not that R2 accepts it.

const _token = 'test-id-token';
Future<String?> _tokens() async => _token;

late Directory _tmp;

File _imageFile({String name = 'party.jpg', int bytes = 2048}) {
  final file = File('${_tmp.path}/$name');
  file.writeAsBytesSync(List<int>.filled(bytes, 7));
  return file;
}

/// A successful presign reply, in the shape the API documents.
String _signed({String key = 'event_images/uid1/1758800000000-party.jpg'}) =>
    jsonEncode({
      'uploadUrl': 'https://r2.example/presigned-put',
      'objectKey': key,
      'contentType': 'image/jpeg',
      'contentLength': 2048,
      'expiresIn': 300,
    });

void main() {
  setUpAll(() {
    // Both services read API_BASE_URL through dotenv, which throws when the
    // app has not loaded a .env. testLoad supplies one in memory; no real
    // environment file is read.
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://api.example');
  });

  setUp(() {
    _tmp = Directory.systemTemp.createTempSync('event_image_test');
  });

  tearDown(() {
    if (_tmp.existsSync()) _tmp.deleteSync(recursive: true);
  });

  group('upload request', () {
    test('posts the agreed body to /api/events/upload-url and PUTs the bytes',
        () async {
      final requests = <http.BaseRequest>[];
      Object? presignBody;

      final api = EventImageApiService(
        tokenProvider: _tokens,
        client: MockClient((request) async {
          requests.add(request);

          if (request.url.path == '/api/events/upload-url') {
            presignBody = jsonDecode(request.body);
            return http.Response(_signed(), 200,
                headers: {'content-type': 'application/json'});
          }
          return http.Response('', 200);
        }),
      );

      final key = await api.uploadEventImage(_imageFile());

      expect(key, 'event_images/uid1/1758800000000-party.jpg');

      // 1 — the presign call.
      expect(requests[0].method, 'POST');
      expect(requests[0].url.path, '/api/events/upload-url');
      expect(requests[0].headers['Authorization'], 'Bearer $_token');
      expect(presignBody, {
        'fileName': 'party.jpg',
        'contentType': 'image/jpeg',
        'contentLength': 2048,
      });

      // 2 — the bytes, straight to storage, never through the API.
      expect(requests[1].method, 'PUT');
      expect(requests[1].url.host, 'r2.example');
      expect(requests[1].headers['Content-Type'], 'image/jpeg');
      expect(requests[1].headers['Content-Length'], '2048');
      // The presigned PUT must not carry the Firebase token.
      expect(requests[1].headers.containsKey('Authorization'), isFalse);
    });

    test('sends exactly the three keys the endpoint accepts', () async {
      Map<String, dynamic>? body;

      final api = EventImageApiService(
        tokenProvider: _tokens,
        client: MockClient((request) async {
          if (request.url.path == '/api/events/upload-url') {
            body = jsonDecode(request.body) as Map<String, dynamic>;
            return http.Response(_signed(), 200);
          }
          return http.Response('', 200);
        }),
      );

      await api.uploadEventImage(_imageFile());

      // The API refuses an unexpected extra key rather than ignoring it.
      expect(body!.keys.toSet(), {'fileName', 'contentType', 'contentLength'});
    });

    test('derives the content type from the extension', () async {
      for (final entry in {
        'a.png': 'image/png',
        'a.webp': 'image/webp',
        'a.JPEG': 'image/jpeg',
      }.entries) {
        String? sent;

        final api = EventImageApiService(
          tokenProvider: _tokens,
          client: MockClient((request) async {
            if (request.url.path == '/api/events/upload-url') {
              sent = (jsonDecode(request.body) as Map)['contentType'] as String;
              return http.Response(_signed(), 200);
            }
            return http.Response('', 200);
          }),
        );

        await api.uploadEventImage(_imageFile(name: entry.key));
        expect(sent, entry.value, reason: entry.key);
      }
    });
  });

  group('upload failures are surfaced, never swallowed', () {
    Future<void> expectsFailure(
      http.Client client, {
      String? name,
      int bytes = 2048,
    }) async {
      final api = EventImageApiService(tokenProvider: _tokens, client: client);

      await expectLater(
        api.uploadEventImage(
            _imageFile(name: name ?? 'party.jpg', bytes: bytes)),
        throwsA(isA<EventImageApiException>()),
      );
    }

    test('a rejected presign request throws', () async {
      await expectsFailure(MockClient((_) async =>
          http.Response('{"message":"Invalid upload request"}', 400)));
    });

    test('an expired session throws', () async {
      await expectsFailure(MockClient(
          (_) async => http.Response('{"message":"Unauthorized"}', 401)));
    });

    test('a rate limit throws', () async {
      await expectsFailure(MockClient(
          (_) async => http.Response('{"message":"Too many"}', 429)));
    });

    test('an incomplete presign reply throws', () async {
      await expectsFailure(MockClient((request) async => http.Response(
          jsonEncode({'objectKey': 'event_images/u/1-a.jpg'}), 200)));
    });

    test('a storage PUT that fails throws', () async {
      await expectsFailure(MockClient((request) async {
        if (request.url.path == '/api/events/upload-url') {
          return http.Response(_signed(), 200);
        }
        return http.Response('AccessDenied', 403);
      }));
    });

    test('a network drop throws, without leaking the presigned URL', () async {
      final api = EventImageApiService(
        tokenProvider: _tokens,
        client: MockClient((request) async {
          if (request.url.path == '/api/events/upload-url') {
            return http.Response(_signed(), 200);
          }
          throw const SocketException('connection reset');
        }),
      );

      try {
        await api.uploadEventImage(_imageFile());
        fail('expected a failure');
      } on EventImageApiException catch (error) {
        expect(error.message, isNot(contains('presigned')));
        expect(error.message, isNot(contains('r2.example')));
        expect(error.toString(), isNot(contains(_token)));
      }
    });

    test('a missing token throws before any request is made', () async {
      var called = false;

      final api = EventImageApiService(
        tokenProvider: () async => null,
        client: MockClient((_) async {
          called = true;
          return http.Response('', 200);
        }),
      );

      await expectLater(api.uploadEventImage(_imageFile()),
          throwsA(isA<EventImageApiException>()));
      expect(called, isFalse);
    });

    test('an unsupported type is refused locally', () async {
      await expectsFailure(
        MockClient((_) async => http.Response(_signed(), 200)),
        name: 'notes.pdf',
      );
    });

    test('an empty file is refused locally', () async {
      await expectsFailure(
        MockClient((_) async => http.Response(_signed(), 200)),
        bytes: 0,
      );
    });
  });

  group('download routing', () {
    Future<String> pathFor(String objectKey) async {
      late String path;

      final service = MediaService(
        tokenProvider: _tokens,
        client: MockClient((request) async {
          path = request.url.path;
          return http.Response(
              jsonEncode({'downloadUrl': 'https://r2.example/get'}), 200);
        }),
      );

      await service.getDownloadUrl(objectKey);
      return path;
    }

    test('an event key goes to the owner-scoped endpoint', () async {
      expect(await pathFor('event_images/uid1/1758800000000-a.jpg'),
          '/api/events/download-url');
    });

    test('catalogue, profile and vendor keys keep using the public endpoint',
        () async {
      for (final key in [
        'category_images/cat1/1758800000000-a.jpg',
        'subcategory_images/sub1/1758800000000-a.jpg',
        'profile_images/uid1/1758800000000-a.jpg',
        'client_profile_images/uid1/1758800000000-a.jpg',
        'vendor_images/uid1/vendor1/1758800000000-a.jpg',
      ]) {
        expect(await pathFor(key), '/api/media/public-download-url',
            reason: key);
      }
    });

    test('the request carries the Firebase token', () async {
      String? auth;

      final service = MediaService(
        tokenProvider: _tokens,
        client: MockClient((request) async {
          auth = request.headers['Authorization'];
          return http.Response(
              jsonEncode({'downloadUrl': 'https://r2.example/get'}), 200);
        }),
      );

      await service.getDownloadUrl('event_images/uid1/1758800000000-a.jpg');
      expect(auth, 'Bearer $_token');
    });

    test('a 404 for somebody else\'s key surfaces as a failure', () async {
      final service = MediaService(
        tokenProvider: _tokens,
        client: MockClient((_) async =>
            http.Response('{"message":"Media object not found"}', 404)),
      );

      await expectLater(
        service.getDownloadUrl('event_images/other/1758800000000-a.jpg'),
        throwsA(isA<MediaApiException>()),
      );
    });
  });
}
