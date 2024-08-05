import 'package:event_master/bussiness_layer.dart/repos/snack_bar.dart';
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
  final String? userName;
  final String? phoneNumber;
  final String? imagePath;

  const ProfileFormScreen({
    super.key,
    this.userName,
    this.phoneNumber,
    this.imagePath,
  });
  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  TextEditingController userNameContrller = TextEditingController();
  TextEditingController phoneNumberContrller = TextEditingController();
  File? image;

  @override
  void initState() {
    userNameContrller.text = widget.userName ?? '';
    phoneNumberContrller.text = widget.phoneNumber ?? '';
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
                        fontFamily: 'JacquesFrancois',
                        letterSpacing: 1),
                  ),
                ),
                SizedBox(height: 180),
                BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardInitial) {
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
                            border: Border.all(width: 2, color: Colors.white38),
                            image: image != null
                                ? DecorationImage(
                                    image: FileImage(image!), fit: BoxFit.cover)
                                : widget.imagePath != null
                                    ? DecorationImage(
                                        image: NetworkImage(widget.imagePath!),
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
                          buttonText: 'Submit Details',
                          onpressed: () async {
                            if (userNameContrller.text.isNotEmpty &&
                                phoneNumberContrller.text.length == 10 &&
                                (image != null || widget.imagePath != null)) {
                              var uid = FirebaseAuth.instance.currentUser!.uid;
                              try {
                                String imagePath = image != null
                                    ? image!.path
                                    : widget.imagePath!;
                                await ClientProfile().updateProfile(
                                  isValid: true,
                                  userName: userNameContrller.text,
                                  uid: uid,
                                  imagePath: imagePath,
                                  phoneNumber: phoneNumberContrller.text,
                                );

                                showCustomSnackBar(
                                    'Success', 'Updated successfully');

                                print('User profile updated');
                              } catch (e) {
                                print('Failed to add fields $e');
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text('Failed to add event: $e'),
                                ));
                              }
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                backgroundColor: Colors.red,
                                content:
                                    Text('Please fill all the required fields'),
                              ));
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    userNameContrller.dispose();
    phoneNumberContrller.dispose();
    super.dispose();
  }
}
