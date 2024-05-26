import 'package:event_master/common/style.dart';
import 'package:event_master/logic/bloc/manage_bloc.dart';
import 'package:event_master/presentation/pages/welcome_pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

void main() {
  runApp(BlocProvider(
    create: (context) => ManageBloc(),
    child: EventMaster(),
  ));
}

class EventMaster extends StatelessWidget {
  const EventMaster({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
              textTheme: TextTheme(
                  bodyLarge: TextStyle(color: Colors.white),
                  bodyMedium: TextStyle(color: Colors.white)),
              colorScheme: ColorScheme.fromSeed(seedColor: myColor))
          .copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: SplashScreen(),
    );
  }
}
