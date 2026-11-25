import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/detail/fields.dart';
import 'package:flutter/material.dart';
import 'package:event_master/presentation/components/media/media_image.dart';

/// The entrepreneur's portfolio, three across.
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
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: widget.images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        // Square-ish tiles. The old fixed 130pt extent against a third of the
        // width made portrait boxes on a narrow phone and letterboxes on a
        // wide one.
        childAspectRatio: 1,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final entry = widget.images[index];
        // Portfolio entries are R2 object keys since the profile migration.
        // `image['image'].startsWith(...)` also threw outright when an entry
        // had no 'image' field, so the value is read defensively too.
        final ref = entry['image'];

        return ClipRRect(
          borderRadius: BorderRadius.circular(kRadiusField),
          child: MediaImage(
            imagePath: ref is String ? ref : null,
            placeholder: kMediaPlaceholderImage,
            builder: (context, image) => Container(
              decoration: BoxDecoration(
                // A tile with no image is a surface, not a black hole in the
                // grid — the card behind it is the same colour.
                color: kSurfaceAlt,
                border: Border.all(color: kBorder),
                borderRadius: BorderRadius.circular(kRadiusField),
                image: image == null
                    ? null
                    : DecorationImage(
                        image: image,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
