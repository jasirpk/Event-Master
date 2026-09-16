import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform, SocketException;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// Client for the Event Master Media API rating endpoints.
///
/// The backend is the only trusted writer of rating documents and of the
/// `rating` / `ratingCount` / `ratingSum` aggregate on an entrepreneur. The app
/// never writes those itself: it sends the Firebase ID token and the backend
/// derives the rater's uid from the verified token, so a client cannot rate on
/// someone else's behalf.
///
/// Base URL is supplied at build time:
///
///   flutter run --dart-define=API_BASE_URL=https://api.example.com
///
/// With no override it falls back to a local development server. The Android
/// emulator reaches the host machine on 10.0.2.2 rather than localhost.
class RatingApi {
  RatingApi(
      {http.Client? client,
      Future<String?> Function({bool forceRefresh})? tokenProvider})
      : _client = client ?? http.Client(),
        _tokenProvider = tokenProvider ?? _firebaseIdToken;

  final http.Client _client;

  /// Supplies the Firebase ID token. Injectable so the status-mapping logic can
  /// be tested without a Firebase app.
  final Future<String?> Function({bool forceRefresh}) _tokenProvider;

  static Future<String?> _firebaseIdToken({bool forceRefresh = false}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Future<String?>.value(null);
    return user.getIdToken(forceRefresh);
  }

  static const String _configuredBaseUrl =
      String.fromEnvironment('API_BASE_URL');

  static const Duration _timeout = Duration(seconds: 15);

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;

    // Local development default. 10.0.2.2 is the host machine as seen from the
    // Android emulator; every other target reaches it as localhost.
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  /// Submits or updates the signed-in user's rating for an entrepreneur.
  ///
  /// Never throws: every failure is reported as a [RatingResult] carrying a
  /// message safe to show to the user.
  Future<RatingResult> submitRating({
    required String entrepreneurId,
    required double value,
  }) {
    return _send(
      operation: 'Rating submission',
      successMessage: 'Thanks for rating!',
      failureMessage: 'Could not submit your rating. Please try again.',
      send: (token) => _put(entrepreneurId, value, token),
    );
  }

  /// Removes the signed-in user's rating for an entrepreneur.
  ///
  /// The backend answers 200 for both `deleted` and `absent`, so removing a
  /// rating that is not there is a success rather than an error — which keeps
  /// a retried removal safe.
  ///
  /// Never throws: every failure is reported as a [RatingResult].
  Future<RatingResult> removeRating({
    required String entrepreneurId,
  }) {
    return _send(
      operation: 'Rating removal',
      successMessage: 'Your rating was removed.',
      failureMessage: 'Could not remove your rating. Please try again.',
      send: (token) => _delete(entrepreneurId, token),
    );
  }

  /// Shared transport for both rating operations: attach the ID token, retry
  /// once on an expired one, and turn every outcome into a [RatingResult].
  Future<RatingResult> _send({
    required String operation,
    required String successMessage,
    required String failureMessage,
    required Future<http.Response> Function(String? token) send,
  }) async {
    try {
      var token = await _tokenProvider();

      if (token == null) {
        return const RatingResult._(
          RatingStatus.unauthenticated,
          'Please sign in to rate.',
        );
      }

      var response = await send(token);

      // ID tokens expire after about an hour. One forced refresh turns the
      // common "stale token" 401 into a success instead of a user-visible
      // error; a second 401 is a real authentication problem.
      if (response.statusCode == 401) {
        token = await _tokenProvider(forceRefresh: true);
        response = await send(token);
      }

      return _interpret(
        response,
        operation: operation,
        successMessage: successMessage,
        failureMessage: failureMessage,
      );
    } on SocketException {
      return const RatingResult._(
        RatingStatus.unavailable,
        'Could not reach the server. Check your connection and try again.',
      );
    } on FirebaseAuthException {
      return const RatingResult._(
        RatingStatus.unauthenticated,
        'Your session has expired. Please sign in again.',
      );
    } catch (error) {
      // Log the type only — never the token, the body, or the URL's headers.
      log('$operation failed (${error.runtimeType})');
      return RatingResult._(RatingStatus.failed, failureMessage);
    }
  }

  Future<http.Response> _put(
    String entrepreneurId,
    double value,
    String? token,
  ) {
    final uri = Uri.parse(
      '$baseUrl/api/ratings/${Uri.encodeComponent(entrepreneurId)}',
    );

    return _client
        .put(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'value': value}),
        )
        .timeout(_timeout);
  }

  Future<http.Response> _delete(String entrepreneurId, String? token) {
    final uri = Uri.parse(
      '$baseUrl/api/ratings/${Uri.encodeComponent(entrepreneurId)}',
    );

    // No body, so no Content-Type: the entrepreneur is named by the path and
    // the rater by the token.
    return _client.delete(uri,
        headers: {'Authorization': 'Bearer $token'}).timeout(_timeout);
  }

  /// Maps the backend's status contract onto a user-facing result.
  RatingResult _interpret(
    http.Response response, {
    required String operation,
    required String successMessage,
    required String failureMessage,
  }) {
    switch (response.statusCode) {
      case 200:
        Map<String, dynamic>? body;
        try {
          body = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {
          body = null;
        }

        final aggregate = body?['aggregate'] as Map<String, dynamic>?;

        return RatingResult._(
          RatingStatus.success,
          successMessage,
          outcome: body?['outcome'] as String?,
          aggregateRating: (aggregate?['rating'] as num?)?.toDouble(),
          ratingCount: (aggregate?['ratingCount'] as num?)?.toInt(),
        );

      case 400:
        return const RatingResult._(
          RatingStatus.invalid,
          'That rating is not valid. Please pick between 1 and 5 stars.',
        );

      case 401:
        return const RatingResult._(
          RatingStatus.unauthenticated,
          'Your session has expired. Please sign in again.',
        );

      case 403:
        return const RatingResult._(
          RatingStatus.forbidden,
          'You cannot rate your own profile.',
        );

      case 404:
        return const RatingResult._(
          RatingStatus.notFound,
          'This business is no longer available.',
        );

      case 429:
        return const RatingResult._(
          RatingStatus.rateLimited,
          'Too many ratings just now. Please try again in a few minutes.',
        );

      case 503:
        return const RatingResult._(
          RatingStatus.unavailable,
          'The service is busy. Please try again in a moment.',
        );

      default:
        // Status only: the body is never surfaced to the user or the log.
        log('$operation failed (HTTP ${response.statusCode})');
        return RatingResult._(RatingStatus.failed, failureMessage);
    }
  }

  void dispose() => _client.close();
}

enum RatingStatus {
  success,
  invalid,
  unauthenticated,
  forbidden,
  notFound,
  rateLimited,
  unavailable,
  failed,
}

/// Result of a rating submission, with a message safe to show to the user.
class RatingResult {
  const RatingResult._(
    this.status,
    this.message, {
    this.outcome,
    this.aggregateRating,
    this.ratingCount,
  });

  final RatingStatus status;

  /// User-facing text. Contains no server internals.
  final String message;

  /// "created", "updated" or "unchanged" for a submission; "deleted" or
  /// "absent" for a removal. Null when the request did not succeed.
  final String? outcome;

  final double? aggregateRating;
  final int? ratingCount;

  bool get isSuccess => status == RatingStatus.success;
}
