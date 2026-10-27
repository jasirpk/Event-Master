import 'dart:async';
import 'dart:convert';

import 'package:event_master/data_layer/services/media_image_resolver.dart';
import 'package:event_master/data_layer/services/media_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// How the resolver treats signed URLs: cached while in date, shared while in
/// flight, re-signed once stale.
///
/// Expiry is driven by the URL itself rather than a clock: the resolver reads
/// `X-Amz-Expires` and retires the URL a safety margin early, so a short
/// declared lifetime is already expired by the time it is handed back. That
/// keeps these deterministic with no fake clock and no waiting.

const String kKey = 'user_media/me/1700000000000-a.jpg';

/// A resolver whose Media API is a mock, plus the number of calls it made.
({MediaImageResolver resolver, int Function() calls, void Function() release})
    buildResolver({
  int expiresIn = 3600,
  String url = 'https://r2.example/signed',
  Completer<void>? gate,
}) {
  var calls = 0;

  final service = MediaService(
    tokenProvider: () async => 'test-token',
    client: MockClient((request) async {
      calls++;
      if (gate != null) await gate.future;

      return http.Response(
        jsonEncode({
          'downloadUrl': '$url?X-Amz-Expires=$expiresIn&n=$calls',
          'objectKey': kKey,
          'expiresIn': expiresIn,
        }),
        200,
      );
    }),
  );

  return (
    resolver: MediaImageResolver.forTesting(service),
    calls: () => calls,
    release: () => gate?.complete(),
  );
}

