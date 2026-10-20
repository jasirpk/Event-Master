import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Thrown when publishing a booking to the entrepreneur index fails.
///
/// Never carries the Authorization header or an ID token — only a message
/// safe to show a user and the HTTP status.
class BookingIndexApiException implements Exception {
  final String message;
  final int? statusCode;

  BookingIndexApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      'BookingIndexApiException: $message${statusCode == null ? '' : ' ($statusCode)'}';
}

/// Publishes a saved booking to the entrepreneur's read index.
///
/// The booking itself is written to `users/{uid}/events/{eventId}` by
/// [EventBookingMethods]; this asks the server to list it. The two are
/// separate on purpose: the index is derived data, and the server owns it.
///
/// Only the event id is sent. The customer comes from the verified token and
/// the entrepreneur is read from the stored booking, so there is nothing here
/// a client could use to address a booking to the wrong company — the API
/// rejects a body carrying `entrepreneurId` or `customerUid` outright.
class BookingIndexApiService {
  static final BookingIndexApiService instance = BookingIndexApiService();

  final http.Client _client;

  /// [tokenProvider] follows the convention [RatingApi] already uses: the
  /// default reads Firebase, and a test supplies its own so these calls can
  /// run with no Firebase app.
  BookingIndexApiService({
    http.Client? client,
    Future<String?> Function()? tokenProvider,
  })  : _client = client ?? http.Client(),
        _tokenProvider = tokenProvider ?? _firebaseIdToken;

  final Future<String?> Function() _tokenProvider;

  static Future<String?> _firebaseIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.getIdToken();
  }

  static final String _configuredBaseUrl = dotenv.env['API_BASE_URL'] ?? "";

  static const Duration _timeout = Duration(seconds: 20);

  /// Matches the convention already used by this app's other API clients.
  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  /// Lists the already-saved booking [eventId] for its entrepreneur.
  ///
  /// Safe to call again with the same [eventId]: the server keys the index
  /// row on the customer and the event, so a retry refreshes that row rather
  /// than creating a second one. That is what makes the retry offered after a
  /// failure safe — it never writes another booking.
  Future<void> indexBooking(String eventId) async {
    final token = await _tokenProvider();

    if (token == null) {
      throw BookingIndexApiException(
        'Please sign in again to finish submitting this event.',
      );
    }

    final http.Response response;

    try {
      response = await _client
          .post(
            Uri.parse('$baseUrl/api/bookings/index'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            // Exactly this one key. The endpoint refuses an unexpected extra
            // one rather than ignoring it, so there is nothing to add — and
            // nothing here carries the customer's email or phone.
            body: jsonEncode({'eventId': eventId}),
          )
          .timeout(_timeout);
    } catch (error) {
      if (error is BookingIndexApiException) rethrow;

      // The underlying error is not interpolated: it can quote the full
      // request, Authorization header included.
      throw BookingIndexApiException(
        'Could not reach the server. Check your connection and try again.',
      );
    }

    if (response.statusCode != 200) {
      throw BookingIndexApiException(
        _messageForStatus(response.statusCode),
        statusCode: response.statusCode,
      );
    }
  }

  /// The server answers each failure with one generic message so the response
  /// is not an oracle; the mapping happens here instead.
  String _messageForStatus(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'This event could not be listed. Please try again.';
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 403:
        return 'This event belongs to a different account.';
      case 404:
        return 'This event could not be found.';
      case 409:
        return 'This event names no event management company.';
      case 429:
        return "You've submitted too many events recently. Please try again "
            'in a few minutes.';
      default:
        return statusCode >= 500
            ? 'The server could not list this event. Please try again later.'
            : 'This event could not be listed. Please try again.';
    }
  }
}
