import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'manage_event.dart';
part 'manage_state.dart';

class ManageBloc extends Bloc<ManageEvent, ManageState> {
  ManageBloc() : super(ManageInitial()) {
    on<SplashEventStatus>(checkLogin);
  }

  FutureOr<void> checkLogin(
      SplashEventStatus event, Emitter<ManageState> emit) async {
    await Future.delayed(Duration(seconds: 2));
    emit(NavigateToWelcomeScreen());
  }
}
