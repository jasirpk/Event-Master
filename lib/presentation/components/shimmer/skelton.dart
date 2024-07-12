import 'package:flutter/material.dart';

class Skelton extends StatelessWidget {
  final double? height;
  final double? width;

  const Skelton({this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
