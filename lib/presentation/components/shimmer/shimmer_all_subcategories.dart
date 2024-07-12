import 'package:event_master/presentation/components/shimmer/skelton.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerAllSubcategories extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;

  const ShimmerAllSubcategories({
    Key? key,
    required this.screenHeight,
    required this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.white24,
        highlightColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skelton(height: 120, width: 120),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < 5; i++)
                      Column(
                        children: [
                          Skelton(),
                          SizedBox(height: 10),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
