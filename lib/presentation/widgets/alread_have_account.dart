import 'package:event_master/common/style.dart';
import 'package:flutter/material.dart';

class AlreadyHaveAccount extends StatelessWidget {
  final VoidCallback onpressed;

  const AlreadyHaveAccount({super.key, required this.onpressed});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: TextStyle(fontSize: 16, fontFamily: 'JacquesFracois'),
        ),
        SizedBox(width: 4),
        InkWell(
          onTap: onpressed,
          child: Text(
            'Login',
            style: TextStyle(
                fontSize: 16, color: myColor, fontFamily: 'JacquesFracois'),
          ),
        ),
      ],
    );
  }
}
