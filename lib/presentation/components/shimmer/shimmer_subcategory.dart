import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerSubCategoryItem extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;

  const ShimmerSubCategoryItem({
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
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 18),
        height: screenHeight * 0.12,
        width: screenWidth * 0.46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              height: screenHeight * 0.04,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                color: Colors.grey[300],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
