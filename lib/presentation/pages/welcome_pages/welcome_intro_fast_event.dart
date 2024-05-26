import 'package:event_master/presentation/widgets/welcome_user_widget.dart';
import 'package:event_master/presentation/pages/welcome_pages/welocme_intro_delicious.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeIntroFastEvent extends StatelessWidget {
  const WelcomeIntroFastEvent({super.key});

  @override
  Widget build(BuildContext context) {
    return WelcomeUserWidget(
        image: 'assets/images/1583747992phpzaxKKK.jpeg',
        title: '''Grab all events now only in your hands''',
        subTitle:
            '''Stream is here to help you to find the best events based on your interests''',
        onpressed: () {
          Get.to(() => WelocmeIntroDelicious());
        },
        buttonText: 'Next');
  }
}
