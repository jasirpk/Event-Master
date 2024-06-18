import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:event_master/presentation/components/ui/custom_text.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // final screebWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBarWithDivider(
        title: 'Complete Your Profile',
        actions: [
          CustomText(
              screenHeight: screenHeight, onpressed: () {}, text: 'Skip'),
          sizedBoxWidth,
        ],
      ),
    );
  }
}
