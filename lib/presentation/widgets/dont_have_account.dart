import 'package:event_master/common/style.dart';
import 'package:flutter/material.dart';

class DontHaveAccount extends StatelessWidget {
  final VoidCallback onpressed;

  const DontHaveAccount({super.key, required this.onpressed});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account?',
          style: TextStyle(fontSize: 16, fontFamily: 'JacquesFracois'),
        ),
        SizedBox(width: 4),
        InkWell(
          onTap: onpressed,
          child: Text(
            'Sign Up',
            style: TextStyle(
                fontSize: 16, color: myColor, fontFamily: 'JacquesFracois'),
          ),
        ),
      ],
    );
  }
}
