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
      return FirebaseFirestore.instance.collection('entrepreneurs').snapshots();
    }
    try {
      return FirebaseFirestore.instance
          .collection('entrepreneurs')
          .where('companyName', isGreaterThanOrEqualTo: searchTerm)
          .where('companyName', isLessThanOrEqualTo: searchTerm + '\uf8ff')
          .snapshots();
    } catch (e) {
      print('Error executing qurey $e');
      return Stream.empty();
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
