import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBarWithDivider extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final double dividerThickness;
  final List<Widget>? actions;

  CustomAppBarWithDivider({
    required this.title,
    this.dividerThickness = 1.5,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          actions: actions,
          leading: IconButton(
            icon: Icon(
              CupertinoIcons.back,
              color: Colors.white,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: screenHeight * 0.018,
              fontWeight: FontWeight.w400,
              fontFamily: 'JacquesFrancois',
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.black,
        ),
        Divider(
          thickness: dividerThickness,
          height:
              dividerThickness, // Ensures the divider doesn't take extra vertical space
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + dividerThickness);
}
