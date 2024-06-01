import 'package:flutter/material.dart';

class BackArrowButton extends StatelessWidget {
  final VoidCallback onpressed;

  const BackArrowButton({super.key, required this.onpressed});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 18, top: 40),
      child: IconButton(
          onPressed: onpressed,
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          )),
    );
  }
}
