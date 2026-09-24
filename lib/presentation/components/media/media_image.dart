import 'package:flutter/material.dart';

import 'package:event_master/data_layer/services/media_image_resolver.dart';

/// The image shown wherever a template picture is missing, still resolving, or
/// failed to resolve. One constant so every list, grid and detail header falls
/// back to the same thing.
const String kMediaPlaceholderAsset = 'assets/images/venue_decoration_img.jpg';

/// [kMediaPlaceholderAsset] as a provider, for [MediaImage.placeholder].
const AssetImage kMediaPlaceholderImage = AssetImage(kMediaPlaceholderAsset);

/// Renders whatever a Firestore `imagePath` points at — a legacy Firebase
/// Storage URL, a bundled asset, or an R2 objectKey that needs signing.
///
/// [builder] receives the resolved [ImageProvider], or [placeholder] while an
/// objectKey is being signed and if signing fails. The surrounding layout is
/// therefore built exactly once and never swaps in a spinner. Paths that need
/// no network round-trip are resolved before the first frame, so the common
/// case doesn't flash the placeholder at all.
class MediaImage extends StatefulWidget {
  const MediaImage({
    super.key,
    required this.imagePath,
    required this.builder,
    this.placeholder,
  });

  /// The raw Firestore value. Null, empty and unresolvable values fall back to
  /// [placeholder].
  final String? imagePath;

  /// Stands in until the real image is available, and instead of it on
  /// failure. Null means the caller renders its own empty state.
  final ImageProvider? placeholder;

  final Widget Function(BuildContext context, ImageProvider? image) builder;

  @override
  State<MediaImage> createState() => _MediaImageState();
}

class _MediaImageState extends State<MediaImage> {
  ImageProvider? _image;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(MediaImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only a different path is worth re-resolving; a plain rebuild (a parent
    // stream tick, a scroll) must not hit the Media API again.
    if (oldWidget.imagePath != widget.imagePath) _load();
  }

  void _load() {
    // Resolving synchronously first is what avoids a placeholder frame for
    // legacy URLs, assets and already-signed objectKeys.
    final immediate = MediaImageResolver.instance.resolveSync(widget.imagePath);
    if (immediate != null) {
      _image = immediate;
      return;
    }

    _image = null;

    final requested = widget.imagePath;
    MediaImageResolver.instance.resolve(requested).then((resolved) {
      // This tile may have been disposed, or recycled onto another document,
      // while the Media API call was in flight.
      if (!mounted || requested != widget.imagePath || resolved == null) return;
      setState(() => _image = resolved);
    });
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _image ?? widget.placeholder);
}
