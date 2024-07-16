import 'package:flutter/material.dart';

class GuestAndThemeWidget extends StatelessWidget {
  final String headText;
  final String value;
  final double screenWidth;

  const GuestAndThemeWidget(
      {super.key,
      required this.headText,
      required this.value,
      required this.screenWidth});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(headText),
        SizedBox(
          height: 6,
        ),
        Container(
          width: screenWidth * 0.3,
          decoration: BoxDecoration(
              color: Colors.white38, borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                value,
                style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        )
      ],
    );
  }
}
