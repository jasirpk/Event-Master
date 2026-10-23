import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/bussiness_layer.dart/repos/snack_bar.dart';
import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/data_layer/services/medias.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_media.dart';
import 'package:event_master/presentation/pages/dashboard/media_scalable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:event_master/presentation/components/media/media_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

/// Width the grid decodes thumbnails at.
///
/// Three columns on a large phone is about 400 device pixels per tile; the
/// full-screen viewer still uses the original so zooming stays sharp.
const int _thumbnailDecodeWidth = 400;

class MediaScreen extends StatelessWidget {
  const MediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    MediaMethods mediaMethods = MediaMethods();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return SafeArea(
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          List<File> images = [];
          if (state is DashboardInitial && state.pickImages != null) {
            images = state.pickImages!;
          }

          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.read<DashboardBloc>().add(PickImagesEvent());
              },
              child: Icon(
                Icons.add,
              ),
            ),
            appBar: AppBar(
              backgroundColor: Colors.black,
              actions: [
                TextButton(
                  onPressed: () async {
                    await _saveImages(images, uid);
                  },
                  child: Row(
                    children: [
                      Text(
                        'Save',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: screenHeight * 0.018),
                      ),
                      Icon(
                        Icons.save,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
              leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(
                  CupertinoIcons.back,
                  color: Colors.white,
                ),
              ),
              title: Text(
                'Gallery',
                style: TextStyle(
                  fontFamily: 'JacquesFrancois',
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: mediaMethods.getImages(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ShimmerMediaItem(
                      screenHeight: screenHeight, screenWidth: screenWidth);
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Lottie.asset(
                      'assets/images/Animation - 1721975522807.json',
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.2,
                    ),
                  );
                }

                var documents = snapshot.data!.docs;
                return MasonryGridView.count(
                  crossAxisCount: 3,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    var document = documents[index];
                    var data = document.data() as Map<String, dynamic>;
                    var imageUrl = data['url'];
                    var imageId = documents[index].id;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImageView(
                              imageUrls: documents
                                  .map((doc) => (doc.data()
                                      as Map<String, dynamic>)['url'] as String)
                                  .toList(),
                              initialIndex: index,
                              uid: uid,
                              imageId: imageId,
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'imageHero_$index',
                        // A gallery value is an R2 object key now, which
                        // Image.network cannot fetch: MediaImage asks the
                        // Media API to sign it, and still renders a legacy
                        // https:// value from the Storage era directly.
                        child: MediaImage(
                          imagePath: imageUrl,
                          builder: (context, image) {
                            if (image == null) {
                              return ShimmerMediaItem(
                                  screenHeight: screenHeight,
                                  screenWidth: screenWidth);
                            }

                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                // A tile in this three-column grid is roughly
                                // 400 device pixels wide, but these are phone
                                // photographs: decoding one at 4000px costs
                                // ~48 MB of image cache, so a handful of them
                                // evict each other and every scroll re-decodes.
                                // Decoding to tile size keeps the same bytes on
                                // the wire but cuts the cache cost ~75x.
                                child: Image(
                                  image: ResizeImage(
                                    image,
                                    width: _thumbnailDecodeWidth,
                                    allowUpscaling: false,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveImages(List<File> images, String uid) async {
    if (images.isEmpty) {
      showCustomSnackBar('Nothing to save', 'Choose an image first.');
      return;
    }

    final result = await MediaMethods().addImages(images: images, uid: uid);

    // Reports what actually happened. This used to say "Images Uploaded"
    // regardless, so a save in which every upload failed looked successful
    // and left the gallery empty with nothing to explain it.
    if (result.allSaved) {
      showCustomSnackBar(
        'Saved',
        images.length == 1
            ? 'Image added to your gallery.'
            : '${result.saved} images added to your gallery.',
      );
      return;
    }

    if (result.partiallyFailed) {
      showCustomSnackBar(
        'Partly saved',
        '${result.saved} added, ${result.failed} could not be uploaded '
            '(${result.reason}). The ones that failed were not saved.',
      );
      return;
    }

    showCustomSnackBar(
      'Not saved',
      'None of your images could be uploaded (${result.reason}). '
          'Nothing was added to your gallery.',
    );
  }
}
