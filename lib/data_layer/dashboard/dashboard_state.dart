part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardState {}

final class DashboardInitial extends DashboardState {}

class TabState extends DashboardState {
  final int index;
  TabState(this.index);
}
