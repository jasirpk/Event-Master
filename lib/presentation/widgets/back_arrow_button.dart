import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BackArrowButton extends StatelessWidget {
  BackArrowButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 18, top: 40),
      child: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          )),
    );
  }
}
