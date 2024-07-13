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

  Stream<QuerySnapshot> searchSubcategories(
      String categoryId, String searchTerm) {
    if (categoryId.isEmpty || searchTerm.isEmpty) {
      print('categoryId and searchTerm must not be empty');
      return Stream.empty(); // Return an empty stream if parameters are invalid
    }

    try {
      print('Searching for: $searchTerm in category: $categoryId');
      return FirebaseFirestore.instance
          .collection('Categories')
          .doc(categoryId)
          .collection('SubCategories')
          .where('subCategoryName', isGreaterThanOrEqualTo: searchTerm)
          .where('subCategoryName', isLessThanOrEqualTo: searchTerm + '\uf8ff')
          .snapshots();
    } catch (e) {
      print('Error executing query: $e');
      return Stream.empty(); // Return an empty stream on error
    }
  }
}
