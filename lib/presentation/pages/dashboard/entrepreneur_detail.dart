import 'package:event_master/bussiness_layer.dart/repos/snack_bar.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/entrepreneur_profile/profile.dart';
import 'package:event_master/data_layer/services/rating/rating_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_master/presentation/components/entrepreneur_profile/detail/fields.dart';
import 'package:event_master/presentation/components/ui/pushable_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// One entrepreneur's public profile.
///
/// The contact fields are nullable because the stored document's are optional:
/// the Media API writes only the keys a save carried, and clearing a website
/// deletes the field. Declaring them non-nullable did not make them present —
/// it only moved the failure to the caller, as a `Null is not a subtype of
/// String` cast at the argument list. Null here means "nothing stored", and
/// the row for it is not drawn.
class EntrepreneurDetailScreen extends StatelessWidget {
  final String companyName;
  final String about;
  final String? phoneNumber;
  final String? bussinessEmail;
  final String? website;
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        // Without this the bar tints itself as content scrolls under it, which
        // on a black scaffold shows up as a grey band that appears mid-scroll.
        scrolledUnderElevation: 0,
        leadingWidth: 56,
        leading: Center(
          // Was a 35x35 turquoise block holding a 48pt-minimum IconButton — a
          // solid accent slab in the corner, with its own touch target
          // overflowing the box it was drawn in. A surface tile with the
          // accent on the glyph reads as navigation rather than as the
          // screen's primary action, and the 40pt box matches the contact
          // rows' icon tiles.
          child: _BackButton(onPressed: Get.back),
        ),
      ),
      body: SafeArea(
        // The bottom inset belongs to the action bar below, not to the scroll
        // view — claiming it here would leave a dead strip above the button.
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
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
      // The booking action, as a real sibling of the scroll view rather than a
      // `Positioned` child stacked on top of it. The Scaffold lays the body out
      // in the space that remains, so the button cannot cover content at any
      // content length, and it stays on screen while the body scrolls.
      bottomNavigationBar: const _BookNowBar(),
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

/// A compact back control, sized to the 40pt tile used elsewhere on the
/// screen. [InkResponse] keeps a comfortable tap radius around it without
/// forcing the drawn box up to 48pt.
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Back',
      button: true,
      child: InkResponse(
        onTap: onPressed,
        radius: 24,
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorder),
          ),
          child: Icon(CupertinoIcons.back, color: myColor, size: 20),
        ),
      ),
    );
  }
}

/// The screen's bottom action area.
///
/// Carries its own top hairline so the bar separates from the content it sits
/// below, and its own [SafeArea] bottom inset — `bottomNavigationBar` does not
/// apply one, so on a device with a home indicator the button would otherwise
/// sit under it.
class _BookNowBar extends StatelessWidget {
  const _BookNowBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: kBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: PushableButton_Widget(
            buttonText: 'Book Now',
            // Unchanged: booking is not wired up on this screen, and wiring it
            // up is not part of a visual pass.
            onpressed: () {},
          ),
        ),
      ),
    );
  }
}
