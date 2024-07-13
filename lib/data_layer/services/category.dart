import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Stream<QuerySnapshot> geCategoryDetail(String Client) {
    return FirebaseFirestore.instance
        .collection('Categories')
        .where('value', isEqualTo: Client)
        .snapshots();
  }

  Future<DocumentSnapshot> getCategoryDetailById(String id) async {
    try {
      DocumentSnapshot docSanpshot = await FirebaseFirestore.instance
          .collection('Categories')
          .doc(id)
          .get();
      return docSanpshot;
    } catch (e) {
      log('Error fetching category detail by ID: $e');
      print('Data Can\'t find in database');
      rethrow;
    }
  }

  Stream<QuerySnapshot> searchcategories(String categoryId, String searchTerm) {
    if (searchTerm.isEmpty) {
      return FirebaseFirestore.instance.collection('Categories').snapshots();
    }

    try {
      return FirebaseFirestore.instance
          .collection('Categories')
          .where('categoryName', isGreaterThanOrEqualTo: searchTerm)
          .where('categoryName', isLessThanOrEqualTo: searchTerm + '\uf8ff')
          .snapshots();
    } catch (e) {
      print('Error executing query: $e');
      return Stream.empty();
    }
  }
}
