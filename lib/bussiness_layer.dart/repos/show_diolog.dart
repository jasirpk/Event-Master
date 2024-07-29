import 'package:event_master/bussiness_layer.dart/repos/snack_bar.dart';
import 'package:event_master/data_layer/services/create_event.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showDeleteConfirmationDialog({
  required String uid,
  required String documentId,
  required EventBookingMethods eventMethods,
}) {
  Get.defaultDialog(
    title: 'Delete Confirmation',
    middleText: 'Are you sure you want to delete this vendor?',
    textCancel: 'Cancel',
    textConfirm: 'Delete',
    confirmTextColor: Colors.white,
    onCancel: () {
      Get.back();
    },
    onConfirm: () async {
      try {
        await eventMethods.deleteGeneratedEventDetail(uid, documentId);
        Get.back();
        showCustomSnackBar('Success', 'Deleted Succesfully');
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to delete vendor: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    },
  );
}
