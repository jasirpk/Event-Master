import 'package:event_master/data_layer/services/media_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Which endpoint signs which key.
///
/// Gallery photographs are private to one person, so they must never be
/// sent to the public media endpoint — which any signed-in caller may use.
void main() {
  group('gallery keys go to the owner-scoped endpoint', () {
    test('the gallery folder is user_media', () {
      expect(kGalleryFolder, 'user_media');
    });

    test('a gallery key is not routed to the public endpoint', () {
      expect(MediaService.debugDownloadPathFor('user_media/me/1-a.jpg'),
          '/api/gallery/download-url');
    });

    test('an event key keeps its own owner-scoped endpoint', () {
      expect(MediaService.debugDownloadPathFor('event_images/me/1-a.jpg'),
          '/api/events/download-url');
    });

    test('catalogue art still uses the public endpoint', () {
      for (final key in [
        'category_images/a/1-a.jpg',
        'subcategory_images/a/1-a.jpg',
        'client_profile_images/a/1-a.jpg',
      ]) {
        expect(MediaService.debugDownloadPathFor(key),
            '/api/media/public-download-url',
            reason: '$key must keep working');
      }
    });
  });
}
