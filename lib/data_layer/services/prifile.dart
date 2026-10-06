import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/data_layer/services/client_profile_api_service.dart';

class ClientProfile {
  /// Saves the signed-in user's own profile through the API.
  ///
  /// Previously this uploaded to Firebase Storage and wrote `users/{uid}`
  /// directly, which meant the client chose its own `uid`, stamped its own
  /// `timestamp`, and hard-coded `isValid: true`. All three are the server's
  /// now, and the avatar goes to Cloudflare R2 through a presigned PUT —
  /// Firebase Storage's quota is no longer in the path.
  ///
  /// Only a freshly picked file is uploaded. [newImage] null means the
  /// stored avatar is left exactly as it is: an R2 key or a legacy URL,
  /// either way untouched, because `imagePath` is then omitted from the
  /// request entirely.
  ///
  /// If the upload succeeds and the save then fails, the uploaded object is
  /// deliberately left in place. The only delete available would clear the
  /// whole `client_profile_images/{uid}/` prefix, which still holds the
  /// user's current avatar — an orphan is far cheaper than that.
  Future<String> saveProfile({
    required String userName,
    required String phoneNumber,
    File? newImage,
  }) async {
    final api = ClientProfileApiService.instance;

    final String? imagePath =
        newImage != null ? await api.uploadAvatar(newImage) : null;

    return api.updateProfile(
      userName: userName,
      phoneNumber: phoneNumber,
      imagePath: imagePath,
    );
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    try {
      final documentRef =
          FirebaseFirestore.instance.collection('users').doc(uid);
      final documentSnapshot = await documentRef.get();
      if (!documentSnapshot.exists) {
        throw Exception('User profile does not exist for uid: $uid');
      }
      return documentSnapshot;
    } catch (e) {
      print('Error getting user profile: $e');
      throw Exception('Failed to get user profile: $e');
    }
  }
}
