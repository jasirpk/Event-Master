import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/widgets/back_arrow_button.dart';
import 'package:event_master/presentation/widgets/pushable_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeUserWidget extends StatelessWidget {
  final String image;
  final String title;
  final String buttonText;
  final String subTitle;
  final VoidCallback onpressed;

  const WelcomeUserWidget(
      {super.key,
      required this.image,
      required this.title,
      required this.subTitle,
      required this.onpressed,
      required this.buttonText});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(image), fit: BoxFit.cover),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          BackArrowButton(
            onpressed: () {
              Get.back();
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.black.withOpacity(1),
                Colors.black.withOpacity(0)
              ], begin: Alignment.bottomCenter, end: Alignment.center),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontFamily: 'JacquesFracois'),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    subTitle,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1),
                  ),
                ),
                sizedbox,
                Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: PushableButton_Widget(
                      buttonText: buttonText, onpressed: onpressed),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
