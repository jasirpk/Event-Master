part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardState {}

// class DashboardInitial extends DashboardState {
//   final File? pickImage;
//   final String pickLocation;

//   DashboardInitial({required this.pickImage, required this.pickLocation});
// }
class DashboardInitial extends DashboardState {
  final File? pickImage;
  final String pickLocation;

  DashboardInitial({required this.pickImage, required this.pickLocation});

  DashboardInitial copyWith({
    File? pickImage,
    String? pickLocation,
  }) {
    return DashboardInitial(
      pickImage: pickImage ?? this.pickImage,
      pickLocation: pickLocation ?? this.pickLocation,
    );
  }
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
