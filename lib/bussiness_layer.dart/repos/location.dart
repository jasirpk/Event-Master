import 'package:geocoding/geocoding.dart';

// Helper function to fetch location name using reverse geocoding
Future<String> getLocationName(double latitude, double longitude) async {
  try {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      return '${placemarks.first.locality}, ${placemarks.first.country}';
    } else {
      return 'Unknown location';
    }
  } catch (e) {
    return 'Location not available';
  }
}
