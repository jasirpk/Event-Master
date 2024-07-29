import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnackBar(String title, String message) {
  Get.snackbar(
    '',
    '',
    titleText: Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
    messageText: Text(
      message,
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
    ),
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.teal,
    borderRadius: 10,
    margin: EdgeInsets.all(10),
    icon: Icon(
      Icons.info,
      color: Colors.white,
    ),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    duration: Duration(seconds: 3),
    isDismissible: true,
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeInBack,
  );
}
