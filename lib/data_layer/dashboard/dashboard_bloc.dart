import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<SearchTermChanged>(searchterm);
    on<TabChanged>((event, emit) {
      emit(TabState(event.newIndex));
    });
  }

  FutureOr<void> searchterm(
      SearchTermChanged event, Emitter<DashboardState> emit) {
    emit(SearchLoading());
    try {
      final searchTerm = event.searTerm;
      emit(SearchLoaded(searchTerm));
    } catch (e) {
      emit(SearchError('An error occurred while searching.'));
    }
  }
}
