import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:event_master/data_layer/services/rating/rating_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Unit tests for the rating API client.
///
/// Both the HTTP client and the token provider are injected, so these run
/// offline with no Firebase app and no backend. They verify the request the
/// app sends and how each backend status is reported to the user — they say
/// nothing about the backend's own behaviour, which its own suites cover.
void main() {
  RatingApi apiReturning(
    int status, {
    String body = '{}',
    void Function(http.Request request)? onRequest,
    List<int>? statusSequence,
  }) {
    var call = 0;

    return RatingApi(
      tokenProvider: ({bool forceRefresh = false}) async =>
          forceRefresh ? 'fresh-token' : 'stale-token',
      client: MockClient((request) async {
        onRequest?.call(request);
        final code = statusSequence != null
            ? statusSequence[call.clamp(0, statusSequence.length - 1)]
            : status;
        call += 1;
        return http.Response(body, code);
      }),
    );
  }

  group('request shape', () {
    test('sends only {value} — never a uid', () async {
      late http.Request captured;

      final api = apiReturning(200, onRequest: (r) => captured = r);
      await api.submitRating(entrepreneurId: 'ent-1', value: 4.5);

      final body = jsonDecode(captured.body) as Map<String, dynamic>;

      expect(body.keys, equals(['value']));
      expect(body['value'], 4.5);
      expect(captured.body.contains('uid'), isFalse);
      expect(captured.body.contains('raterUid'), isFalse);
    });

    test('PUTs to /api/ratings/:entrepreneurId with a bearer token', () async {
      late http.Request captured;

      final api = apiReturning(200, onRequest: (r) => captured = r);
      await api.submitRating(entrepreneurId: 'ent-1', value: 3);

      expect(captured.method, 'PUT');
      expect(captured.url.path, endsWith('/api/ratings/ent-1'));
      expect(captured.headers['Authorization'], 'Bearer stale-token');
      expect(captured.headers['Content-Type'], contains('application/json'));
    });

    test('percent-encodes the entrepreneur id', () async {
      late http.Request captured;

      final api = apiReturning(200, onRequest: (r) => captured = r);
      await api.submitRating(entrepreneurId: 'a b/c', value: 3);

      expect(captured.url.toString(), isNot(contains('a b/c')));
      expect(captured.url.toString(), contains('a%20b%2Fc'));
    });
  });

  group('removal request shape', () {
    test('DELETEs to /api/ratings/:entrepreneurId with a bearer token',
        () async {
      late http.Request captured;

      final api = apiReturning(200, onRequest: (r) => captured = r);
      await api.removeRating(entrepreneurId: 'ent-1');

      expect(captured.method, 'DELETE');
      expect(captured.url.path, endsWith('/api/ratings/ent-1'));
      expect(captured.headers['Authorization'], 'Bearer stale-token');
    });

    test('sends no body and never a uid', () async {
      late http.Request captured;

      final api = apiReturning(200, onRequest: (r) => captured = r);
      await api.removeRating(entrepreneurId: 'ent-1');

      expect(captured.body, isEmpty);
      expect(captured.headers.containsKey('Content-Type'), isFalse);
    });

    test('percent-encodes the entrepreneur id', () async {
      late http.Request captured;

      final api = apiReturning(200, onRequest: (r) => captured = r);
      await api.removeRating(entrepreneurId: 'a b/c');

      expect(captured.url.toString(), isNot(contains('a b/c')));
      expect(captured.url.toString(), contains('a%20b%2Fc'));
    });
  });

  group('removal status mapping', () {
    test('a deleted rating succeeds and carries the aggregate', () async {
      final api = apiReturning(
        200,
        body: jsonEncode({
          'outcome': 'deleted',
          'aggregate': {'rating': 4.0, 'ratingCount': 2, 'ratingSum': 8},
        }),
      );

      final result = await api.removeRating(entrepreneurId: 'ent-1');

      expect(result.isSuccess, isTrue);
      expect(result.outcome, 'deleted');
      expect(result.aggregateRating, 4.0);
      expect(result.ratingCount, 2);
    });

    test('removing a rating that is absent is still a success', () async {
      // The backend answers 200 "absent" so a retried removal is safe.
      final api = apiReturning(
        200,
        body: jsonEncode({
          'outcome': 'absent',
          'aggregate': {'rating': 0, 'ratingCount': 0, 'ratingSum': 0},
        }),
      );

      final result = await api.removeRating(entrepreneurId: 'ent-1');

      expect(result.isSuccess, isTrue);
      expect(result.outcome, 'absent');
    });

    test('a 401 triggers one forced refresh and retries', () async {
      final tokens = <String>[];

      final api = RatingApi(
        tokenProvider: ({bool forceRefresh = false}) async =>
            forceRefresh ? 'fresh-token' : 'stale-token',
        client: MockClient((request) async {
          tokens.add(request.headers['Authorization']!);
          return http.Response('{}', tokens.length == 1 ? 401 : 200);
        }),
      );

      final result = await api.removeRating(entrepreneurId: 'ent-1');

      expect(tokens, ['Bearer stale-token', 'Bearer fresh-token']);
      expect(result.isSuccess, isTrue);
    });

    test('no signed-in user short-circuits before any request', () async {
      var called = false;

      final api = RatingApi(
        tokenProvider: ({bool forceRefresh = false}) async => null,
        client: MockClient((_) async {
          called = true;
          return http.Response('{}', 200);
        }),
      );

      final result = await api.removeRating(entrepreneurId: 'ent-1');

      expect(called, isFalse);
      expect(result.status, RatingStatus.unauthenticated);
    });

    test('failure messages describe removal, not submission', () async {
      final api = apiReturning(500);
      final result = await api.removeRating(entrepreneurId: 'ent-1');

      expect(result.isSuccess, isFalse);
      expect(result.message, contains('remove'));
      expect(result.message, isNot(contains('submit')));
    });

    test('a transport error becomes a result, not an exception', () async {
      final api = RatingApi(
        tokenProvider: ({bool forceRefresh = false}) async => 'token',
        client: MockClient((_) async => throw const SocketException('down')),
      );

      final result = await api.removeRating(entrepreneurId: 'ent-1');

      expect(result.isSuccess, isFalse);
      expect(result.message, isNot(contains('SocketException')));
    });
  });

  group('status mapping', () {
    test('200 is a success and carries the aggregate', () async {
      final api = apiReturning(
        200,
        body: jsonEncode({
          'outcome': 'created',
          'rating': {'value': 4.5},
          'aggregate': {'rating': 4.25, 'ratingCount': 4, 'ratingSum': 17},
        }),
      );

      final result = await api.submitRating(entrepreneurId: 'e', value: 4.5);

      expect(result.isSuccess, isTrue);
      expect(result.status, RatingStatus.success);
      expect(result.outcome, 'created');
      expect(result.aggregateRating, 4.25);
      expect(result.ratingCount, 4);
    });

    test('200 with an unparseable body still succeeds', () async {
      final api = apiReturning(200, body: 'not json');
      final result = await api.submitRating(entrepreneurId: 'e', value: 4);

      expect(result.isSuccess, isTrue);
      expect(result.aggregateRating, isNull);
    });

    for (final entry in {
      400: RatingStatus.invalid,
      403: RatingStatus.forbidden,
      404: RatingStatus.notFound,
      429: RatingStatus.rateLimited,
      503: RatingStatus.unavailable,
      500: RatingStatus.failed,
    }.entries) {
      test('HTTP ${entry.key} maps to ${entry.value.name}', () async {
        final api = apiReturning(entry.key);
        final result = await api.submitRating(entrepreneurId: 'e', value: 4);

        expect(result.status, entry.value);
        expect(result.isSuccess, isFalse);
        expect(result.message, isNotEmpty);
      });
    }
  });

  group('expired tokens', () {
    test('a 401 triggers one forced refresh and retries', () async {
      final tokens = <String?>[];

      final api = RatingApi(
        tokenProvider: ({bool forceRefresh = false}) async {
          final token = forceRefresh ? 'fresh-token' : 'stale-token';
          tokens.add(token);
          return token;
        },
        client: MockClient((request) async {
          // First call presents the stale token and is rejected; the retry
          // presents the refreshed one and succeeds.
          return request.headers['Authorization'] == 'Bearer stale-token'
              ? http.Response('{"message":"Unauthorized"}', 401)
              : http.Response('{"outcome":"created"}', 200);
        }),
      );

      final result = await api.submitRating(entrepreneurId: 'e', value: 4);

      expect(tokens, ['stale-token', 'fresh-token']);
      expect(result.isSuccess, isTrue);
    });

    test('a second 401 is reported, not retried forever', () async {
      var calls = 0;

      final api = RatingApi(
        tokenProvider: ({bool forceRefresh = false}) async => 'token',
        client: MockClient((request) async {
          calls += 1;
          return http.Response('{"message":"Unauthorized"}', 401);
        }),
      );

      final result = await api.submitRating(entrepreneurId: 'e', value: 4);

      expect(calls, 2);
      expect(result.status, RatingStatus.unauthenticated);
    });

    test('no signed-in user short-circuits before any request', () async {
      var called = false;

      final api = RatingApi(
        tokenProvider: ({bool forceRefresh = false}) async => null,
        client: MockClient((_) async {
          called = true;
          return http.Response('{}', 200);
        }),
      );

      final result = await api.submitRating(entrepreneurId: 'e', value: 4);

      expect(called, isFalse);
      expect(result.status, RatingStatus.unauthenticated);
    });
  });

  group('failures never throw', () {
    test('a transport error becomes a result, not an exception', () async {
      final api = RatingApi(
        tokenProvider: ({bool forceRefresh = false}) async => 'token',
        client: MockClient((_) async => throw const FormatException('boom')),
      );

      final result = await api.submitRating(entrepreneurId: 'e', value: 4);

      expect(result.isSuccess, isFalse);
      expect(result.message, isNotEmpty);
    });

    test('user-facing messages never leak server internals', () async {
      final api = apiReturning(
        500,
        body:
            jsonEncode({'message': 'Firestore transaction failed at /srv/app'}),
      );

      final result = await api.submitRating(entrepreneurId: 'e', value: 4);

      expect(result.message, isNot(contains('Firestore')));
      expect(result.message, isNot(contains('/srv/')));
    });
  });

  group('base url', () {
    test('defaults to a local development server when unconfigured', () {
      // No --dart-define in the test harness, so this exercises the fallback.
      expect(RatingApi.baseUrl,
          anyOf(contains('10.0.2.2'), contains('localhost')));
    });
  });
}
