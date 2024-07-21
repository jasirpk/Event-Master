import 'package:event_master/presentation/components/entrepreneur_profile/detail/fields.dart';
import 'package:flutter/material.dart';

class RichTextEmailWidget extends StatelessWidget {
  const RichTextEmailWidget({
    super.key,
    required this.widget,
  });

  final DetailFieldsWidget widget;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
              text: '@',
              style: TextStyle(
                  fontSize: widget.screenHeight * 0.022,
                  fontWeight: FontWeight.bold)),
          TextSpan(text: ' '),
          TextSpan(
            text: widget.bussinessEmail,
            style: TextStyle(
                color: Colors.blue,
                fontSize: widget.screenHeight * 0.018,
                fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}
