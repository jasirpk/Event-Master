import 'dart:ui';

import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/forgot_password.dart';
import 'package:event_master/presentation/components/ui/back_arrow_button.dart';
import 'package:event_master/presentation/components/ui/pushable_button.dart';
import 'package:event_master/presentation/components/auth/text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final formKey = GlobalKey<FormState>();
  final userEmailController = TextEditingController();

  late final ResetPassword resetPassword;

  @override
  void initState() {
    super.initState();
    resetPassword = ResetPassword(controller: userEmailController);
  }

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
                    'Reset Password',
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
                          borderRadius: BorderRadius.circular(30),
                        ),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: Form(
                          key: formKey,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Enter Your valid Email and we will send \nyou a password reset link',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                TextFieldWidget(
                                  Controller: userEmailController,
                                  hintText: 'Email',
                                  obscureText: false,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                PushableButton_Widget(
                                  buttonText: 'Reset',
                                  onpressed: () async {
                                    if (formKey.currentState?.validate() ??
                                        false) {
                                      await resetPassword.sendResetLink();
                                    }
                                  },
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
