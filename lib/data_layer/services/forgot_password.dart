import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPassword {
  final TextEditingController controller;

  ResetPassword({required this.controller});

  Future<void> sendResetLink() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: controller.text);
      Get.snackbar(
        'Success',
        'Password reset email sent',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      print("Password reset email sent");
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error sending password reset email: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Error sending password reset email: $e");
    }
  }
}
