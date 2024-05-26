import 'package:event_master/logic/bloc/manage_bloc.dart';
import 'package:event_master/presentation/pages/welcome_pages/welcome_intro_evernt_track.dart';
import 'package:event_master/presentation/widgets/welcome_user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ManageBloc>().add(SplashEventStatus());
    return Scaffold(
      body: BlocListener<ManageBloc, ManageState>(
        listener: (context, state) {
          if (state is NavigateToWelcomeScreen) {
            Get.off(() => WelcomeUserWidget(
                image: 'assets/images/welcome_img1.webp',
                title: 'Welcome to\nEvent Master',
                subTitle:
                    '''Your all-in-one solution for seamless event planning. Let's create unforgettable moments together''',
                onpressed: () {
                  Get.to(() => WelcomeIntroEverntTrack());
                },
                buttonText: 'Get Started'));
          }
        },
        child: BlocBuilder<ManageBloc, ManageState>(
          builder: (context, state) {
            if (state is ManageInitial) {
              return Center(
                child: Lottie.asset(
                    'assets/images/Animation - 1716651896239.json',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.contain),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
