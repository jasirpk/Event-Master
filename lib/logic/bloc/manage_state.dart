part of 'manage_bloc.dart';

@immutable
sealed class ManageState {}

final class ManageInitial extends ManageState {}

class NavigateToWelcomeScreen extends ManageState {}
