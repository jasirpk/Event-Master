import 'package:flutter/material.dart';

class BackArrowButton extends StatelessWidget {
  final VoidCallback onpressed;

  const BackArrowButton({super.key, required this.onpressed});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: IconButton(
              onPressed: onpressed,
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
        ),
      ],
    );
  }
}
