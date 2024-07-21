import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/detail/fields.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EntrepreneurDetailScreen extends StatelessWidget {
  final String companyName;
  final String about;
  final String phoneNumber;
  final String bussinessEmail;
  final String website;
  final String imagePath;
  final List<Map<String, dynamic>> links;
  final List<Map<String, dynamic>> images;
  final String uid;

  const EntrepreneurDetailScreen({
    super.key,
    required this.companyName,
    required this.about,
    required this.phoneNumber,
    required this.bussinessEmail,
    required this.website,
    required this.imagePath,
    required this.links,
    required this.images,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8), color: myColor),
            child: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                CupertinoIcons.back,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: DetailFieldsWidget(
            imagePath: imagePath,
            companyName: companyName,
            screenHeight: screenHeight,
            about: about,
            phoneNumber: phoneNumber,
            bussinessEmail: bussinessEmail,
            website: website,
            links: links,
            images: images,
            onRatingSubmit: (rating) {
              submitRating(uid, rating);
              print('rating submitted');
            },
          ),
        ),
      ),
    );
  }

  Future<void> submitRating(String uid, double rating) async {
    // Add logic to update the rating in Firestore
    try {
      await FirebaseFirestore.instance
          .collection('entrepreneurs')
          .doc(uid)
          .update({'rating': rating});
      print('Rating updated successfully');
    } catch (e) {
      print('Error updating rating: $e');
    }
  }
}
