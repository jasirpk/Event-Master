import 'package:event_master/presentation/components/entrepreneur_profile/detail/fields.dart';
import 'package:flutter/material.dart';
import 'package:event_master/presentation/components/media/media_image.dart';

class MediaWidget extends StatelessWidget {
  const MediaWidget({
    super.key,
    required this.widget,
  });

  final DetailFieldsWidget widget;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.images.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisExtent: 130,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final entry = widget.images[index];
        // Portfolio entries are R2 object keys since the profile migration.
        // `image['image'].startsWith(...)` also threw outright when an entry
        // had no 'image' field, so the value is read defensively too.
        final ref = entry['image'];

        return MediaImage(
          imagePath: ref is String ? ref : null,
          placeholder: kMediaPlaceholderImage,
          builder: (context, image) => Container(
            decoration: BoxDecoration(
              image: image == null
                  ? null
                  : DecorationImage(
                      image: image,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        );
      },
    );
  }
}
