import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/bussiness_layer.dart/repos/snack_bar.dart';
import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/data_layer/services/medias.dart';
import 'package:event_master/presentation/components/shimmer/shimmer_media.dart';
import 'package:event_master/presentation/pages/dashboard/media_scalable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

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
                        child: FutureBuilder(
                          future: _loadImage(imageUrl),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return ShimmerMediaItem(
                                  screenHeight: screenHeight,
                                  screenWidth: screenWidth);
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              );
                            } else {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }
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
    final mediaMethods = MediaMethods();
    await mediaMethods.addImages(images: images, uid: uid);
    showCustomSnackBar('Success', 'Images Uploaded');
  }

  Future<void> _loadImage(String imageUrl) async {
    await precacheImage(NetworkImage(imageUrl), Get.context!);
  }
}
