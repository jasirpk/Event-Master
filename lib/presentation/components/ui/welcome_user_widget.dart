import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/pages/auth/login.dart';
import 'package:event_master/presentation/components/ui/back_arrow_button.dart';
import 'package:event_master/presentation/components/ui/pushable_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WelcomeUserWidget extends StatelessWidget {
  final String image;
  final String title;
  final String buttonText;
  final String subTitle;
  final VoidCallback onpressed;
  final VoidCallback backButtonPressed;

  const WelcomeUserWidget(
      {super.key,
      required this.image,
      required this.title,
      required this.subTitle,
      required this.onpressed,
      required this.buttonText,
      required this.backButtonPressed});
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
            onpressed: backButtonPressed,
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
                PushableButton_Widget(
                    buttonText: buttonText, onpressed: onpressed),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: TextButton(
                      onPressed: () {
                        Get.to(() => GoogleAuthScreen());
                      },
                      child: Text(
                        'Not now',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1),
                      )),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
