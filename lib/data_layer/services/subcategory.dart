import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class subDatabaseMethods {
  Stream<QuerySnapshot> getSubcategories(String categoryId) {
    return FirebaseFirestore.instance
        .collection('Categories')
        .doc(categoryId)
        .collection('SubCategories')
        .snapshots();
  }

  Future<DocumentSnapshot> getSubCategoryId(
      String categoryId, String subCategoryId) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Categories')
          .doc(categoryId)
          .collection('SubCategories')
          .doc(subCategoryId)
          .get();
      return docSnapshot;
    } catch (e) {
      log('Error fetching sub-category detail by ID: $e');
      rethrow;
    }
  }
}
