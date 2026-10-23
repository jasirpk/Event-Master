import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Uploads a person's own gallery photographs to R2 through the Media API.
///
/// Modelled on [EventImageApiService], which already speaks this exact
/// contract: the API signs a short-lived PUT and the bytes go straight to
/// private R2. No R2 credential ever reaches the app, and the uid is taken
/// from the verified token server-side — the request body carries only the
/// file's own details, never an identity.
///
/// Gallery objects live under `user_media/{uid}/` and are readable only by
/// their owner, so they are fetched through the gallery download endpoint
/// rather than the public media one.

class GalleryApiException implements Exception {
  final String message;
  final int? statusCode;

  GalleryApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      'GalleryApiException: $message${statusCode == null ? '' : ' ($statusCode)'}';
}

/// Uploads one gallery photograph to the private R2 bucket.
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
class GalleryApiService {
  static final GalleryApiService instance = GalleryApiService();

  final http.Client _client;

  /// [tokenProvider] follows the convention [RatingApi] already uses: the
  /// default reads Firebase, and a test supplies its own so these calls can
  /// run with no Firebase app.
  GalleryApiService({
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

  /// Must match the API's MAX_FILE_NAME_LENGTH.
  ///
  /// The server measures the *trimmed* name, before it sanitizes unusual
  /// characters — and since sanitizing replaces one character with one
  /// underscore, the sanitized name is the same length anyway. Checking here
  /// turns a round trip and a generic 400 into an immediate, specific
  /// message; the server remains the authority.
  static const int maxFileNameLength = 128;

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
  /// returned key — `user_media/{uid}/{timestamp}-{name}` — in Firestore.
  Future<String> uploadGalleryImage(File file) async {
    final contentType = _contentTypeFor(file.path);

    if (contentType == null) {
      throw GalleryApiException(
        'Unsupported image type. Please use a JPG, PNG or WebP file.',
      );
    }

    final fileName = _basename(file.path).trim();

    if (fileName.isEmpty) {
      throw GalleryApiException('Please choose an image.');
    }

    if (fileName.length > maxFileNameLength) {
      throw GalleryApiException(
        'That image\'s file name is too long. Please rename it to under '
        '$maxFileNameLength characters.',
      );
    }

    final Uint8List bytes;

    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      // The underlying error quotes the absolute path on the device, which
      // then surfaced in a snackbar. The user cannot act on that, and it does
      // not belong on screen.
      throw GalleryApiException(
        'That image could not be read. Please choose another.',
      );
    }

    if (bytes.isEmpty) {
      throw GalleryApiException('That image file appears to be empty.');
    }

    if (bytes.length > maxUploadBytes) {
      throw GalleryApiException(
        'That image is too large. Please choose one under 10 MB.',
      );
    }

    final signed = await _requestUploadUrl(
      fileName: fileName,
      contentType: contentType,
      contentLength: bytes.length,
    );

    final uploadUrl = signed['uploadUrl'] as String?;
    final objectKey = signed['objectKey'] as String?;

    if (uploadUrl == null || objectKey == null) {
      throw GalleryApiException(
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
      throw GalleryApiException(
        'Could not upload the image. Check your connection and try again.',
      );
    }

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw GalleryApiException(
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
    final uri = Uri.parse('$baseUrl/api/gallery/upload-url');

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
      if (error is GalleryApiException) rethrow;

      // The underlying error is not interpolated: it can quote the full
      // request, Authorization header included.
      throw GalleryApiException(
        'Could not reach the server. Check your connection and try again.',
      );
    }

    if (response.statusCode != 200) {
      throw GalleryApiException(
        _messageForStatus(response.statusCode),
        statusCode: response.statusCode,
      );
    }

    if (response.body.isEmpty) {
      throw GalleryApiException(
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
      throw GalleryApiException('Please sign in again to add an image.');
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
