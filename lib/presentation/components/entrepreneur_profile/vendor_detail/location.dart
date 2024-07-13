import 'package:flutter/material.dart';

class LocationWidget extends StatelessWidget {
  const LocationWidget({
    super.key,
    required this.screenHeight,
    required this.location,
  });

  final double screenHeight;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * 0.2,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: AssetImage('assets/images/location_img.webp'),
          fit: BoxFit.cover,
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            color: Colors.black.withOpacity(0.6),
          ),
          padding: EdgeInsets.only(left: 8, top: 8),
          child: Text(
            location,
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: screenHeight * 0.016,
              letterSpacing: 1,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
