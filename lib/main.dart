import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/data_layer/instant/instant_bloc.dart';
import 'package:event_master/firebase_options.dart';
import 'package:event_master/data_layer/auth_bloc/manage_bloc.dart';
import 'package:event_master/presentation/pages/onboarding/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(EventMaster());
}

class EventMaster extends StatelessWidget {
  const EventMaster({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ManageBloc()),
        BlocProvider(create: (context) => DashboardBloc()),
        BlocProvider(create: (context) => InstantBloc())
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            textTheme: TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white)),
            colorScheme: ColorScheme.fromSeed(
              seedColor: myColor,
            )).copyWith(
          scaffoldBackgroundColor: Colors.black,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
