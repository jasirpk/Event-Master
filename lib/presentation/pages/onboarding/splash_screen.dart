import 'package:event_master/logic/bloc/manage_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    context.read<ManageBloc>().add(CheckUserEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ManageBloc, ManageState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return Center(
              child: Lottie.asset(
                  'assets/images/Animation - 1716651896239.json',
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.2,
                  fit: BoxFit.contain),
            );
          }
          return Container();
        },
      ),
    );
  }
}
