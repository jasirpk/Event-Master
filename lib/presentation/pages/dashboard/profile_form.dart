import 'package:event_master/bussiness_layer.dart/snack_bar.dart';
import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/data_layer/services/prifile.dart';
import 'package:event_master/presentation/components/event/add_event/custom_textfeild.dart';
import 'package:event_master/presentation/components/ui/back_arrow_button.dart';
import 'package:event_master/presentation/components/ui/pushable_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';

import 'package:get/get.dart';

class ProfileFormScreen extends StatefulWidget {
  final String userName;
  final String phoneNumber;

  const ProfileFormScreen({
    super.key,
    required this.userName,
    required this.phoneNumber,
  });
  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  TextEditingController userNameContrller = TextEditingController();
  TextEditingController phoneNumberContrller = TextEditingController();

  @override
  void initState() {
    userNameContrller.text = widget.userName;
    phoneNumberContrller.text = widget.phoneNumber;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(Assigns.profileBackground),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3), BlendMode.darken))),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BackArrowButton(onpressed: () {
                  Get.back();
                }),
                Padding(
                  padding: const EdgeInsets.only(top: 36),
                  child: Text(
                    Assigns.completeProfile,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.034,
                        fontFamily: 'JacquesFracois',
                        letterSpacing: 1),
                  ),
                ),
                SizedBox(height: 180),
                Container(
                  child: BlocBuilder<DashboardBloc, DashboardState>(
                    builder: (context, state) {
                      File? image;
                      if (state is DashboardInitial &&
                          state.pickImage != null) {
                        image = state.pickImage;
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextFieldWidget(
                            controller: userNameContrller,
                            labelText: 'Name',
                            readOnly: false,
                            prefixIcon: Icons.person,
                          ),
                          sizedbox,
                          CustomTextFieldWidget(
                            controller: phoneNumberContrller,
                            labelText: 'Phone number',
                            readOnly: false,
                            prefixIcon: Icons.call,
                            keyboardType: TextInputType.phone,
                          ),
                          sizedbox,
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(width: 2, color: Colors.white38),
                              image: image != null
                                  ? DecorationImage(
                                      image: FileImage(image),
                                      fit: BoxFit.cover)
                                  : null,
                            ),
                            child: Center(
                              child: IconButton(
                                onPressed: () {
                                  context
                                      .read<DashboardBloc>()
                                      .add(PickImageEvent());
                                },
                                icon: Icon(Icons.collections_bookmark),
                              ),
                            ),
                            width: screenWidth * 0.4,
                            height: screenHeight * 0.16,
                          ),
                          sizedbox,
                          PushableButton_Widget(
                              buttonText: 'Submit Deatails',
                              onpressed: () async {
                                if (userNameContrller.text.isNotEmpty &&
                                    phoneNumberContrller.text.isNotEmpty &&
                                    image != null) {
                                  var uid =
                                      FirebaseAuth.instance.currentUser!.uid;
                                  try {
                                    await ClientProfile().updateProfile(
                                        userName: userNameContrller.text,
                                        uid: uid,
                                        imagePath: image.path,
                                        phoneNumber: phoneNumberContrller.text);

                                    showCustomSnackBar(
                                        'Success', 'updated sucessfully');

                                    print('User profile updated');
                                  } catch (e) {
                                    print('Failded to add fields $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                                'Failed to add event: $e')));
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                              'Please fill all the required fields')));
                                }
                              })
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
