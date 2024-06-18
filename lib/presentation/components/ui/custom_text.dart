import 'package:event_master/common/style.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.screenHeight,
    required this.onpressed,
    required this.text,
  });

  final double screenHeight;
  final VoidCallback onpressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onpressed,
          child: Padding(
            padding: EdgeInsets.only(right: 8),
            child: Text(
              text,
              style: TextStyle(
                color: myColor,
                fontSize: screenHeight * 0.016,
                fontWeight: FontWeight.w400,
                fontFamily: 'JacquesFracois',
                decoration: TextDecoration.underline,
                decorationColor: Colors.teal,
                decorationThickness: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
