import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerMediaItem extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;

  const ShimmerMediaItem({
    Key? key,
    required this.screenHeight,
    required this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white24,
      highlightColor: Colors.white,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        height: screenHeight * 0.2,
        width: screenWidth * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
      ),
    );
  }
}
