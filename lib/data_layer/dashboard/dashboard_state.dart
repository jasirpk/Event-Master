part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardState {}

class DashboardInitial extends DashboardState {
  final File? pickImage;
  final List<File>? pickImages;
  final String pickLocation;
  final int selectedIndex;

  DashboardInitial(
      {required this.pickImage,
      this.pickImages,
      required this.pickLocation,
      this.selectedIndex = 0});
}

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

class ColorThemeChanged extends DashboardState {
  final Color newColor;

  ColorThemeChanged(this.newColor);
}

class VendorSelectionState extends DashboardState {
  final List<Map<String, dynamic>> selectedVendors;

  VendorSelectionState({this.selectedVendors = const []});
}

class LocationFetchLoading extends DashboardState {}
