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

class ChangeColorTheme extends DashboardEvent {
  final Color newColor;

  ChangeColorTheme(this.newColor);
}

class SelectedVendor extends DashboardEvent {
  final Map<String, dynamic> vendorDetail;

  SelectedVendor(this.vendorDetail);
}

class DeselectVendor extends DashboardEvent {
  final String vendorId;

  DeselectVendor(this.vendorId);
}

class ClearSelectedVendors extends DashboardEvent {}

class PickImageEvent extends DashboardEvent {}

class ClearImage extends DashboardEvent {}

class FetchLocation extends DashboardEvent {}

class PickImagesEvent extends DashboardEvent {}
