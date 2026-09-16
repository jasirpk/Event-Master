import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  Stream<QuerySnapshot> getUserProfile() {
    return FirebaseFirestore.instance
        .collection('entrepreneurs')
        .where('isValid', isEqualTo: true)
        .snapshots();
  }

  Future<DocumentSnapshot> getUserDetailById(String uid) async {
    try {
      DocumentSnapshot docSanpshot = await FirebaseFirestore.instance
          .collection('entrepreneurs')
          .doc(uid)
          .get();
      return docSanpshot;
    } catch (e) {
      log('Error fetching category detail by ID: $e');
      print('Data Can\'t find in database');
      rethrow;
    }
  }

  Stream<QuerySnapshot> searchEntrepreneurs(String searchTerm) {
    if (searchTerm.isEmpty) {
      return FirebaseFirestore.instance
          .collection('entrepreneurs')
          .where('isValid', isEqualTo: true)
          .snapshots();
    }
    try {
      return FirebaseFirestore.instance
          .collection('entrepreneurs')
          .where('isValid', isEqualTo: true)
          .where('companyName', isGreaterThanOrEqualTo: searchTerm)
          .where('companyName', isLessThanOrEqualTo: searchTerm + '\uf8ff')
          .snapshots();
    } catch (e) {
      print('Error executing qurey $e');
      return Stream.empty();
    }
  }

  /// Reads the signed-in user's own rating for an entrepreneur.
  ///
  /// A direct document read rather than a backend call: a rater may read their
  /// own rating document, so this needs no index, no query and no round trip
  /// through the API. Writes still go through the Media API, which is the only
  /// trusted writer.
  ///
  /// Returns null when the user has not rated yet. A failed read also yields
  /// null, so the UI shows "not rated" rather than a stale value; re-rating
  /// from that state is an update and stays correct.
  Future<double?> fetchMyRating({
    required String entrepreneurId,
    required String raterUid,
  }) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('entrepreneurs')
          .doc(entrepreneurId)
          .collection('ratings')
          .doc(raterUid)
          .get();

      if (!doc.exists) return null;

      final value = doc.data()?['value'];
      return value is num ? value.toDouble() : null;
    } catch (e) {
      log('Error fetching own rating: $e');
      return null;
    }
  }

  Future<double> fetchRating(String documentId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('entrepreneurs')
        .doc(documentId)
        .get();
    if (doc.exists && doc.data() != null && doc['rating'] != null) {
      return doc['rating'];
    }
    return 0.0;
  }
}
