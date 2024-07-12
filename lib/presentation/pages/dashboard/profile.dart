import 'package:event_master/data_layer/auth_bloc/manage_bloc.dart';
import 'package:event_master/presentation/pages/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              context.read<ManageBloc>().add(Logout());
              context.read<ManageBloc>().add(SignOutWithGoogle());
              context.read<ManageBloc>().add(SignOutWithFacebook());
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: BlocListener<ManageBloc, ManageState>(
        listener: (context, state) {
          if (state is UnAuthenticated) {
            Get.off(() => GoogleAuthScreen());
          } else if (state is AuthenticatedErrors) {
            Get.snackbar('Logout Error', state.message,
                snackPosition: SnackPosition.BOTTOM);
          }
        },
        child: Center(
          child: Text('Profile Page'),
        ),
      ),
    );
  }
}
