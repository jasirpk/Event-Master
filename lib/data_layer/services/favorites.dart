import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesMethods {
  Future<void> addFavorite(String uid, String categoryId, String subCategoryId,
      Map<String, dynamic> favorites) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .doc(subCategoryId)
          .set(favorites);
      print('Added to favorites');
    } catch (e) {
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  Future<void> removeFavorite(String uid, String subCategorId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('favorites')
          .doc(subCategorId)
          .delete();
      print('Removed from favorites');
    } catch (e) {
      print('Something Error for removing $e');
      rethrow;
    }
  }

  Stream<DocumentSnapshot> getFavoritesStatus(
      String uid, String subCategoryId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(subCategoryId)
        .snapshots();
  }

  Stream<QuerySnapshot> getFavorites(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots();
  }
}
