import 'package:cloud_firestore/cloud_firestore.dart';

class NotesMethods {
  Future<void> addNotes(
      {required String uid,
      required String title,
      required String date,
      required String description}) async {
    try {
      CollectionReference collectionReference = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notes');
      await collectionReference
          .add({'title': title, 'date': date, 'description': description});
      print('Added note detail to collection notes');
    } catch (e) {
      print('Failded to add new note $e');
    }
  }

  Stream<QuerySnapshot> getNotes(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notes')
        .snapshots();
  }

  Future<DocumentSnapshot?> getNOtesById(String uid, String noteId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notes')
          .doc(noteId)
          .get();
      if (documentSnapshot.exists) {
        return documentSnapshot;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting note  id $e');
      throw Exception('Failed to get document by ID: $e');
    }
  }

  Future<void> deletenote(String uid, String noteId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notes')
          .doc(noteId)
          .delete();
      print('note deleted');
    } catch (e) {
      print('Failed to delete note');
    }
  }

  Future<void> updatenote(
    String uid,
    String noteId,
    String title,
    String date,
    String description,
  ) async {
    try {
      CollectionReference collectionReference = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notes');
      await collectionReference
          .doc(noteId)
          .update({'title': title, 'date': date, 'description': description});
      print('note details updated');
    } catch (e) {
      print('something error to update to note data $e');
    }
  }
}
