import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/data_layer/auth_bloc/manage_bloc.dart';
import 'package:event_master/data_layer/services/prifile.dart';
import 'package:event_master/presentation/components/settings/menu_button.dart';
import 'package:event_master/presentation/components/settings/user_profile.dart';
import 'package:event_master/presentation/pages/auth/login.dart';
import 'package:event_master/presentation/pages/dashboard/privacy_policy.dart';
import 'package:event_master/presentation/pages/dashboard/terms_of_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    List<Map<String, dynamic>> items = [
      {
        'icon': Icons.share,
        'text': 'Share this App',
        'section': 'ABOUT',
        'onTap': () {
          Share.share('https://www.amazon.com/dp/B0DC59TJDZ/ref=apps_sf_sta');
        }
      },
      {
        'icon': Icons.preview,
        'text': 'Privacy Policy',
        'section': 'ABOUT',
        'onTap': () {
          Get.to(() => PrivacyPolicy());
        }
      },
      {
        'icon': Icons.info,
        'text': 'Terms of Service',
        'section': 'ABOUT',
        'onTap': () {
          Get.to(() => TermsOfService());
        }
      },
      {
        'icon': Icons.logout,
        'text': 'Exit Application',
        'section': 'DANGER',
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
                // The dashboard tab lives in DashboardBloc, which is provided above
                // GetMaterialApp and so survives this route replacement. Without a
                // reset it still holds the tab the user logged out from, and the
                // next login lands there instead of Home.
                context.read<DashboardBloc>().add(TabChanged(0));

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

            return UserProfileWidget(userData: userData, items: items);
          },
        ),
      ),
    );
  }
}
