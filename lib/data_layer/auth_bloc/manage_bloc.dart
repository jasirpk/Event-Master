import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart' hide Transition;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_master/bussiness_layer.dart/entities/user_data.dart';
import 'package:event_master/presentation/pages/onboarding/welcome_intro_evernt_track.dart';
import 'package:event_master/presentation/pages/dashboard/home.dart';
import 'package:event_master/presentation/components/ui/welcome_user_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
      emit(AuthLoading(true));
      try {
        final UserCredential = await auth.signInWithEmailAndPassword(email: event.email, password: event.password);
        final user = UserCredential.user!;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        String platform = userDoc['platform'];
        if (platform == 'mobile') {
          await saveAuthState(user.uid, user.email!);
          print('Account is authenticated');
          emit(Authenticated(UserModel(email: user.email!, password: '', uid: user.uid)));
        } else {
          emit(AuthenticatedErrors(message: 'Not Authenticated for this platform'));
          print('Authentication Failed: Not Authenticated for this platform');
        }
      } catch (e) {
        emit(AuthenticatedErrors(message: e.toString()));
        print('Authentication Failed $e');
      }
    });

    // SiguUp...!

    on<SignUp>((event, emit) async {
      emit(AuthLoading(true));
      try {
        final UserCredential =
            await auth.createUserWithEmailAndPassword(email: event.userModel.email.toString(), password: event.userModel.password.toString());
        final user = UserCredential.user;
        if (user != null) {
          // Account bookkeeping only. The password is never persisted: Firebase
          // Auth already holds the credential, and nothing in any of the three
          // apps ever reads it back from Firestore.
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({'uid': user.uid, 'email': user.email, 'platform': 'mobile', 'createdAt': DateTime.now()},SetOptions(merge: true));

          await saveAuthState(user.uid, user.email!);
          log('Account is authenticated');
          log('Current FirebaseAuth user UID: ${user.uid}');
          log('Current FirebaseAuth user Email: ${user.email}');
          emit(Authenticated(UserModel(email: user.email!, password: '', uid: user.uid)));
        } else {
          emit(UnAuthenticated());
        }
      } catch (e) {
        emit(AuthenticatedErrors(message: e.toString()));
        log(('Authentication Failed $e'));
      }
    });

    // checUserProfile...!

    on<CheckUserEvent>((event, emit) async {
      emit(AuthLoading(true));

      // Firebase Auth is the source of truth, not SharedPreferences: the two
      // can disagree — a revoked or expired session leaves a stale `uid` in
      // prefs, and the app would then route to HomeScreen with no signed-in
      // user, so every `currentUser!` below it throws.
      //
      // authStateChanges().first resolves as soon as Firebase has restored the
      // persisted session, or confirmed there is none. The splash delay runs
      // alongside it rather than before it, so the wait is whichever takes
      // longer — never the sum, and never a guess that Firebase is ready.
      final results = await Future.wait([
        auth.authStateChanges().first,
        Future.delayed(const Duration(seconds: 2)),
      ]);
      final user = results.first as User?;

      if (user != null) {
        print('Session restored from FirebaseAuth');
        // Keep prefs in step with the session that actually exists.
        await saveAuthState(user.uid, user.email ?? '');
        Get.offAll(() => HomeScreen());
        emit(Authenticated(
            UserModel(uid: user.uid, email: user.email, password: '')));
      } else {
        print('No active FirebaseAuth session');
        // Drop any stale uid/email so nothing downstream trusts them.
        await clearAuthState();
        emit(UnAuthenticated());
        Get.offAll(() => WelcomeUserWidget(
            image: 'assets/images/welcome_img1.webp',
            title: 'Welcome to Event Master',
            subTitle: '''Your all-in-one solution for seamless event planning. Let's create unforgettable moments together''',
            onpressed: () {
              Get.to(
                    () => WelcomeIntroEverntTrack(),
                transition: Transition.rightToLeft,
              );
            },
            buttonText: 'Get Started',
            backButtonPressed: () {
              Get.back();
            }));
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

// Google Authentication...!

    on<GoogleAuth>((event, emit) async {
      emit(AuthLoading(true));

      try {
        final GoogleSignIn googleSignIn = GoogleSignIn.instance;

        await googleSignIn.initialize();

        final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        final user = userCredential.user;

        if (user != null) {
          await saveAuthState(user.uid, user.email ?? '');

          emit(
            Authenticated(
              UserModel(uid: user.uid, email: user.email, password: ''),
            ),
          );
        }
      } catch (e) {
        emit(
          AuthenticatedErrors(message: e.toString()),
        );

        log(e.toString());
      }
    });

// Google SignOUt...!
    on<SignOutWithGoogle>((event, emit) async {
      try {
        await GoogleSignIn.instance.signOut();
        clearAuthState();
      } catch (e) {
        emit(AuthenticatedErrors(message: e.toString()));
      }
    });

// .....................Validation............!

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

  FutureOr<void> validateTextField(TextFieldTextchanged event, Emitter<ManageState> emit) {
    try {
      emit(isValidEmail(event.text) ? TextValid() : TextInvalid(message: 'Enter Valid Email'));
    } catch (e) {
      emit(AuthenticatedErrors(message: e.toString()));
    }
  }

  bool isValidEmail(String text) {
    return text.isNotEmpty && text.contains('@gmail.com');
  }

  FutureOr<void> validatePasswordField(TextFieldPasswordChanged event, Emitter<ManageState> emit) {
    try {
      emit(isValidPassword(event.password) ? PasswordValid() : PasswordInvalid(message: 'Enter Valid Password'));
    } catch (e) {
      emit(AuthenticatedErrors(message: e.toString()));
    }
  }

  bool isValidPassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }

  FutureOr<void> togglePasswordVisibility(TogglePasswordVisibility event, Emitter<ManageState> emit) {
    isPasswordVisible = !isPasswordVisible;
    emit(PasswordvisiblityToggled(isVisible: isPasswordVisible));
  }
}
