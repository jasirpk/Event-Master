import 'package:flutter/widgets.dart';

import 'package:event_master/data_layer/services/media_service.dart';

/// Turns a Firestore `imagePath` into an [ImageProvider].
///
/// Template artwork is mid-migration, so a document's `imagePath` is either a
/// legacy Firebase Storage download URL, a bundled asset, or an R2 objectKey
/// written by the Admin Console. This is the single place that tells those
/// apart, so no widget has to.
///
/// Only the objectKey case costs anything: it needs a short-lived signed GET
/// URL from the Media API. Signed URLs are cached by objectKey and reused
/// until shortly before they lapse, which stops a rebuilding grid or list from
/// re-signing the same object over and over. A signed URL is never persisted.
class MediaImageResolver {
  MediaImageResolver._();

  static final MediaImageResolver instance = MediaImageResolver._();

  final MediaService _mediaService = MediaService.instance;

  final Map<String, _SignedUrl> _cache = {};

  /// Lifetime assumed when a signed URL doesn't declare one. Matches the
  /// Media API's documented 300s.
  static const Duration _assumedLifetime = Duration(seconds: 300);

  /// Signed URLs are retired this long before they actually expire, so one
  /// can't lapse between being handed to a widget and the device fetching it.
  static const Duration _safetyMargin = Duration(seconds: 60);

  /// The provider for [imagePath], but only if it needs no network round-trip.
  ///
  /// Returns null just for an objectKey with no live cached URL — the one case
  /// that has to go async. Everything else (null/empty, legacy URL, bundled
  /// asset, already-signed objectKey) resolves here, so those render on the
  /// first frame instead of flickering through a placeholder.
  ImageProvider? resolveSync(String? imagePath) {
    final path = imagePath?.trim();
    if (path == null || path.isEmpty) return null;

    if (_isHttpUrl(path)) return NetworkImage(path);
    if (_isAssetPath(path)) return AssetImage(path);

    final url = _cache[path]?.readyUrl;
    return url == null ? null : NetworkImage(url);
  }

  /// The provider for [imagePath], signing an R2 objectKey if one is needed.
  ///
  /// Never throws. An unreachable Media API, an expired session or a rejected
  /// key all resolve to null, leaving the caller free to fall back to its own
  /// placeholder.
  Future<ImageProvider?> resolve(String? imagePath) async {
    final immediate = resolveSync(imagePath);
    if (immediate != null) return immediate;

    final path = imagePath?.trim();
    if (path == null || path.isEmpty) return null;

    // Anything resolveSync recognises has already been handled above; only an
    // unsigned objectKey reaches here.
    if (_isHttpUrl(path) || _isAssetPath(path)) return null;

    try {
      return NetworkImage(await _signedUrlFor(path));
    } catch (_) {
      return null;
    }
  }

  /// A live signed URL for [objectKey], reusing an in-flight request when one
  /// is already running so a list of tiles sharing a key calls the API once.
  Future<String> _signedUrlFor(String objectKey) {
    final existing = _cache[objectKey];
    if (existing != null && existing.isLive) return existing.future;

    late final _SignedUrl entry;
    final future = _mediaService.getDownloadUrl(objectKey).then(
      (url) {
        entry.url = url;
        entry.expiresAt = _expiryFor(url);
        return url;
      },
      onError: (Object error) {
        // Failures aren't cached, so the next rebuild is free to retry.
        if (identical(_cache[objectKey], entry)) _cache.remove(objectKey);
        throw error;
      },
    );

    entry = _SignedUrl(future);
    _cache[objectKey] = entry;
    return future;
  }

  /// When [signedUrl] stops being safe to hand out.
  ///
  /// Presigned R2 URLs carry their own lifetime in `X-Amz-Expires`, so the real
  /// value is used when present and [_assumedLifetime] covers anything
  /// unexpected. It is measured from now rather than the URL's `X-Amz-Date`
  /// because the URL was just minted, which keeps this correct even if the
  /// device clock is skewed against the signing server's.
  static DateTime _expiryFor(String signedUrl) {
    final declared = int.tryParse(
      Uri.tryParse(signedUrl)?.queryParameters['X-Amz-Expires'] ?? '',
    );
    final lifetime = (declared != null && declared > 0)
        ? Duration(seconds: declared)
        : _assumedLifetime;

    // A lifetime shorter than the margin leaves nothing safe to cache, so the
    // entry expires immediately and the next read re-signs.
    final usable = lifetime - _safetyMargin;
    return DateTime.now().add(usable > Duration.zero ? usable : Duration.zero);
  }

  static bool _isHttpUrl(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  static bool _isAssetPath(String path) => path.startsWith('assets/');
}

/// A signed URL request: in flight, or resolved with the moment it goes stale.
class _SignedUrl {
  _SignedUrl(this.future);

  final Future<String> future;
  String? url;
  DateTime? expiresAt;

  bool get _unexpired {
    final at = expiresAt;
    return at != null && at.isAfter(DateTime.now());
  }

  /// Worth reusing: either still in flight, or resolved and not near expiry.
  bool get isLive => url == null || _unexpired;

  /// The URL if it is resolved and safely in date, otherwise null.
  String? get readyUrl => _unexpired ? url : null;
}
