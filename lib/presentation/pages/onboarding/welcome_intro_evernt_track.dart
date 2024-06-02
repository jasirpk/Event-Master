import 'package:event_master/presentation/pages/onboarding/welcome_intro_fast_event.dart';
import 'package:event_master/presentation/widgets/welcome_user_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeIntroEverntTrack extends StatelessWidget {
  const WelcomeIntroEverntTrack({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WelcomeUserWidget(
        image: 'assets/images/night_near_party.jpg',
        title: '''Gather the best party and event options near you!''',
        subTitle:
            '''Discover top-notch event parties in your area with our curated selection. Find yours now!''',
        onpressed: () {
          Get.to(() => WelcomeIntroFastEvent());
        },
        backButtonPressed: () {
          Get.back();
        },
        buttonText: 'Continue',
      ),
    );
  }
}
