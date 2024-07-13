part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardEvent {}

class TabChanged extends DashboardEvent {
  final int newIndex;
  TabChanged(this.newIndex);
}

class SearchTermChanged extends DashboardEvent {
  final String searTerm;

  SearchTermChanged(this.searTerm);
}
