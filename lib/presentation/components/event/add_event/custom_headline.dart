import 'package:event_master/common/style.dart';
import 'package:flutter/material.dart';

class CustomHeadLineTextWidget extends StatelessWidget {
  const CustomHeadLineTextWidget({
    super.key,
    required this.screenHeight,
    required this.text,
  });

  final double screenHeight;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: myColor,
          fontSize: screenHeight * 0.020,
          fontWeight: FontWeight.w500,
          letterSpacing: 1),
    );
  }
}
