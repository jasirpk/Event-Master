import 'dart:convert';
import 'dart:io';

import 'package:event_master/data_layer/services/gallery_api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// The gallery upload contract, at the HTTP boundary.
///
/// The Media API is mocked here: these assert what the app *sends* and how
/// it reacts to what comes back. They do not prove R2 accepts the bytes —
/// only the emulator/real-R2 suites in the API repo can.

File tempImage(String name, {int bytes = 32}) {
  final file = File('${Directory.systemTemp.path}/$name')
    ..writeAsBytesSync(List<int>.filled(bytes, 7));
  addTearDown(() {
    if (file.existsSync()) file.deleteSync();
  });
  return file;
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://api.example');
  });

  group('requesting an upload URL', () {
    test('sends only the file details, never an identity', () async {
      Map<String, dynamic>? sentBody;

      final service = GalleryApiService(
        tokenProvider: () async => 'test-token',
        client: MockClient((request) async {
          if (request.url.path == '/api/gallery/upload-url') {
            sentBody = jsonDecode(request.body) as Map<String, dynamic>;
            expect(request.headers['Authorization'], 'Bearer test-token');

            return http.Response(
              jsonEncode({
                'uploadUrl': 'https://r2.example/signed',
                'objectKey': 'user_media/me/1700000000000-a.jpg',
                'expiresIn': 300,
              }),
              200,
            );
          }

          return http.Response('', 200);
        }),
      );

      final key = await service.uploadGalleryImage(tempImage('a.jpg'));

      expect(
          sentBody!.keys.toSet(), {'fileName', 'contentType', 'contentLength'});
      expect(sentBody!['contentType'], 'image/jpeg');
      expect(sentBody!.containsKey('uid'), isFalse,
          reason: 'the server derives the owner from the token');
      expect(key, 'user_media/me/1700000000000-a.jpg');
    });

    test('PUTs the bytes with exactly the signed headers', () async {
      String? putContentType;
      String? putContentLength;
      int? putBodyLength;

      final service = GalleryApiService(
        tokenProvider: () async => 'test-token',
        client: MockClient((request) async {
          if (request.url.path == '/api/gallery/upload-url') {
            return http.Response(
              jsonEncode({
                'uploadUrl': 'https://r2.example/signed',
                'objectKey': 'user_media/me/1-a.jpg',
                'expiresIn': 300,
              }),
              200,
            );
          }

          putContentType = request.headers['Content-Type'];
          putContentLength = request.headers['Content-Length'];
          putBodyLength = request.bodyBytes.length;

          return http.Response('', 200);
        }),
      );

      await service.uploadGalleryImage(tempImage('b.jpg', bytes: 64));

      expect(putContentType, 'image/jpeg');
      expect(putContentLength, '64',
          reason: 'both headers are bound into the signature');
      expect(putBodyLength, 64);
    });
  });

  group('failures are not reported as success', () {
    Future<void> expectFailure(http.Response signResponse) async {
      final service = GalleryApiService(
        tokenProvider: () async => 'test-token',
        client: MockClient((_) async => signResponse),
      );

      await expectLater(
        service.uploadGalleryImage(tempImage('c.jpg')),
        throwsA(isA<GalleryApiException>()),
      );
    }

    test('an expired session', () => expectFailure(http.Response('{}', 401)));
    test('a rejected request', () => expectFailure(http.Response('{}', 400)));
    test('a server fault', () => expectFailure(http.Response('{}', 500)));

    test('an incomplete signing response', () async {
      await expectFailure(http.Response(jsonEncode({'uploadUrl': 'x'}), 200));
    });

    test('a failed PUT to R2', () async {
      final service = GalleryApiService(
        tokenProvider: () async => 'test-token',
        client: MockClient((request) async {
          if (request.url.path == '/api/gallery/upload-url') {
            return http.Response(
              jsonEncode({
                'uploadUrl': 'https://r2.example/signed',
                'objectKey': 'user_media/me/1-a.jpg',
                'expiresIn': 300,
              }),
              200,
            );
          }

          // An expired signature looks like this.
          return http.Response('AccessDenied', 403);
        }),
      );

      await expectLater(
        service.uploadGalleryImage(tempImage('d.jpg')),
        throwsA(isA<GalleryApiException>()),
      );
    });

    test('no signed-in user', () async {
      final service = GalleryApiService(
        tokenProvider: () async => null,
        client: MockClient((_) async => http.Response('{}', 200)),
      );

      await expectLater(
        service.uploadGalleryImage(tempImage('e.jpg')),
        throwsA(isA<GalleryApiException>()),
      );
    });
  });

  group('what the client refuses before any network call', () {
    test('an unsupported image type', () async {
      final service = GalleryApiService(
        tokenProvider: () async => 'test-token',
        client: MockClient((_) async {
          fail('must not reach the network');
        }),
      );

      await expectLater(
        service.uploadGalleryImage(tempImage('f.pdf')),
        throwsA(isA<GalleryApiException>()),
      );
    });

    test('an empty file', () async {
      final service = GalleryApiService(
        tokenProvider: () async => 'test-token',
        client: MockClient((_) async {
          fail('must not reach the network');
        }),
      );

      await expectLater(
        service.uploadGalleryImage(tempImage('g.jpg', bytes: 0)),
        throwsA(isA<GalleryApiException>()),
      );
    });
  });
}
