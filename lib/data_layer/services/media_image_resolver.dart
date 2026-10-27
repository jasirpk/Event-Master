import 'dart:async' show Completer, TimeoutException;
import 'dart:collection' show Queue;
import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

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
  MediaImageResolver._({MediaService? mediaService})
      : _mediaService = mediaService ?? MediaService.instance;

  static final MediaImageResolver instance = MediaImageResolver._();

  /// A resolver with a cache of its own and a supplied collaborator.
  ///
  /// The singleton is what the app uses; this exists so the caching, sharing
  /// and expiry rules can be exercised without a network or a Firebase app,
  /// and without one test's cache leaking into the next.
  @visibleForTesting
  factory MediaImageResolver.forTesting(MediaService mediaService) =>
      MediaImageResolver._(mediaService: mediaService);

  final MediaService _mediaService;

  final Map<String, _SignedUrl> _cache = {};

  /// Caps how many signing calls are in flight at once.
  ///
  /// Opening a gallery used to fan out one request per tile with nothing
  /// holding them back — a dozen gallery images plus avatars and category
  /// art all at once. The shared API instance answered some with HTTP 520
  /// and let others time out. Four at a time is a deliberately conservative
  /// ceiling; the rest queue and go out as slots free up, so a large screen
  /// now trickles rather than bursts.
  ///
  /// This is a mitigation under test, not a proven cure: the overload was
  /// never reproduced in isolation.
  final _ConcurrencyGate _gate = _ConcurrencyGate(maxInFlight: 4);

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
    } catch (error) {
      _reportFailure(path, error);
      return null;
    }
  }

  /// Failures already logged, as `objectKey|category`, so a rebuilding list
  /// reports each one once rather than on every frame.
  final Set<String> _reported = {};

  /// Logs why [objectKey] could not be signed: its folder, a failure category
  /// and the HTTP status. Never the token, the signed URL or the response
  /// body — [MediaApiException.toString] carries the body, so it is not used.
  void _reportFailure(String objectKey, Object error) {
    final int? status = error is MediaApiException ? error.statusCode : null;
    final String category = _failureCategory(error);
    if (!_reported.add('$objectKey|$category')) return;

    final slash = objectKey.indexOf('/');
    final folder = slash > 0 ? objectKey.substring(0, slash) : '(no folder)';
    developer.log(
      'Could not sign an image in "$folder": $category'
      '${status != null ? ' (HTTP $status)' : ''}',
      name: 'MediaImageResolver',
    );
  }

  static String _failureCategory(Object error) {
    if (error is MediaApiException) {
      final status = error.statusCode;
      if (status == null) return 'not-signed-in';
      if (status == 401 || status == 403) return 'unauthorized';
      if (status == 404) return 'not-found';
      if (status == 200) return 'incomplete-response';
      return 'http-error';
    }
    if (error is TimeoutException) return 'timeout';
    if (error is FormatException) return 'malformed-response';
    // On web a CORS rejection surfaces here too, indistinguishable from an
    // unreachable host.
    if (error is http.ClientException) return 'network';
    return 'unexpected (${error.runtimeType})';
  }

  /// A live signed URL for [objectKey], reusing an in-flight request when one
  /// is already running so a list of tiles sharing a key calls the API once.
  Future<String> _signedUrlFor(String objectKey) {
    final existing = _cache[objectKey];
    if (existing != null && existing.isLive) return existing.future;

    late final _SignedUrl entry;
    // The call is gated, the cache entry is not: it is registered below
    // before any await, so a second caller for this key joins this same
    // future while it is still queued rather than opening a second request.
    final future =
        _gate.run(() => _mediaService.getDownloadUrl(objectKey)).then(
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

/// Lets at most [maxInFlight] operations run at once; the rest wait in turn.
///
/// A slot is released in a `finally`, so success, failure, timeout and a
/// synchronous throw all give it back. A freed slot is handed straight to the
/// next waiter rather than decremented and re-acquired, which keeps the count
/// exact and the queue moving.
class _ConcurrencyGate {
  _ConcurrencyGate({required this.maxInFlight}) : assert(maxInFlight > 0);

  final int maxInFlight;

  int _inFlight = 0;
  final Queue<Completer<void>> _waiting = Queue<Completer<void>>();

  /// Runs [action] once a slot is free, releasing it however [action] ends.
  Future<T> run<T>(Future<T> Function() action) async {
    await _acquire();

    try {
      return await action();
    } finally {
      _release();
    }
  }

  Future<void> _acquire() {
    if (_inFlight < maxInFlight) {
      _inFlight++;
      return Future<void>.value();
    }

    final waiter = Completer<void>();
    _waiting.add(waiter);

    return waiter.future;
  }

  void _release() {
    if (_waiting.isEmpty) {
      _inFlight--;
      return;
    }

    // Pass the slot on directly: _inFlight stays as it is.
    _waiting.removeFirst().complete();
  }
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
