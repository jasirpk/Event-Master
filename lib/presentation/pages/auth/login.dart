import 'dart:ui';

import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/widgets/back_arrow_button.dart';
import 'package:event_master/presentation/widgets/dont_have_account.dart';
import 'package:event_master/presentation/widgets/pasword_field.dart';
import 'package:event_master/presentation/widgets/pushable_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final userPasswordController = TextEditingController();
  final userEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/clint_login_background.png',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  BackArrowButton(
                    onpressed: () {
                      Get.back();
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  Text(
                    'Log in',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  sizedbox,
                  ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 5,
                        sigmaY: 5,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(0, 0, 0, 1).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30)),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Form(
                            key: formKey,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 25.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: myColor, width: 2.0),
                                          ),
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundImage: AssetImage(
                                              'assets/images/pkevent.jpeg',
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.03),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'PK Events',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'sample.213@gmail.com',
                                              style: TextStyle(fontSize: 18),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                  PasswordField(
                                    controller: userPasswordController,
                                    hintText: 'Password',
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                  PushableButton_Widget(
                                      buttonText: 'Continue', onpressed: () {}),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                  Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                        color: myColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  DontHaveAccount(
                                    onpressed: () {
                                      Get.back();
                                    },
                                  )
                                ],
                              ),
                            )),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
