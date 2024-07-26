import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MediaMethods {
  Future<void> addImages(
      {required List<File> images, required String uid}) async {
    try {
      List<String> mediaUrls = await uploadImages(images);
      await saveMediaUrlsToFirestore(mediaUrls, uid);
    } catch (e) {
      print('Error adding images: $e');
    }
  }

  Future<List<String>> uploadImages(List<File> images) async {
    List<String> downloadUrls = [];
    for (var image in images) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('uploads/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final uploadTask = storageRef.putFile(image);
        final snapshot = await uploadTask.whenComplete(() => null);
        final downloadURL = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadURL);
        print('Uploaded Image URL: $downloadURL');
      } catch (e) {
        print('Failed to upload image: $e');
      }
    }
    return downloadUrls;
  }

  Future<void> saveMediaUrlsToFirestore(
      List<String> mediaUrls, String uid) async {
    final firestore = FirebaseFirestore.instance;
    final mediaCollection =
        firestore.collection('users').doc(uid).collection('medias');

    for (var url in mediaUrls) {
      try {
        await mediaCollection.add({
          'url': url,
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('Saved media URL to Firestore: $url');
      } catch (e) {
        print('Failed to save media URL to Firestore: $e');
      }
    }
  }

  Stream<QuerySnapshot> getImages(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('medias')
        .snapshots();
  }
}
