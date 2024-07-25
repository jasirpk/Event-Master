import 'package:event_master/common/assigns.dart';
import 'package:event_master/data_layer/auth_bloc/manage_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class MenuButtonWidget extends StatelessWidget {
  const MenuButtonWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        color: Colors.white,
        iconColor: Colors.white,
        onSelected: (value) {
          if (value == 'logout') {
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
                  context.read<ManageBloc>().add(Logout());
                  context.read<ManageBloc>().add(SignOutWithGoogle());
                  context.read<ManageBloc>().add(SignOutWithFacebook());
                });
          }
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              child: Text(Assigns.terms),
              value: 'terms',
            ),
            PopupMenuItem(
              child: Text(Assigns.privacy),
              value: 'privacy',
            ),
            PopupMenuItem(
              child: Text(Assigns.logout),
              value: 'logout',
            ),
          ];
        });
  }
}
