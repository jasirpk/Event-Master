import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerAllTemplates extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;

  const ShimmerAllTemplates({
    Key? key,
    required this.screenHeight,
    required this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 14),
      child: Shimmer.fromColors(
        baseColor: Colors.white24,
        highlightColor: Colors.white,
        child: Container(
          height: screenHeight * 0.32,
          width: screenWidth * 0.90,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.white),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white, // Shimmer background color
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Container(
                  color: Colors.grey[300],
                  height: screenHeight * 0.32,
                  width: screenWidth * 0.90,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Container(
                            width: screenWidth * 0.4,
                            height: screenHeight * 0.02,
                            color: Colors.grey[300],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Container(
                            width: screenWidth * 0.2,
                            height: screenHeight * 0.02,
                            color: Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        width: screenWidth * 0.8,
                        height: screenHeight * 0.24,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
