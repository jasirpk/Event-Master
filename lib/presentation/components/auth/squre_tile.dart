import 'package:flutter/material.dart';

class SqureTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onpressed;

  const SqureTile(
      {super.key,
      required this.imagePath,
      required this.title,
      required this.onpressed});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onpressed,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[200]),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              height: 40,
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            )
          ],
        ),
      ),
    );
  }
}
