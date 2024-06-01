import 'package:event_master/common/style.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: myColor,
        actions: [
          IconButton(
            onPressed: () {
              // context.read<ManageBloc>().add(Logout());
              // context.read<ManageBloc>().add(SignOutWithGoogle());
              // context.read<ManageBloc>().add(SignOutWithFacebook());
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Text('Home Page'),
      ),
    );
  }
}
