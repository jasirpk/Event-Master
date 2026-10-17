import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Thrown when an event-image request fails.
///
/// Never carries the Authorization header, an ID token, or a presigned URL —
/// only a message safe to show a user and the HTTP status.
class EventImageApiException implements Exception {
  final String message;
  final int? statusCode;

  EventImageApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      'EventImageApiException: $message${statusCode == null ? '' : ' ($statusCode)'}';
}

/// Uploads an event picture to the private R2 bucket.
///
/// Its own client rather than a method on [ClientProfileApiService]: that one
/// speaks to `/api/client-profile` and writes `users/{uid}`, while this writes
/// no document at all. The API keeps the two surfaces apart so a request to
/// one cannot reach the other's folder, and mirroring that here keeps the
/// boundary visible from this side too.
///
/// Bytes never pass through the API. The client asks for a presigned PUT,
/// uploads straight to storage, and keeps the object key — never the signed
/// URL, which lapses in minutes.
class EventImageApiService {
  static final EventImageApiService instance = EventImageApiService();

  final http.Client _client;

  /// [tokenProvider] follows the convention [RatingApi] already uses: the
  /// default reads Firebase, and a test supplies its own so these calls can
  /// run with no Firebase app.
  EventImageApiService({
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

  static const Duration _timeout = Duration(seconds: 30);
  static const Duration _uploadTimeout = Duration(seconds: 120);

  /// Must match the API's ALLOWED_CONTENT_TYPES.
  static const Map<String, String> _contentTypes = {
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.png': 'image/png',
    '.webp': 'image/webp',
  };

  /// Must match the API's MAX_UPLOAD_BYTES.
  static const int maxUploadBytes = 10 * 1024 * 1024;

  /// Matches the convention already used by this app's other API clients.
  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  /// Uploads [file] and returns its R2 object key.
  ///
  /// The key is chosen by the server from the verified token's uid, so this
  /// client cannot influence where the object lands. The caller stores the
  /// returned key — `event_images/{uid}/{timestamp}-{name}` — in Firestore.
  Future<String> uploadEventImage(File file) async {
    final contentType = _contentTypeFor(file.path);

    if (contentType == null) {
      throw EventImageApiException(
        'Unsupported image type. Please use a JPG, PNG or WebP file.',
      );
    }

    final bytes = await file.readAsBytes();

    if (bytes.isEmpty) {
      throw EventImageApiException('That image file appears to be empty.');
    }

    if (bytes.length > maxUploadBytes) {
      throw EventImageApiException(
        'That image is too large. Please choose one under 10 MB.',
      );
    }

    final signed = await _requestUploadUrl(
      fileName: _basename(file.path),
      contentType: contentType,
      contentLength: bytes.length,
    );

    final uploadUrl = signed['uploadUrl'] as String?;
    final objectKey = signed['objectKey'] as String?;

    if (uploadUrl == null || objectKey == null) {
      throw EventImageApiException(
        'The server returned an incomplete upload URL.',
      );
    }

    final http.Response response;

    try {
      response = await _client
          .put(
            Uri.parse(uploadUrl),
            // Both headers are bound into the signature, so storage rejects
            // the PUT if either differs from what was declared.
            headers: {
              'Content-Type': contentType,
              'Content-Length': '${bytes.length}',
            },
            body: bytes,
          )
          .timeout(_uploadTimeout);
    } catch (_) {
      // The presigned URL is never interpolated into the message: it grants
      // write access for its lifetime.
      throw EventImageApiException(
        'Could not upload the image. Check your connection and try again.',
      );
    }

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw EventImageApiException(
        'The image could not be stored. Please try again.',
        statusCode: response.statusCode,
      );
    }

    return objectKey;
  }

  Future<Map<String, dynamic>> _requestUploadUrl({
    required String fileName,
    required String contentType,
    required int contentLength,
  }) async {
    final token = await _currentIdToken();
    final uri = Uri.parse('$baseUrl/api/events/upload-url');

    final http.Response response;

    try {
      response = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            // Exactly these three keys. The endpoint refuses an unexpected
            // extra one rather than ignoring it, so there is nothing to add.
            body: jsonEncode({
              'fileName': fileName,
              'contentType': contentType,
              'contentLength': contentLength,
            }),
          )
          .timeout(_timeout);
    } catch (error) {
      if (error is EventImageApiException) rethrow;

      // The underlying error is not interpolated: it can quote the full
      // request, Authorization header included.
      throw EventImageApiException(
        'Could not reach the server. Check your connection and try again.',
      );
    }

    if (response.statusCode != 200) {
      throw EventImageApiException(
        _messageForStatus(response.statusCode),
        statusCode: response.statusCode,
      );
    }

    if (response.body.isEmpty) {
      throw EventImageApiException(
        'The server returned an incomplete upload URL.',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// The server answers every validation failure with one generic message so
  /// the response is not an oracle; the mapping happens here instead.
  String _messageForStatus(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'That image could not be accepted. Please choose another.';
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 413:
        return 'That image is too large.';
      case 429:
        return "You've uploaded too many images recently. Please try again "
            'later.';
      default:
        return statusCode >= 500
            ? 'The server could not store the image. Please try again later.'
            : 'Could not prepare the image upload.';
    }
  }

  Future<String> _currentIdToken() async {
    final token = await _tokenProvider();
    if (token == null) {
      throw EventImageApiException('Please sign in again to add an event.');
    }
    return token;
  }

  String _basename(String path) {
    final slash = path.lastIndexOf(Platform.pathSeparator);
    final unix = path.lastIndexOf('/');
    final cut = slash > unix ? slash : unix;
    return cut < 0 ? path : path.substring(cut + 1);
  }

  String _extension(String path) {
    final name = _basename(path);
    final dot = name.lastIndexOf('.');
    return dot <= 0 ? '' : name.substring(dot).toLowerCase();
  }

  String? _contentTypeFor(String path) => _contentTypes[_extension(path)];
}
