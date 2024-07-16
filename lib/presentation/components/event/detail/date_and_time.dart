import 'package:flutter/material.dart';

class DateAndTimeWidget extends StatelessWidget {
  final String TypeText;
  final String value;

  const DateAndTimeWidget(
      {super.key, required this.TypeText, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Text(
            TypeText,
          ),
          SizedBox(width: 6),
          Container(
              decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(4)),
              child: Padding(
                padding: EdgeInsets.all(4.0),
                child: Text(
                  value,
                  style: TextStyle(letterSpacing: 2),
                ),
              )),
        ],
      ),
    );
  }
}
