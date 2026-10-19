import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:event_master/bussiness_layer.dart/repos/snack_bar.dart';
import 'dart:io';

import 'package:event_master/data_layer/services/event_image_api_service.dart';
import 'package:event_master/data_layer/services/media_service.dart';

class EventBookingMethods {
  /// Injectable so the image-reference logic can be exercised without
  /// reaching the network; defaults to the shared instance.
  EventBookingMethods({EventImageApiService? imageApi})
      : _imageApi = imageApi ?? EventImageApiService.instance;

  final EventImageApiService _imageApi;

  Future<void> addEvent({
    required String uid,
    required String EntrepreneurId,
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
    required bool isValid,
    required List<Map<String, dynamic>> selectedVendors,
    required String sum,
  }) async {
    try {
      // An already-stored value is either a legacy Storage URL or an R2 key
      // from a previous save; neither needs re-uploading. Only a local file
      // path picked on this device does.
      final String finalImagePath = await storedImageRef(imagePath);

      // Generate a unique event ID
      String eventId = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('events')
          .doc()
          .id;

      Map<String, dynamic> eventCredential = {
        'EntrepreneurId': EntrepreneurId,
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
        'isValid': isValid,
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

  /// Stores an event picture and returns its R2 object key.
  ///
  /// Was Firebase Storage, which returned a download URL. It now returns a
  /// key — `event_images/{uid}/{timestamp}-{name}` — because the bucket is
  /// private and a signed URL lapses in minutes, so persisting one would
  /// leave a booking pointing at a dead link. [MediaImage] exchanges the key
  /// for a fresh URL whenever the picture is actually shown.
  ///
  /// Errors propagate. Both callers upload before writing the booking, so a
  /// failed upload means no booking is written at all — which is the point:
  /// a booking that silently lost its picture is worse than one not saved.
  Future<String> uploadImage(File imageFile) async {
    return _imageApi.uploadEventImage(imageFile);
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
      final String finalImagePath = await storedImageRef(imagePath);

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

  /// What to persist for [imagePath].
  ///
  /// Three kinds of value reach here and only one is an upload:
  ///
  ///  * `https://…`          — a legacy Firebase Storage URL, kept verbatim so
  ///                           bookings saved before the migration still
  ///                           render.
  ///  * a known object key   — already in storage: an `event_images/…` key
  ///                           this app uploaded earlier, or the
  ///                           `subcategory_images/…` default carried in from
  ///                           the template screens. Stored as-is; the
  ///                           resolver signs whichever endpoint owns it.
  ///  * anything else        — a local file path from the picker.
  @visibleForTesting
  Future<String> storedImageRef(String imagePath) async {
    if (imagePath.startsWith('http')) return imagePath;

    // Any folder the Media API already stores objects under is a reference,
    // not a file to upload. Checking only `event_images/` meant the default
    // picture — a `subcategory_images/...` key carried in from the template
    // screens — was handed to File.readAsBytes, which threw and stopped the
    // booking being written at all.
    if (isMediaObjectKey(imagePath)) return imagePath;

    return uploadImage(File(imagePath));
  }

  Future<void> updateIsValidField(String uid, String documentId,
      {required bool isConfirm}) async {
    try {
      CollectionReference eventDetailsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('events');
      await eventDetailsRef.doc(documentId).update({'isValid': isConfirm});
      print('IsValid Field updated successfully');
    } catch (e) {
      print('Error update isValid field');
      throw Exception('Failed to update IsValid Field');
    }
  }
}
