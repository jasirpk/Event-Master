import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:event_master/bussiness_layer.dart/location.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  List<Map<String, dynamic>> selectedVendors = [];
  DashboardBloc()
      : super(DashboardInitial(
          pickImage: null,
          pickLocation: '',
        )) {
    on<SearchTermChanged>(searchterm);
    on<ChangeColorTheme>(changeColorTheme);
    on<SelectedVendor>(selectedVendor);
    on<DeselectVendor>(deselectedVendor);
    on<ClearSelectedVendors>(clearSelectdVendors);
    on<TabChanged>((event, emit) {
      emit(TabState(event.newIndex));
    });
    on<PickImageEvent>(pickImageEventHandler);
    on<ClearImage>(clearImageHandler);
    on<FetchLocation>(fetchLocation);
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

  FutureOr<void> changeColorTheme(
      ChangeColorTheme event, Emitter<DashboardState> emit) {
    emit(ColorThemeChanged(event.newColor));
  }

  FutureOr<void> selectedVendor(
      SelectedVendor event, Emitter<DashboardState> emit) {
    if (state is VendorSelectionState) {
      final currentState = state as VendorSelectionState;
      final updatedVendors =
          List<Map<String, dynamic>>.from(currentState.selectedVendors)
            ..add(event.vendorDetail);
      emit(VendorSelectionState(selectedVendors: updatedVendors));
    } else {
      emit(VendorSelectionState(selectedVendors: [event.vendorDetail]));
    }
  }

  FutureOr<void> deselectedVendor(
      DeselectVendor event, Emitter<DashboardState> emit) {
    if (state is VendorSelectionState) {
      final currentState = state as VendorSelectionState;
      final updatedVendors =
          List<Map<String, dynamic>>.from(currentState.selectedVendors)
            ..removeWhere((vendor) => vendor['uid'] == event.vendorId);
      emit(VendorSelectionState(selectedVendors: updatedVendors));
    }
  }

  FutureOr<void> clearSelectdVendors(
      ClearSelectedVendors event, Emitter<DashboardState> emit) {
    emit(VendorSelectionState(selectedVendors: []));
  }

  FutureOr<void> pickImageEventHandler(
      PickImageEvent event, Emitter<DashboardState> emit) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print('image Picked successfully');
        final File updatedImage = File(image.path);
        if (state is DashboardInitial) {
          emit((state as DashboardInitial).copyWith(pickImage: updatedImage));
        } else {
          emit(DashboardInitial(
              pickImage: updatedImage,
              pickLocation: (state as DashboardInitial).pickLocation));
        }
        print('State updated with new image path: ${updatedImage.path}');
      } else {
        print('Image picking failed, no image selected.');
      }
    } catch (e) {
      print('Image picking failed, no image selected.$e');
    }
  }

  FutureOr<void> fetchLocation(
      FetchLocation event, Emitter<DashboardState> emit) async {
    emit(LocationFetchLoading());
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await Geolocator.openLocationSettings();
        if (!serviceEnabled) {
          print('Location services are disabled.');
          return;
        }
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied.');
      }

      final position = await Geolocator.getCurrentPosition();
      String locationName =
          await getLocationName(position.latitude, position.longitude);

      // Handle different types of states
      if (state is DashboardInitial) {
        emit(DashboardInitial(
          pickImage: (state as DashboardInitial).pickImage,
          pickLocation: locationName,
        ));
      } else if (state is VendorSelectionState) {
        emit(DashboardInitial(
          pickImage: null, // or maintain previous image state if needed
          pickLocation: locationName,
        ));
      } else {
        // Handle other possible states or fallback
        emit(DashboardInitial(
          pickImage: null,
          pickLocation: locationName,
        ));
      }
    } catch (e) {
      print("Error Occurred $e");
    }
  }

  FutureOr<void> clearImageHandler(
      ClearImage event, Emitter<DashboardState> emit) {
    emit(DashboardInitial(pickImage: null, pickLocation: ''));
  }
}
