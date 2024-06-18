import 'package:event_master/presentation/pages/auth/login.dart';
import 'package:event_master/presentation/components/ui/welcome_user_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeIntroAmbiance extends StatelessWidget {
  const WelcomeIntroAmbiance({super.key});

  @override
  Widget build(BuildContext context) {
    return WelcomeUserWidget(
        image: 'assets/images/venue_decoration_img.jpg',
        title: 'Ambiance Creators',
        subTitle:
            '''Elevate your event with stunning decor options. Create memorable atmospheres.''',
        onpressed: () {
          Get.to(() => GoogleAuthScreen());
        },
        backButtonPressed: () {
          Get.back();
        },
        buttonText: 'continue');
  }
}
