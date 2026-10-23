import 'package:event_master/presentation/pages/dashboard/media_scalable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// Thumbnails decode small; the viewer keeps the original.
///
/// Legacy `https://` values are used deliberately: the resolver returns those
/// synchronously without touching the Media API, so this needs no network,
/// no Firebase app and no timing assumptions.
void main() {
  testWidgets('the full-screen viewer uses the original-resolution provider',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: FullScreenImageView(
        imageUrls: const ['https://legacy.example/a.jpg'],
        initialIndex: 0,
        uid: 'me',
        imageId: 'doc-1',
      ),
    ));
    await tester.pump();

    final gallery = tester.widget<PhotoViewGallery>(
      find.byType(PhotoViewGallery),
    );

    final options =
        gallery.builder!(tester.element(find.byType(PhotoViewGallery)), 0);
    final provider = options.imageProvider;

    expect(provider, isA<NetworkImage>(),
        reason: 'zooming must use the full-resolution image');
    expect(provider, isNot(isA<ResizeImage>()),
        reason: 'the viewer must not decode at thumbnail size');
    expect((provider as NetworkImage).url, 'https://legacy.example/a.jpg');

    // The widget harness answers every HTTP request with 400, so painting a
    // NetworkImage throws. Which provider was chosen is the point here, not
    // whether bytes arrived.
    tester.takeException();
  });
}
