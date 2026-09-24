import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Thrown when a Media API request fails or returns an unexpected response.
///
/// Never carries the Authorization header or a signed URL — only a message,
/// the HTTP status (if any), and a truncated response body.
class MediaApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  MediaApiException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() {
    final status = statusCode != null ? ' (status $statusCode)' : '';
    final body = responseBody != null ? ' — $responseBody' : '';
    return 'MediaApiException: $message$status$body';
  }
}

/// Read-only Media API client for template artwork.
///
/// Category and sub-category images live in a private Cloudflare R2 bucket, so
/// a Firestore `imagePath` is an object key rather than a URL. This exchanges
/// that key for a short-lived signed GET URL.
///
/// Deliberately read-only: this app never uploads template media — that is the
/// Admin Console's job — so there is no upload path to misuse here. It calls
/// `/public-download-url`, which any signed-in user may use and which the API
/// restricts to the catalogue folders; the admin `/download-url` endpoint
/// requires a claim this app's users do not have.
class MediaService {
  /// The instance every caller should use. One long-lived client: constructing
  /// one per image would leak an `http.Client` per tile.
  static final MediaService instance = MediaService();

  final http.Client _client;

  MediaService({http.Client? client}) : _client = client ?? http.Client();

  static final String _configuredBaseUrl = dotenv.env['API_BASE_URL'] ?? "";

  static const Duration _timeout = Duration(seconds: 15);

  /// Matches the convention already used by this app's other API clients.
  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;

    // Local development default. 10.0.2.2 is the host machine as seen from the
    // Android emulator; every other target reaches it as localhost.
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  /// Resolves a temporary (~5 minute) signed GET URL for [objectKey].
  ///
  /// Never cache or persist the returned URL — [MediaImageResolver] holds it
  /// only until shortly before it lapses.
  Future<String> getDownloadUrl(String objectKey) async {
    final token = await _currentIdToken();

    final response = await _client.get(
      Uri.parse('$baseUrl/api/media/public-download-url').replace(
        queryParameters: {'objectKey': objectKey},
      ),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      throw MediaApiException(
        'Failed to obtain a download URL from the Media API',
        statusCode: response.statusCode,
        responseBody: _safeBody(response.body),
      );
    }

    final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
    final String? downloadUrl = body['downloadUrl'] as String?;

    if (downloadUrl == null) {
      throw MediaApiException(
        'Media API returned an incomplete download-url response',
        statusCode: response.statusCode,
      );
    }

    return downloadUrl;
  }

  Future<String> _currentIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw MediaApiException('No signed-in Firebase user');
    }
    final token = await user.getIdToken();
    if (token == null) {
      throw MediaApiException('Firebase did not return an ID token');
    }
    return token;
  }

  /// Truncates a response body before it goes into an exception message, so an
  /// unexpectedly large response never balloons a log line.
  String _safeBody(String body) {
    const maxLength = 500;
    return body.length > maxLength ? '${body.substring(0, maxLength)}…' : body;
  }
}
