import 'package:event_master/presentation/components/entrepreneur_profile/detail/fields.dart';
import 'package:flutter/material.dart';

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
        var image = widget.images[index];
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: image['image'].startsWith('http')
                  ? NetworkImage(image['image'])
                  : AssetImage(image['image']) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
