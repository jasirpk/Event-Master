import 'package:event_master/bussiness_layer.dart/repos/snack_bar.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/profile.dart';
import 'package:event_master/data_layer/services/rating/rating_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            onRatingSubmit: (rating) => submitRating(
              entrepreneurId: uid,
              rating: rating,
            ),
            onLoadUserRating: () => loadUserRating(entrepreneurId: uid),
            onRatingRemove: () => removeRating(entrepreneurId: uid),
          ),
        ),
      ),
    );
  }

  /// Sends the rating to the Media API, which is the only trusted writer of
  /// the rating document and of the entrepreneur's aggregate. The rater's uid
  /// is never sent — the backend takes it from the verified ID token.
  ///
  /// Returns true only when the backend persisted (or already held) the value.
  Future<bool> submitRating({
    required String entrepreneurId,
    required double rating,
  }) async {
    if (FirebaseAuth.instance.currentUser == null) {
      showCustomSnackBar('Sign in required', 'Please sign in to rate.');
      return false;
    }

    final result = await RatingApi().submitRating(
      entrepreneurId: entrepreneurId,
      value: rating,
    );

    showCustomSnackBar(
      result.isSuccess ? 'Rating submitted' : 'Rating not saved',
      result.message,
    );

    return result.isSuccess;
  }

  /// Reads this user's own rating straight from Firestore.
  ///
  /// Reads do not go through the Media API: a rater may read their own rating
  /// document directly, which avoids a round trip and keeps the screen working
  /// the moment it opens. Returns null when signed out or not yet rated.
  Future<double?> loadUserRating({required String entrepreneurId}) async {
    final raterUid = FirebaseAuth.instance.currentUser?.uid;
    if (raterUid == null) return null;

    return UserProfile().fetchMyRating(
      entrepreneurId: entrepreneurId,
      raterUid: raterUid,
    );
  }

  /// Asks the Media API to remove this user's rating. As with submission the
  /// rater's uid is never sent — the backend takes it from the verified token.
  ///
  /// Returns true only when the backend confirmed the rating is gone.
  Future<bool> removeRating({required String entrepreneurId}) async {
    if (FirebaseAuth.instance.currentUser == null) {
      showCustomSnackBar('Sign in required', 'Please sign in to rate.');
      return false;
    }

    final result = await RatingApi().removeRating(
      entrepreneurId: entrepreneurId,
    );

    showCustomSnackBar(
      result.isSuccess ? 'Rating removed' : 'Rating not removed',
      result.message,
    );

    return result.isSuccess;
  }
}
