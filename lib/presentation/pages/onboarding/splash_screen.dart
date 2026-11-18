import 'package:event_master/data_layer/auth_bloc/manage_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lottie/lottie.dart';

// Mirrored by the native launch screens: android launch_background.xml and the
// iOS LaunchImage asset both draw kSplashLogoAsset centred at kSplashLogoWidth.
// Change one and the logo jumps when Flutter takes over; regenerate the native
// side with `fvm dart run flutter_native_splash:create`.
const String kSplashLogoAsset = 'assets/images/event_master_splash_logo.png';
const String kSplashAnimationAsset =
    'assets/images/Animation - 1716651896239.json';

// 992px in the xxxhdpi bucket and 248pt at iOS 1x both resolve to 248dp.
const double kSplashLogoWidth = 248;

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
          // ManageInitial is included on purpose: it is the state the bloc is
          // built with, so without it the first Flutter frame is an empty
          // Container and the logo the native splash just drew disappears for
          // a frame before AuthLoading arrives.
          if (state is AuthLoading || state is ManageInitial) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Centred exactly as the native launch screen draws it, so the
                // logo does not move when Flutter takes over.
                Center(
                  child: Image.asset(
                    kSplashLogoAsset,
                    width: kSplashLogoWidth,
                    fit: BoxFit.contain,
                  ),
                ),
                // The existing animation, unchanged in asset, size and fit —
                // only moved below the logo, which now occupies the centre.
                Align(
                  alignment: const Alignment(0, 0.6),
                  child: Lottie.asset(
                    kSplashAnimationAsset,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.2,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
