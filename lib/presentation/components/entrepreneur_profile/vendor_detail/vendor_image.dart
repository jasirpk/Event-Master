import 'package:flutter/material.dart';
import 'package:event_master/presentation/components/media/media_image.dart';

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
      // imagePathUrl is an R2 object key since the vendor migration, so it
      // needs signing. AssetImage asked Flutter for a bundled asset named
      // "vendor_images/..." and threw.
      child: MediaImage(
        imagePath: vendorImage,
        placeholder: kMediaPlaceholderImage,
        builder: (context, image) => CircleAvatar(
          backgroundImage: image,
          maxRadius: 60,
        ),
      ),
    );
  }
}
