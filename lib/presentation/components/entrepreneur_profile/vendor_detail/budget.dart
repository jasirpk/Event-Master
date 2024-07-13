import 'package:flutter/material.dart';

class BudgetWidget extends StatelessWidget {
  const BudgetWidget({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.vendorImage,
    required this.budget,
  });

  final double screenHeight;
  final double screenWidth;
  final String vendorImage;
  final Map<String, double> budget;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * 0.2,
      width: screenWidth * 0.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 2, color: Colors.white),
        image: DecorationImage(
            image: vendorImage.startsWith('http')
                ? NetworkImage(vendorImage)
                : AssetImage(vendorImage) as ImageProvider,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.6), BlendMode.color)),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          height: screenHeight * 0.1,
          width: screenWidth * 0.25,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              "${budget['from']}\nto\n${budget['to']}",
              textAlign: TextAlign.center,
              style: TextStyle(
                letterSpacing: 1,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
