part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardState {}

final class DashboardInitial extends DashboardState {}

class TabState extends DashboardState {
  final int index;
  TabState(this.index);
}

class SearchLoading extends DashboardState {}

class SearchLoaded extends DashboardState {
  final String searchTerm;

  SearchLoaded(this.searchTerm);
}

class SearchError extends DashboardState {
  final String message;

  SearchError(this.message);
}
