part of 'manage_bloc.dart';

@immutable
sealed class ManageState {}

final class ManageInitial extends ManageState {}

// ..................Authentication...........!
class AuthLoading extends ManageState {}

class Authenticated extends ManageState {
  final UserModel user;

  Authenticated(this.user);
}

class ValidationSuccess extends ManageState {}

class UnAuthenticated extends ManageState {}

class AuthenticatedErrors extends ManageState {
  final String message;

  AuthenticatedErrors({required this.message});
}

// Validation...!

class TextValid extends ManageState {}

class TextInvalid extends ManageState {
  final String message;

  TextInvalid({required this.message});
}

class PasswordValid extends ManageState {}

class PasswordInvalid extends ManageState {
  final String message;

  PasswordInvalid({required this.message});
}

// password Visiblility...!

class PasswordvisiblityToggled extends ManageState {
  final bool isVisible;

  PasswordvisiblityToggled({required this.isVisible});
}
