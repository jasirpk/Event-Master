import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/bussiness_layer.dart/snack_bar.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EventBookingMethods {
  Future<void> addEvent(
      {required String uid,
      required String clientName,
      required String email,
      required String phoneNumber,
      required String location,
      required String date,
      required String time,
      required String eventype,
      required String eventAbout,
      required String imagePath,
      required String selectedColor,
      required String guestCount,
      required List<Map<String, dynamic>> selectedVendors,
      required String sum}) async {
    try {
      String finalImagePath = imagePath;
      if (!imagePath.startsWith('http')) {
        finalImagePath = await uploadImage(File(imagePath));
      }
      // Generate a unique event ID
      String eventId = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('events')
          .doc()
          .id;

      Map<String, dynamic> eventCredential = {
        'uid': uid,
        'clientName': clientName,
        'email': email,
        'phoneNumber': phoneNumber,
        'location': location,
        'guestCount': guestCount,
        'date': date,
        'time': time,
        'eventype': eventype,
        'eventAbout': eventAbout,
        'imageURL': finalImagePath,
        'selectedColor': selectedColor,
        'selectedVendors': selectedVendors,
        'sum': sum,
      };

      // Add the event to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('events')
          .doc(eventId)
          .set(eventCredential);

      print('Added event to Firebase');
    } catch (e) {
      print('Error adding to events: $e');
      rethrow;
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      // Create a reference to the Firebase Storage location
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('event_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = ref.putFile(imageFile);

      // Wait for the upload to complete
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL of the uploaded file
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getGeneratedEventsDetails(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('events')
        .snapshots();
  }

  Future<DocumentSnapshot?> getEventsById(String uid, String eventId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('events')
          .doc(eventId)
          .get();
      if (documentSnapshot.exists) {
        return documentSnapshot;
      } else {
        print('Event with eventId $eventId not found');
        return null;
      }
    } catch (e) {
      print('Error getting documentId by Id $e');
      throw Exception('Failed to get document by ID: $e');
    }
  }

  Future<void> deleteGeneratedEventDetail(String uid, String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('events')
          .doc(documentId)
          .delete();

      print('Vendor details deleted successfully.');
    } catch (e) {
      print('Error deleting vendor details: $e');
      throw Exception('Failed to delete vendor details: $e');
    }
  }

  Future<void> updateEvent({
    required String uid,
    required String eventId,
    required String clientName,
    required String email,
    required String phoneNumber,
    required String location,
    required String date,
    required String time,
    required String eventType,
    required String eventAbout,
    required String imagePath,
    required String guestCount,
    required String sum,
  }) async {
    try {
      String finalImagePath = imagePath;
      if (!imagePath.startsWith('http')) {
        finalImagePath = await uploadImage(File(imagePath));
      }

      Map<String, dynamic> updatedEventCredential = {
        'clientName': clientName,
        'email': email,
        'phoneNumber': phoneNumber,
        'location': location,
        'guestCount': guestCount,
        'date': date,
        'time': time,
        'eventype': eventType,
        'eventAbout': eventAbout,
        'imageURL': finalImagePath,
        'sum': sum,
      };

      // Update the event in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('events')
          .doc(eventId)
          .update(updatedEventCredential);
      showCustomSnackBar('Success', 'Event updated  successfully');

      print('Updated event in Firebase');
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }
}
