import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/entities/user_data.dart';
import 'package:event_master/presentation/pages/onboarding/welcome_intro_evernt_track.dart';
import 'package:event_master/presentation/pages/screens/dashboard.dart';
import 'package:event_master/presentation/widgets/welcome_user_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'manage_event.dart';
part 'manage_state.dart';

class ManageBloc extends Bloc<ManageEvent, ManageState> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isPasswordVisible = false;

  ManageBloc() : super(ManageInitial()) {
    // Login status...!

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final UserCredential = await auth.signInWithEmailAndPassword(
            email: event.email, password: event.password);
        final user = UserCredential.user!;
        await saveAuthState(user.uid, user.email!);
        print('Account is Authenticated');
        emit(Authenticated(
            UserModel(email: user.email!, password: '', uid: user.uid)));
      } catch (e) {
        emit(AuthenticatedErrors(message: 'Not Authenticated'));
        print('Authentication Failed $e');
      }
    });

    // SiguUp...!

    on<SignUp>((event, emit) async {
      emit(AuthLoading());
      try {
        final UserCredential = await auth.createUserWithEmailAndPassword(
            email: event.userModel.email.toString(),
            password: event.userModel.password.toString());
        final user = UserCredential.user;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'uid': user.uid,
            'email': user.email,
            'password': event.userModel.password,
            'createdAt': DateTime.now()
          });
          await saveAuthState(user.uid, user.email!);
          print('Account is authenticated');
          print('Current FirebaseAuth user UID: ${user.uid}');
          print('Current FirebaseAuth user Email: ${user.email}');
          emit(Authenticated(
              UserModel(email: user.email!, password: '', uid: user.uid)));
        } else {
          emit(UnAuthenticated());
        }
      } catch (e) {
        emit(AuthenticatedErrors(message: 'Creating Failed'));
        print(('Authentication Failed $e'));
      }
    });
    on<CheckUserEvent>((event, emit) async {
      emit(AuthLoading());
      await Future.delayed(Duration(seconds: 2));
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      final email = prefs.getString('email');

      print('SharedPreferences UID: $uid');
      print('SharedPreferences Email: $email');

      if (uid != null) {
        print('User found in sharedPreferenc');
        Get.offAll(() => HomeScreen());
        emit(Authenticated(UserModel(uid: uid, email: email, password: '')));
      } else {
        print('User not found in SharedPreferences, checking FirebaseAuth');
        print('User NOt found in FirebaseAuth');

        emit(UnAuthenticated());
        Get.offAll(() => WelcomeUserWidget(
            image: 'assets/images/welcome_img1.webp',
            title: 'Welcome to Event Master',
            subTitle:
                '''Your all-in-one solution for seamless event planning. Let's create unforgettable moments together''',
            onpressed: () {
              WelcomeIntroEverntTrack();
            },
            buttonText: 'Get Started',
            backButtonPressed: () {
              Get.back();
            }));
        emit(UnAuthenticated());
        final user = auth.currentUser;
        if (user != null) {
          print('User Found in FirebaseAuth');
          Get.offAll(() => HomeScreen());
          emit(Authenticated(
              UserModel(uid: user.uid, email: user.email, password: '')));
        } else {
          print('User Not found in FirebaseAuth');
          Get.offAll(() => WelcomeUserWidget(
              image: 'assets/images/welcome_img1.webp',
              title: 'Welcome to Event Master',
              subTitle:
                  '''Your all-in-one solution for seamless event planning. Let's create unforgettable moments together''',
              onpressed: () {
                WelcomeIntroEverntTrack();
              },
              buttonText: 'Get Started',
              backButtonPressed: () {
                Get.back();
              }));
          emit(UnAuthenticated());
        }
      }
    });

// Handle logout...!

    on<Logout>((event, emit) async {
      try {
        await auth.signOut();
        clearAuthState();
        emit(UnAuthenticated());
      } catch (e) {
        emit(AuthenticatedErrors(message: e.toString()));
      }
    });
    on<TextFieldTextchanged>(validateTextField);
    on<TextFieldPasswordChanged>(validatePasswordField);
    on<TogglePasswordVisibility>(togglePasswordVisibility);

    on<AuthenticationErrors>((event, emit) {
      emit(AuthenticatedErrors(message: event.errorMessage));
    });
  }

// User Credential storing in Sharedpreference...!
  Future<void> saveAuthState(String uid, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('email', email);
    log('Saved UID: $uid');
    log('Saved Email: $email');
  }

// User Credential clearing..!

  Future<void> clearAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    await prefs.remove('email');
    log('Cleared UID and Email from SharedPreferences');
  }
  // .....................Validation............!

  FutureOr<void> validateTextField(
      TextFieldTextchanged event, Emitter<ManageState> emit) {
    try {
      emit(isValidEmail(event.text)
          ? TextValid()
          : TextInvalid(message: 'Enter Valid Email'));
    } catch (e) {
      emit(AuthenticatedErrors(message: e.toString()));
    }
  }

  bool isValidEmail(String text) {
    return text.isNotEmpty && text.contains('@gmail.com');
  }

  FutureOr<void> validatePasswordField(
      TextFieldPasswordChanged event, Emitter<ManageState> emit) {
    try {
      emit(isValidPassword(event.password)
          ? PasswordValid()
          : PasswordInvalid(message: 'Enter Valid Password'));
    } catch (e) {
      emit(AuthenticatedErrors(message: e.toString()));
    }
  }

  bool isValidPassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }

  FutureOr<void> togglePasswordVisibility(
      TogglePasswordVisibility event, Emitter<ManageState> emit) {
    isPasswordVisible = !isPasswordVisible;
    emit(PasswordvisiblityToggled(isVisible: isPasswordVisible));
  }
}
