import 'package:event_master/bussiness_layer.dart/repos/snack_bar.dart';
import 'package:event_master/data_layer/services/notes.dart';
import 'package:flutter/material.dart';

Future<void> updateNote(
    String uid,
    String noteId,
    TextEditingController titleController,
    TextEditingController dateController,
    TextEditingController descriptionController) async {
  if (dateController.text.isNotEmpty &&
      titleController.text.isNotEmpty &&
      descriptionController.text.isNotEmpty) {
    try {
      await NotesMethods().updatenote(
        uid,
        noteId,
        titleController.text,
        dateController.text,
        descriptionController.text,
      );
      showCustomSnackBar('Success', 'note updated successfully');
    } catch (e) {
      showCustomSnackBar('Error', 'Error encountered to note in firebase');
      print('not did not added $e');
    }
  } else {
    showCustomSnackBar('Error', 'please fill all required fields');
  }
}
