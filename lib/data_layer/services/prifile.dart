import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

class ClientProfile {
  Future<void> updateProfile({
    required String userName,
    required String uid,
    required String imagePath,
    required String phoneNumber,
    required bool isValid,
  }) async {
    try {
      String downloadUrl;

      // Check if the imagePath is a URL or a local file path
      if (Uri.parse(imagePath).isAbsolute) {
        // If it's already a URL, use it directly
        downloadUrl = imagePath;
      } else {
        // Read the file data from the provided path
        File imageFile = File(imagePath);
        if (!imageFile.existsSync()) {
          throw Exception('File does not exist: $imagePath');
        }
        Uint8List imageData = await imageFile.readAsBytes();

        // Prepare the storage reference
        String fileName = imagePath.split('/').last;
        Reference storageRef =
            FirebaseStorage.instance.ref().child('client_profile/$fileName');

        // Upload the image data
        UploadTask uploadTask = storageRef.putData(imageData);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});

        // Get the download URL
        downloadUrl = await taskSnapshot.ref.getDownloadURL();
      }

      // Update Firestore document
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('users').doc(uid);
      await documentReference.update({
        'userName': userName,
        'imagePath': downloadUrl,
        'phoneNumber': phoneNumber,
        'timestamp': FieldValue.serverTimestamp(),
        'isValid': isValid,
      });

      print('User details added successfully to sub-collection.');
    } catch (e) {
      print('Error adding user Profile: $e');
      throw Exception('Failed to add user Profile: $e');
    }
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    try {
      DocumentReference documentRef =
          FirebaseFirestore.instance.collection('users').doc(uid);
      DocumentSnapshot documentSnapshot = await documentRef.get();
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
