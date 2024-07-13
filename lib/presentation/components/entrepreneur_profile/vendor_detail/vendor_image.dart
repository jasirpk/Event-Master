import 'package:flutter/material.dart';

class VendorImageWidget extends StatelessWidget {
  const VendorImageWidget({
    super.key,
    required this.vendorImage,
  });

  final String vendorImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: CircleAvatar(
        backgroundImage: vendorImage.startsWith('http')
            ? NetworkImage(vendorImage)
            : AssetImage(vendorImage) as ImageProvider,
        maxRadius: 60,
      ),
    );
  }
}
