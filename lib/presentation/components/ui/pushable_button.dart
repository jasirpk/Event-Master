import 'package:event_master/common/style.dart';
import 'package:flutter/material.dart';
import 'package:pushable_button/pushable_button.dart';

class PushableButton_Widget extends StatelessWidget {
  final String buttonText;
  final VoidCallback onpressed;

  const PushableButton_Widget(
      {super.key, required this.buttonText, required this.onpressed});
  @override
  Widget build(BuildContext context) {
    return PushableButton(
      elevation: 8,
      hslColor: HSLColor.fromColor(myColor),
      height: 50,
      shadow: BoxShadow(),
      onPressed: onpressed,
      child: Text(
        buttonText,
        style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: 1),
      ),
    );
  }
}