String? urlOf(ImageProvider? provider) =>
    provider is NetworkImage ? provider.url : null;

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://api.example');
  });

  group('a signed URL is cached and reused while it is in date', () {
    test('a second resolve of the same key makes no further API call',
        () async {
      final h = buildResolver(expiresIn: 3600);

      final first = await h.resolver.resolve(kKey);
      final second = await h.resolver.resolve(kKey);

      expect(h.calls(), 1, reason: 'the cached URL should have been reused');
      expect(urlOf(first), urlOf(second));
    });

    test('resolveSync returns the cached URL with no await at all', () async {
      final h = buildResolver(expiresIn: 3600);

      await h.resolver.resolve(kKey);

      expect(urlOf(h.resolver.resolveSync(kKey)), isNotNull);
      expect(h.calls(), 1);
    });

    test('a different key is signed separately', () async {
      final h = buildResolver(expiresIn: 3600);

      await h.resolver.resolve(kKey);
      await h.resolver.resolve('user_media/me/1700000000001-b.jpg');

      expect(h.calls(), 2);
    });
  });

  group('concurrent resolves of one key share a single request', () {
    test('ten simultaneous callers cause one API call', () async {
      final gate = Completer<void>();
      final h = buildResolver(gate: gate);

      final pending = List.generate(10, (_) => h.resolver.resolve(kKey));

      // Every caller arrives while the first request is still in flight.
      h.release();
      final providers = await Future.wait(pending);

      expect(h.calls(), 1, reason: 'the in-flight request should be shared');
      expect(providers.map(urlOf).toSet().length, 1,
          reason: 'all callers get the same signed URL');
    });

    test('a failure is not cached, so the next caller may retry', () async {
      var calls = 0;

      final service = MediaService(
        tokenProvider: () async => 'test-token',
        client: MockClient((_) async {
          calls++;
          return calls == 1
              ? http.Response('{}', 500)
              : http.Response(
                  jsonEncode({
                    'downloadUrl': 'https://r2.example/ok?X-Amz-Expires=3600',
                    'objectKey': kKey,
                    'expiresIn': 3600,
                  }),
                  200,
                );
        }),
      );

      final resolver = MediaImageResolver.forTesting(service);

      expect(await resolver.resolve(kKey), isNull);
      expect(urlOf(await resolver.resolve(kKey)), isNotNull);
      expect(calls, 2);
    });
  });

  group('an expired URL is signed again rather than reused', () {
    test('a lifetime shorter than the safety margin is never reused', () async {
      // 30s declared, 60s margin -> already stale when handed back.
      final h = buildResolver(expiresIn: 30);

      final first = await h.resolver.resolve(kKey);
      final second = await h.resolver.resolve(kKey);

      expect(h.calls(), 2, reason: 'the stale URL must not be reused');
      expect(urlOf(first), isNot(urlOf(second)),
          reason: 'a fresh signature each time');
    });

    test('resolveSync refuses to hand out a stale URL', () async {
      final h = buildResolver(expiresIn: 30);

      await h.resolver.resolve(kKey);

      expect(h.resolver.resolveSync(kKey), isNull,
          reason: 'stale cache entries must not be served synchronously');
    });

    test('a long lifetime is reused, a short one is not', () async {
      final long = buildResolver(expiresIn: 3600);
      await long.resolver.resolve(kKey);
      await long.resolver.resolve(kKey);

      final short = buildResolver(expiresIn: 10);
      await short.resolver.resolve(kKey);
      await short.resolver.resolve(kKey);

      expect(long.calls(), 1);
      expect(short.calls(), 2);
    });
  });

  group('at most four signing calls are in flight at once', () {
    /// A service that takes a real moment to answer, recording how many
    /// calls overlapped. A genuine async gap is what makes the gate's effect
    /// observable; holding requests open manually made the test, not the
    /// gate, the thing under test.
    ({MediaService service, int Function() peak, int Function() started})
        slowService({int failFirst = 0, bool throwInstead = false}) {
      var inFlight = 0;
      var peak = 0;
      var started = 0;

      final service = MediaService(
        tokenProvider: () async => 'test-token',
        client: MockClient((request) async {
          started++;
          inFlight++;
          if (inFlight > peak) peak = inFlight;

          await Future<void>.delayed(const Duration(milliseconds: 5));

          inFlight--;

          if (started <= failFirst) {
            if (throwInstead) throw http.ClientException('socket died');
            return http.Response('{}', 500);
          }

          final key = request.url.queryParameters['objectKey'];
          return http.Response(
            jsonEncode({
              'downloadUrl': 'https://r2.example/$key?X-Amz-Expires=3600',
              'objectKey': key,
              'expiresIn': 3600,
            }),
            200,
          );
        }),
      );

      return (service: service, peak: () => peak, started: () => started);
    }

    test('ten distinct keys never exceed four concurrent calls', () async {
      final h = slowService();
      final resolver = MediaImageResolver.forTesting(h.service);

      await Future.wait([
        for (var i = 0; i < 10; i++) resolver.resolve('user_media/me/$i-a.jpg'),
      ]);

      expect(h.peak(), lessThanOrEqualTo(4),
          reason: 'the gate must never allow a fifth call');
      expect(h.peak(), greaterThan(1),
          reason: 'it should still run several at once, not serialise');
      expect(h.started(), 10, reason: 'every key must eventually be signed');
    });

    test('a long queue drains completely', () async {
      final h = slowService();
      final resolver = MediaImageResolver.forTesting(h.service);

      final providers = await Future.wait([
        for (var i = 0; i < 20; i++) resolver.resolve('user_media/me/$i-b.jpg'),
      ]);

      expect(h.started(), 20, reason: 'the queue must drain, not stall');
      expect(h.peak(), lessThanOrEqualTo(4));
      expect(providers.every((p) => p != null), isTrue);
    });

    test('duplicates of one key share a single call even when queued',
        () async {
      final h = slowService();
      final resolver = MediaImageResolver.forTesting(h.service);

      // Fill the gate, then pile six callers onto one further key.
      final all = <Future<ImageProvider?>>[
        for (var i = 0; i < 4; i++)
          resolver.resolve('user_media/me/$i-fill.jpg'),
        for (var i = 0; i < 6; i++)
          resolver.resolve('user_media/me/9-same.jpg'),
      ];

      final results = await Future.wait(all);

      expect(h.started(), 5,
          reason: 'four fillers plus one shared call, not ten');
      expect(results.skip(4).map(urlOf).toSet().length, 1,
          reason: 'every caller gets the same signed URL');
    });

    test('a failed call releases its slot', () async {
      final h = slowService(failFirst: 4);
      final resolver = MediaImageResolver.forTesting(h.service);

      final results = await Future.wait([
        for (var i = 0; i < 8; i++) resolver.resolve('user_media/me/$i-c.jpg'),
      ]);

      expect(h.started(), 8, reason: 'a failure must not strand its slot');
      expect(h.peak(), lessThanOrEqualTo(4));
      expect(results.where((p) => p == null).length, 4);
      expect(results.where((p) => p != null).length, 4);
    });

    test('a thrown (non-HTTP) failure also releases its slot', () async {
      final h = slowService(failFirst: 4, throwInstead: true);
      final resolver = MediaImageResolver.forTesting(h.service);

      await Future.wait([
        for (var i = 0; i < 8; i++) resolver.resolve('user_media/me/$i-d.jpg'),
      ]);

      expect(h.started(), 8, reason: 'an exception must not block the queue');
      expect(h.peak(), lessThanOrEqualTo(4));
    });
  });

  group('paths that need no signing never reach the API', () {
    test('a legacy https URL resolves synchronously', () async {
      final h = buildResolver();

      expect(urlOf(h.resolver.resolveSync('https://legacy/x.jpg')),
          'https://legacy/x.jpg');
      expect(h.calls(), 0);
    });

    test('a bundled asset resolves synchronously', () async {
      final h = buildResolver();

      expect(h.resolver.resolveSync('assets/images/a.jpg'), isA<AssetImage>());
      expect(h.calls(), 0);
    });

    test('null and empty resolve to nothing', () async {
      final h = buildResolver();

      expect(h.resolver.resolveSync(null), isNull);
      expect(h.resolver.resolveSync('  '), isNull);
      expect(h.calls(), 0);
    });
  });
}
