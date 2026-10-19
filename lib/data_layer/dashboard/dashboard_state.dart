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

/// A location lookup that ended without a location.
///
/// Every failure path emits this. Without it the bloc's last state stayed
/// [LocationFetchLoading] for ever, so the spinner the screen shows while
/// locating was never dismissed.
class LocationFetchFailed extends DashboardState {
  LocationFetchFailed(this.message, {this.permanentlyDenied = false});

  /// Safe to show the user.
  final String message;

  /// The user said no and iOS will not ask again, so only the Settings app
  /// can change it. The screen says so; it does not open Settings itself.
  final bool permanentlyDenied;
}
