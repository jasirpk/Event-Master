import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/auth_bloc/manage_bloc.dart';
import 'package:event_master/data_layer/services/prifile.dart';
import 'package:event_master/presentation/components/settings/menu_button.dart';
import 'package:event_master/presentation/pages/auth/login.dart';
import 'package:event_master/presentation/pages/dashboard/privacy_policy.dart';
import 'package:event_master/presentation/pages/dashboard/profile_form.dart';
import 'package:event_master/presentation/pages/dashboard/terms_of_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  late Future<DocumentSnapshot> _userProfileFuture;
  ClientProfile clientProfile = ClientProfile();
  @override
  void initState() {
    _userProfileFuture = clientProfile.getUserProfile(uid);
    super.initState();
  }

  void refresh() {
    setState(() {
      _userProfileFuture = clientProfile.getUserProfile(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    List<Map<String, dynamic>> items = [
      {
        'icon': Icons.share,
        'text': 'Share this App',
        'onTap': () {
          Share.share('https://www.amazon.com/dp/B0DC59TJDZ/ref=apps_sf_sta');
        }
      },
      {
        'icon': Icons.preview,
        'text': 'Privacy Policy',
        'onTap': () {
          Get.to(() => PrivacyPolicy());
        }
      },
      {
        'icon': Icons.info,
        'text': 'Terms of Service',
        'onTap': () {
          Get.to(() => TermsOfService());
        }
      },
      {
        'icon': Icons.logout,
        'text': 'Exit Application',
        'onTap': () {
          Get.defaultDialog(
              title: 'Exit? ⚠️',
              middleText: 'Do you want logout?',
              textCancel: 'Cancel',
              textConfirm: 'Log Out',
              middleTextStyle: TextStyle(color: Colors.black),
              onCancel: () {
                Get.back();
              },
              onConfirm: () {
                Get.offAll(() => GoogleAuthScreen());
                context.read<ManageBloc>().add(Logout());
                context.read<ManageBloc>().add(SignOutWithGoogle());
                // context.read<ManageBloc>().add(SignOutWithFacebook());
              });
        }
      },
    ];
    return BlocListener<ManageBloc, ManageState>(
      listener: (context, state) {
        if (state is UnAuthenticated) {
          Get.off(() => GoogleAuthScreen());
        } else if (state is AuthenticatedErrors) {
          Get.snackbar('Logout Error', state.message,
              snackPosition: SnackPosition.BOTTOM);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: refresh,
            ),
            MenuButtonWidget(),
          ],
        ),
        body: FutureBuilder<DocumentSnapshot>(
          future: _userProfileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData ||
                !snapshot.data!.exists ||
                snapshot.hasError) {
              return Text('No data');
            }
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            String profileImage = userData['imagePath'] ?? '';
            print('Snapshot data: ${snapshot.data}');
            print('User data: ${userData}');
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: CircleAvatar(
                                maxRadius: 60,
                                child: ClipOval(
                                  child: FadeInImage(
                                    placeholder:
                                        AssetImage(Assigns.personImage),
                                    image: profileImage.isNotEmpty
                                        ? NetworkImage(profileImage)
                                        : AssetImage(Assigns.personImage)
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                maxRadius: 20,
                                backgroundColor: Colors.white,
                                child: IconButton(
                                    onPressed: () {
                                      Get.to(() => ProfileFormScreen(
                                            userName: userData['userName'] ??
                                                'No name',
                                            phoneNumber:
                                                userData['phoneNumber'] ??
                                                    '+91',
                                            imagePath: profileImage,
                                          ));
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.black,
                                    )),
                              ),
                            )
                          ],
                        ),
                        sizedBoxWidth,
                        Text(
                          userData['userName'] ?? 'No name',
                          style: TextStyle(
                              fontSize: screenHeight * 0.022,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                    sizedbox,
                    Row(
                      children: [
                        Icon(
                          Icons.call,
                          color: Colors.white,
                        ),
                        sizedBoxWidth,
                        Text(
                          userData['phoneNumber'] ?? '',
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.mail,
                          color: Colors.white,
                        ),
                        sizedBoxWidth,
                        Text(
                          userData['email'] ?? '@',
                        ),
                      ],
                    ),
                    sizedbox,
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        var data = items[index];
                        return GestureDetector(
                          onTap: data['onTap'],
                          child: Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.white38,
                                  borderRadius: BorderRadius.circular(20)),
                              child: ListTile(
                                leading: Icon(
                                  data['icon'],
                                  color: Colors.white,
                                ),
                                title: Text(
                                  data['text'],
                                  style: TextStyle(color: Colors.white),
                                ),
                                trailing: IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      CupertinoIcons.forward,
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    sizedbox,
                    Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Text('Version 1.0.0+2',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
