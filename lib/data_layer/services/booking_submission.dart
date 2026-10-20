import 'package:event_master/data_layer/services/booking_index_api_service.dart';

/// How far a submission got.
enum BookingSubmissionOutcome {
  /// Saved and listed. The entrepreneur can see it.
  listed,

  /// Saved, but not listed yet. The booking exists and must not be re-made.
  listingPending,
}

class BookingSubmissionResult {
  const BookingSubmissionResult({
    required this.eventId,
    required this.outcome,
    this.listingError,
  });

  /// The saved booking's id. Present whichever outcome occurred, because the
  /// booking exists in both — it is what a retry re-sends.
  final String eventId;

  final BookingSubmissionOutcome outcome;

  /// Safe to show the user. Null when the listing succeeded.
  final String? listingError;

  bool get isListed => outcome == BookingSubmissionOutcome.listed;
}

/// Saving a booking and then listing it, in that order.
///
/// Two steps with different consequences, which is the whole reason this
/// exists as one place:
///
///  * The save is the system of record. If it throws, nothing is listed and
///    the error belongs to the caller — there is no booking.
///  * The listing is derived. If it fails, the booking is still saved, so the
///    failure must never be reported as a failed booking and the save must
///    never be retried.
///
/// The save is passed in as a callback rather than fifteen parameters: this
/// class is about the ordering and what happens between the steps, not about
/// the booking's fields.
class BookingSubmission {
  BookingSubmission({BookingIndexApiService? indexApi})
      : _indexApi = indexApi ?? BookingIndexApiService.instance;

  final BookingIndexApiService _indexApi;

  /// Runs [saveBooking], then asks the server to list the result.
  ///
  /// Throws only what [saveBooking] throws. A listing failure is returned,
  /// not thrown, because by then there is a booking to report.
  Future<BookingSubmissionResult> submit({
    required Future<String> Function() saveBooking,
  }) async {
    // Any failure here propagates: no booking, so nothing to list and
    // nothing to tell the entrepreneur about.
    final eventId = await saveBooking();

    try {
      await _indexApi.indexBooking(eventId);

      return BookingSubmissionResult(
        eventId: eventId,
        outcome: BookingSubmissionOutcome.listed,
      );
    } on BookingIndexApiException catch (error) {
      return BookingSubmissionResult(
        eventId: eventId,
        outcome: BookingSubmissionOutcome.listingPending,
        listingError: error.message,
      );
    } catch (_) {
      return BookingSubmissionResult(
        eventId: eventId,
        outcome: BookingSubmissionOutcome.listingPending,
        listingError: 'The listing could not be updated.',
      );
    }
  }

  /// Retries the listing for a booking that is already saved.
  ///
  /// Takes an existing [eventId] and nothing else, so it cannot create a
  /// second booking. The server keys its index row on the customer and the
  /// event, so a repeat refreshes that row rather than adding another.
  Future<BookingSubmissionResult> retryListing(String eventId) async {
    try {
      await _indexApi.indexBooking(eventId);

      return BookingSubmissionResult(
        eventId: eventId,
        outcome: BookingSubmissionOutcome.listed,
      );
    } on BookingIndexApiException catch (error) {
      return BookingSubmissionResult(
        eventId: eventId,
        outcome: BookingSubmissionOutcome.listingPending,
        listingError: error.message,
      );
    }
  }
}
