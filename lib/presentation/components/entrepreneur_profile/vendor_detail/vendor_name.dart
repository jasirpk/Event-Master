import 'package:event_master/common/assigns.dart';
import 'package:flutter/material.dart';

class VendorNameWidget extends StatelessWidget {
  const VendorNameWidget({
    super.key,
    required this.screenWidth,
    required this.vendorName,
  });

  final double screenWidth;
  final String vendorName;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: Assigns.vendorName,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: screenWidth * 0.038,
            ),
          ),
          TextSpan(
            text: '  ',
          ),
          TextSpan(
            text: vendorName,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: screenWidth * 0.040,
            ),
          ),
        ],
      ),
    );
  }
}
