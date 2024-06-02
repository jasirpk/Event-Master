import 'package:event_master/presentation/pages/onboarding/welcome_intro_ambiance.dart';
import 'package:event_master/presentation/widgets/welcome_user_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelocmeIntroDelicious extends StatelessWidget {
  const WelocmeIntroDelicious({super.key});

  @override
  Widget build(BuildContext context) {
    return WelcomeUserWidget(
        image: 'assets/images/welcome_img1.webp',
        title: 'Taste Sensations',
        subTitle:
            '''Delicious cuisines for your special events. Choose from a variety of menus.''',
        onpressed: () {
          Get.to(() => WelcomeIntroAmbiance());
        },
        backButtonPressed: () {
          Get.back();
        },
        buttonText: 'Next');
  }
}
