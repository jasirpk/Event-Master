import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/components/dashboard/category_list.dart';
import 'package:event_master/presentation/components/ui/custom_appbar.dart';
import 'package:event_master/presentation/components/ui/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllTemplatesScreen extends StatelessWidget {
  const AllTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> items = [
      {
        'text': 'Wedding',
        'subText': 'hello',
        'image': 'assets/images/wedding_img_card.jpg'
      },
      {
        'text': 'Wedding',
        'subText': 'hello',
        'image': 'assets/images/wedding_img_card.jpg'
      },
      {
        'text': 'Wedding',
        'subText': 'hello',
        'image': 'assets/images/wedding_img_card.jpg'
      },
    ];
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBarWithDivider(
        title: 'Templates',
        actions: [
          CustomText(
              screenHeight: screenHeight,
              onpressed: () {
                Get.back();
              },
              text: 'Close'),
          sizedBoxWidth
        ],
      ),
      body: CustomScrollView(
        slivers: [
          CategoryListWidget(
              items: items,
              screenHeight: screenHeight,
              screenWidth: screenWidth)
        ],
      ),
    );
  }
}
