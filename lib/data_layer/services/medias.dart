import 'dart:developer' as developer;
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/data_layer/services/gallery_api_service.dart';

/// What came of a gallery save.
///
/// Every failure used to be caught and dropped, so a save that uploaded
/// nothing still told the user "Images Uploaded" and left the gallery empty
/// with no explanation. The caller now gets the counts and can say what
/// actually happened.
class MediaSaveResult {
  const MediaSaveResult({
    required this.saved,
    required this.failed,
    this.reason,
  });

  final int saved;
  final int failed;

  /// A safe code for the first failure — a Firebase error code or a runtime
  /// type name, never a message or URL.
  final String? reason;

  bool get nothingSelected => saved == 0 && failed == 0;
  bool get allFailed => saved == 0 && failed > 0;
  bool get partiallyFailed => saved > 0 && failed > 0;
  bool get allSaved => failed == 0 && saved > 0;
}

class MediaMethods {
  MediaMethods({GalleryApiService? gallery})
      : _gallery = gallery ?? GalleryApiService.instance;

  final GalleryApiService _gallery;

  /// Uploads [images] and records each one against [uid].
  ///
  /// Each image is uploaded and recorded as a unit, so a file that fails
  /// leaves no half-saved document behind and the ones that succeeded are
  /// still kept. Nothing is swallowed: the result says how many of each.
  Future<MediaSaveResult> addImages({
    required List<File> images,
    required String uid,
  }) async {
    int saved = 0;
    int failed = 0;
    String? reason;

    for (final image in images) {
      try {
        final url = await _uploadImage(image);
        await _recordMedia(url, uid);
        saved++;
      } on FirebaseException catch (e) {
        failed++;
        reason ??= e.code;
        // Code and plugin only — never the message or the download URL.
        developer.log(
          'Gallery image failed (plugin: ${e.plugin}, code: ${e.code})',
          name: 'Gallery',
        );
      } catch (e) {
        failed++;
        reason ??= e.runtimeType.toString();
        developer.log(
          'Gallery image failed (type: ${e.runtimeType})',
          name: 'Gallery',
        );
      }
    }

    return MediaSaveResult(saved: saved, failed: failed, reason: reason);
  }

  /// Uploads one image to private R2 and returns its object key.
  ///
  /// Firebase Storage used to hold these, under a shared `uploads/` prefix
  /// with no owner in the path, and stopped working once its quota was
  /// exhausted. The Media API now signs a short-lived PUT straight to R2
  /// under `user_media/{uid}/`, where the uid comes from the verified token
  /// rather than anything this client sends. Throws on failure.
  Future<String> _uploadImage(File image) {
    return _gallery.uploadGalleryImage(image);
  }

  /// Records one saved image against [uid]. Throws on failure.
  ///
  /// The field keeps its name. What it holds is now an R2 object key rather
  /// than a download URL, and every reader already branches on the shape:
  /// MediaImageResolver signs a key, and a legacy `https://` value from the
  /// Storage era still renders through NetworkImage.
  Future<void> _recordMedia(String url, String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('medias')
        .add({
      'url': url,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getImages(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('medias')
        .snapshots();
  }

  Future<void> deleteImage(String uid, String imageId) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('medias')
        .doc(imageId)
        .delete();
  }
}
