import 'dart:convert';

import 'package:event_master/data_layer/services/booking_index_api_service.dart';
import 'package:event_master/data_layer/services/booking_submission.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Phase 3: listing a saved booking for its entrepreneur.
///
/// Both the HTTP client and the token provider are injected, so these run
/// offline with no Firebase app and no backend. They verify the request this
/// app sends and the ordering around it — not that the server accepts it.
/// The real HTTP path is covered by the Media API's own emulator suite.

const _token = 'test-id-token';
Future<String?> _tokens() async => _token;

BookingIndexApiService api({
  required MockClient client,
  Future<String?> Function()? tokenProvider,
}) =>
    BookingIndexApiService(
      client: client,
      tokenProvider: tokenProvider ?? _tokens,
    );

/// Records every listing attempt, without a network.
class FakeIndexApi extends BookingIndexApiService {
  FakeIndexApi({this.failures = 0})
      : super(
          client: MockClient((_) async => http.Response('{}', 200)),
          tokenProvider: _tokens,
        );

  /// How many of the first calls should fail.
  int failures;

  final List<String> calls = [];

  @override
  Future<void> indexBooking(String eventId) async {
    calls.add(eventId);
    if (failures > 0) {
      failures -= 1;
      throw BookingIndexApiException('listing unavailable', statusCode: 503);
    }
  }
}

void main() {
  setUpAll(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://api.example');
  });

  group('the request this app sends', () {
    test('posts only eventId to /api/bookings/index with the token', () async {
      http.BaseRequest? seen;
      Map<String, dynamic>? body;

      await api(
        client: MockClient((request) async {
          seen = request;
          body = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
              jsonEncode({'indexId': 'u_e1', 'entrepreneurId': 'ent1'}), 200);
        }),
      ).indexBooking('e1');

      expect(seen!.method, 'POST');
      expect(seen!.url.path, '/api/bookings/index');
      expect(seen!.headers['Authorization'], 'Bearer $_token');
      expect(body, {'eventId': 'e1'});
    });

    test('never sends ownership fields, email or phone', () async {
      Map<String, dynamic>? body;

      await api(
        client: MockClient((request) async {
          body = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response('{}', 200);
        }),
      ).indexBooking('e1');

      expect(body!.keys.toSet(), {'eventId'});
      for (final forbidden in [
        'customerUid',
        'entrepreneurId',
        'email',
        'phoneNumber',
      ]) {
        expect(body!.containsKey(forbidden), isFalse, reason: forbidden);
      }
    });

    test('a missing token fails before any request is made', () async {
      var called = false;

      await expectLater(
        api(
          client: MockClient((_) async {
            called = true;
            return http.Response('{}', 200);
          }),
          tokenProvider: () async => null,
        ).indexBooking('e1'),
        throwsA(isA<BookingIndexApiException>()),
      );
      expect(called, isFalse);
    });

    test('each failure status maps to a safe message', () async {
      for (final status in [400, 401, 403, 404, 409, 429, 500]) {
        try {
          await api(
                  client: MockClient((_) async => http.Response('{}', status)))
              .indexBooking('e1');
          fail('expected a failure for $status');
        } on BookingIndexApiException catch (error) {
          expect(error.statusCode, status);
          expect(error.message, isNotEmpty);
          expect(error.toString(), isNot(contains(_token)));
        }
      }
    });
  });

  group('save then list, in that order', () {
    test('a successful save and listing reports listed', () async {
      final index = FakeIndexApi();
      final submission = BookingSubmission(indexApi: index);

      final result =
          await submission.submit(saveBooking: () async => 'event-1');

      expect(result.isListed, isTrue);
      expect(result.eventId, 'event-1');
      expect(result.listingError, isNull);
      expect(index.calls, ['event-1']);
    });

    test('a failed save never reaches the index endpoint', () async {
      final index = FakeIndexApi();
      final submission = BookingSubmission(indexApi: index);

      await expectLater(
        submission.submit(
            saveBooking: () async => throw Exception('firestore down')),
        throwsA(isA<Exception>()),
      );

      expect(index.calls, isEmpty,
          reason: 'nothing to list when there is no booking');
    });

    test('a listing failure does not re-run the save', () async {
      var saves = 0;
      final index = FakeIndexApi(failures: 1);
      final submission = BookingSubmission(indexApi: index);

      final result = await submission.submit(saveBooking: () async {
        saves += 1;
        return 'event-2';
      });

      expect(saves, 1, reason: 'the booking is written exactly once');
      expect(result.isListed, isFalse);
      expect(result.outcome, BookingSubmissionOutcome.listingPending);
      expect(result.eventId, 'event-2');
      expect(result.listingError, 'listing unavailable');
    });

    test('a listing failure is not reported as a failed booking', () async {
      final submission = BookingSubmission(indexApi: FakeIndexApi(failures: 1));

      // It returns rather than throwing: by now there is a booking.
      final result =
          await submission.submit(saveBooking: () async => 'event-3');

      expect(result.eventId, 'event-3');
    });

    test('an unexpected listing error still yields a saved booking', () async {
      final submission = BookingSubmission(indexApi: _ThrowsRaw());

      final result =
          await submission.submit(saveBooking: () async => 'event-4');

      expect(result.outcome, BookingSubmissionOutcome.listingPending);
      expect(result.listingError, 'The listing could not be updated.');
    });
  });

  group('retry', () {
    test('reuses the same eventId and makes no booking', () async {
      var saves = 0;
      final index = FakeIndexApi(failures: 1);
      final submission = BookingSubmission(indexApi: index);

      final first = await submission.submit(saveBooking: () async {
        saves += 1;
        return 'event-5';
      });
      expect(first.isListed, isFalse);

      final retried = await submission.retryListing(first.eventId);

      expect(retried.isListed, isTrue);
      expect(saves, 1, reason: 'retry must never write a second booking');
      expect(index.calls, ['event-5', 'event-5']);
    });

    test('a retry that fails again stays pending with its message', () async {
      final submission = BookingSubmission(indexApi: FakeIndexApi(failures: 5));

      final retried = await submission.retryListing('event-6');

      expect(retried.isListed, isFalse);
      expect(retried.listingError, 'listing unavailable');
      expect(retried.eventId, 'event-6');
    });
  });
}

/// Fails with something that is not a BookingIndexApiException.
class _ThrowsRaw extends BookingIndexApiService {
  _ThrowsRaw()
      : super(
          client: MockClient((_) async => http.Response('{}', 200)),
          tokenProvider: _tokens,
        );

  @override
  Future<void> indexBooking(String eventId) async => throw StateError('boom');
}
