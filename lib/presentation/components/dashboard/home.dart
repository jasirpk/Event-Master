import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/components/dashboard/share_container.dart';
import 'package:event_master/presentation/components/dashboard/tools_list.dart';
import 'package:event_master/presentation/components/ui/custom_text.dart';
import 'package:event_master/presentation/components/dashboard/listview.dart';
import 'package:event_master/presentation/components/dashboard/stack_appbar.dart';
import 'package:event_master/presentation/pages/dashboard/all_templates.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final List<Map<String, dynamic>> items = [
      {'text': 'Instant Meet', 'icon': Icons.filter_alt},
      {'text': 'Notes', 'icon': Icons.notes},
      {'text': 'Media', 'icon': Icons.collections_bookmark},
      {'text': 'Greetings', 'icon': Icons.monitor_heart_rounded},
    ];
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StackAppBar(screenHeight: screenHeight),
              sizedbox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Event Templates',
                    style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CustomText(
                    screenHeight: screenHeight,
                    onpressed: () {
                      Get.to(() => AllTemplatesScreen(),
                          transition: Transition.fade,
                          duration: Duration(milliseconds: 800));
                    },
                    text: 'View All',
                  ),
                ],
              ),
              sizedbox,
              ListViewWidget(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
              ),
              sizedbox,
              Text(
                'Tools',
                style: TextStyle(
                  fontSize: screenHeight * 0.022,
                  fontWeight: FontWeight.bold,
                ),
              ),
              sizedbox,
              ToolsListWidget(
                  screenHeight: screenHeight,
                  items: items,
                  screenWidth: screenWidth),
              SizedBox(height: 30),
              ShareContainerWidget(screenHeight: screenHeight)
            ],
          ),
        ),
      ),
    );
  }
}
