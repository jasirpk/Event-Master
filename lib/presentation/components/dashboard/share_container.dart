import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:flutter/material.dart';

class ShareContainerWidget extends StatelessWidget {
  const ShareContainerWidget({
    super.key,
    required this.screenHeight,
  });

  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: screenHeight * 0.06,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            gradient: LinearGradient(
              colors: [
                Colors.white,
                myColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: myColor,
                ),
                child: Center(
                  child: Icon(
                    Icons.share,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
              Text(
                Assigns.shareApp,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              )
            ],
          ),
        ),
      ),
    );
  }
}
