import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/medias.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenImageView extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String uid;
  final String imageId;

  const FullScreenImageView({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
    required this.uid,
    required this.imageId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Get.defaultDialog(
                    title: 'Delete Confirmation⚠️',
                    middleText: 'Are you sure you want to delete this picture?',
                    textCancel: 'Cancel',
                    textConfirm: 'Delete',
                    middleTextStyle: TextStyle(color: Colors.black),
                    cancelTextColor: Colors.black,
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.teal,
                    onCancel: () {
                      Get.back();
                    },
                    onConfirm: () {
                      MediaMethods().deleteImage(uid, imageId);
                      Get.back();
                    });
              },
              icon: Icon(
                Icons.delete,
                color: Colors.white,
              )),
          sizedBoxWidth,
        ],
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: PhotoViewGallery.builder(
        itemCount: imageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrls[index]),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(
                tag: 'imageHero_$index'), // Ensure unique tag
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(
          color: Colors.black,
        ),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}
