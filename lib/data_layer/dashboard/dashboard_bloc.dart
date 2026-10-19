import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:event_master/bussiness_layer.dart/repos/location.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  List<Map<String, dynamic>> selectedVendors = [];
  DashboardBloc()
      : super(DashboardInitial(
            pickImage: null, pickLocation: '', pickImages: null)) {
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
    on<PickImagesEvent>(pickImagesEvent);
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
        print('Image Picked successfully');
        final File updatedImage = File(image.path);
        emit(DashboardInitial(
          pickImage: updatedImage,
          pickLocation: (state is DashboardInitial)
              ? (state as DashboardInitial).pickLocation
              : '',
        ));
        print('State updated with new image path: ${updatedImage.path}');
      } else {
        print('Image picking failed, no image selected.');
      }
    } catch (e) {
      print('Image picking failed, no image selected. $e');
    }
  }

  FutureOr<void> fetchLocation(
      FetchLocation event, Emitter<DashboardState> emit) async {
    emit(LocationFetchLoading());
    try {
      // Services off: report it and stop. Opening the Settings app from here
      // threw the user out of a half-filled form without being asked.
      if (!await Geolocator.isLocationServiceEnabled()) {
        emit(LocationFetchFailed(
          'Location services are turned off. Turn them on, or type the '
          'location instead.',
        ));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      // Asked once, on an explicit tap. Never in a loop.
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        emit(LocationFetchFailed(
          'Location access is off for Event Master. You can allow it in '
          'Settings, or type the location instead.',
          permanentlyDenied: true,
        ));
        return;
      }

      // Every remaining refusal. Previously execution simply fell through to
      // getCurrentPosition(), which threw, and the catch below swallowed it
      // while leaving the spinner up.
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        emit(LocationFetchFailed(
          'Location permission was declined. You can type the location '
          'instead.',
        ));
        return;
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
          pickImage: null,
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
      // The device can refuse a fix even with permission granted — no signal,
      // airplane mode, a simulator with no location set. The message stays
      // generic: the plugin's own text is not written for users.
      emit(LocationFetchFailed(
        'Could not get your current location. You can type it instead.',
      ));
    }
  }

  FutureOr<void> pickImagesEvent(
      PickImagesEvent event, Emitter<DashboardState> emit) async {
    final picker = ImagePicker();
    try {
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        print('Images picker successfully');
        final List<File> updateImages =
            images.map((image) => File(image.path)).toList();
        emit(DashboardInitial(
          pickImages: updateImages,
          pickImage: null,
          pickLocation: (state is DashboardInitial)
              ? (state as DashboardInitial).pickLocation
              : '',
        ));
        print(
            'State updated with new images paths: ${updateImages.map((image) => image.path)}');
      } else {
        print('Image picking failed, no images selected.');
      }
    } catch (e) {
      print('Image picking failed, no images selected. $e');
    }
  }

  FutureOr<void> clearImageHandler(
      ClearImage event, Emitter<DashboardState> emit) {
    emit(DashboardInitial(
      pickImage: null,
      pickLocation: '',
      pickImages: null,
    ));
  }
}
