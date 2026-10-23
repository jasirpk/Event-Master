import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// The R2 folder holding consumer event pictures.
///
/// Named here because it is what decides which endpoint may sign a read for
/// a key — see [MediaService.getDownloadUrl].
const String kEventImageFolder = 'event_images';

/// A person's own gallery photographs. Private to their owner, like event
/// pictures, so they are signed by their own owner-scoped endpoint.
const String kGalleryFolder = 'user_media';

/// Every folder the Media API stores objects under.
///
/// Mirrors the API's own lists — ALLOWED_FOLDERS, PROFILE_MEDIA_FOLDERS,
/// VENDOR_MEDIA_FOLDER and EVENT_MEDIA_FOLDER in media.validation.ts. It is
/// an explicit roster rather than a "looks like a path" guess, because the
/// question it answers is whether a stored string is already in storage or is
/// a local file still to be uploaded, and guessing wrong in either direction
/// is a bug: a missed key gets read off disk, and a false positive silently
/// stores a path that resolves to nothing.
const Set<String> kMediaObjectFolders = {
  'category_images',
  'subcategory_images',
  'profile_images',
  'profile_portfolio',
  'client_profile_images',
  'vendor_images',
  kEventImageFolder,
};

/// Whether [value] is an object key already held by the Media API.
///
/// Only the leading folder is checked; the rest of the grammar is the API's
/// to enforce. A local file path never begins with one of these names, and a
/// key always does.
bool isMediaObjectKey(String value) {
  final slash = value.indexOf('/');
  if (slash <= 0) return false;

  return kMediaObjectFolders.contains(value.substring(0, slash));
}

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

  /// [tokenProvider] follows the convention [RatingApi] already uses: the
  /// default reads Firebase, and a test supplies its own so these calls can
  /// run with no Firebase app.
  MediaService({
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
      Uri.parse('$baseUrl${_downloadPathFor(objectKey)}').replace(
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

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    final String? downloadUrl = body['downloadUrl'] as String?;

    if (downloadUrl == null) {
      throw MediaApiException(
        'Media API returned an incomplete download-url response',
        statusCode: response.statusCode,
      );
    }

    return downloadUrl;
  }

  /// The endpoint that may sign a read for [objectKey].
  ///
  /// Catalogue, profile and vendor artwork go through `/public-download-url`,
  /// which any signed-in caller may use because those images are already on
  /// show throughout the apps. An event picture belongs to one person's
  /// booking, so the API keeps it out of that list and serves it from an
  /// owner-scoped endpoint instead, which answers 404 for somebody else's
  /// key. Sending an event key to the public endpoint would simply be
  /// refused.
  /// Visible for tests: which endpoint may sign [objectKey].
  @visibleForTesting
  static String debugDownloadPathFor(String objectKey) =>
      _downloadPathFor(objectKey);

  static String _downloadPathFor(String objectKey) {
    if (objectKey.startsWith('$kEventImageFolder/')) {
      return '/api/events/download-url';
    }

    // Gallery photographs are the same case: private to one person, kept out
    // of the public list, and served by an endpoint that answers 404 for
    // somebody else's key.
    if (objectKey.startsWith('$kGalleryFolder/')) {
      return '/api/gallery/download-url';
    }

    return '/api/media/public-download-url';
  }

  Future<String> _currentIdToken() async {
    final token = await _tokenProvider();
    if (token == null) {
      throw MediaApiException('No signed-in Firebase user');
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
