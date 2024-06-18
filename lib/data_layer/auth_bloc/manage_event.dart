part of 'manage_bloc.dart';

@immutable
sealed class ManageEvent {}

// check User...!
class CheckUserEvent extends ManageEvent {}

// ...............validation......................!

class LoginEvent extends ManageEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

// signUp...!

class SignUp extends ManageEvent {
  final UserModel userModel;

  SignUp({required this.userModel});
}

// logout...!
class Logout extends ManageEvent {}

// .................Form Validation....................!

// TextField...!

class TextFieldTextchanged extends ManageEvent {
  final String text;
  TextFieldTextchanged({required this.text});
}

// passoword...!

class TextFieldPasswordChanged extends ManageEvent {
  final String password;

  TextFieldPasswordChanged({required this.password});
}

class TogglePasswordVisibility extends ManageEvent {}

// Authenticationerrors...!

class AuthenticationErrors extends ManageEvent {
  final String errorMessage;

  AuthenticationErrors(this.errorMessage);
}

// Google Auth..!

class GoogleAuth extends ManageEvent {}

class SignOutWithGoogle extends ManageEvent {}

// facebook Auth...!

class SignOutWithFacebook extends ManageEvent {}
