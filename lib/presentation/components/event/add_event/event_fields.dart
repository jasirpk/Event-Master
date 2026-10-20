// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'package:event_master/bussiness_layer.dart/repos/snack_bar.dart';
import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/services/booking_submission.dart';
import 'package:event_master/data_layer/services/create_event.dart';
import 'package:event_master/presentation/components/event/add_event/client_details.dart';
import 'package:event_master/presentation/components/event/add_event/custom_headline.dart';
import 'package:event_master/presentation/components/event/add_event/event_type.dart';
import 'package:event_master/presentation/components/event/add_event/selected_vendors.dart';
import 'package:event_master/presentation/components/event/add_event/style_and_theme.dart';
import 'package:event_master/presentation/components/ui/pushable_button.dart';
import 'package:event_master/presentation/pages/dashboard/all_templates.dart';
import 'package:event_master/presentation/pages/dashboard/create_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EventFieldsWidget extends StatefulWidget {
  const EventFieldsWidget({
    super.key,
    required this.screenHeight,
    required this.clientNameController,
    required this.emailController,
    required this.phoneNumberController,
    required this.locationController,
    required this.dateController,
    required this.timeController,
    required this.eventTypeController,
    required this.aboutController,
    required this.imagePath,
    required this.image,
    required this.screenWidth,
    required this.selectedColor,
    required this.guestCountController,
    required this.widget,
    required this.sum,
    required this.EntrepreneurId,
    this.locating = false,
    this.submission,
  });

  final double screenHeight;
  final TextEditingController clientNameController;
  final TextEditingController emailController;
  final TextEditingController phoneNumberController;
  final TextEditingController locationController;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final TextEditingController eventTypeController;
  final TextEditingController aboutController;
  final String? imagePath;
  final File? image;
  final double screenWidth;
  final Color selectedColor;
  final TextEditingController guestCountController;
  final SubmitDetailsScreen widget;
  final double sum;
  final String EntrepreneurId;

  /// A location lookup is in flight.
  final bool locating;

  /// Overridden in tests; defaults to the real save-then-list sequence.
  final BookingSubmission? submission;

  @override
  State<EventFieldsWidget> createState() => _EventFieldsWidgetState();
}

class _EventFieldsWidgetState extends State<EventFieldsWidget> {
  /// Set while the image upload and the Firestore write are running.
  ///
  /// The submit button is replaced by progress for the duration, so a second
  /// tap cannot start a second upload or write a duplicate booking.
  bool _submitting = false;

  /// Saving and listing, in order. Injectable so the ordering can be tested
  /// without Firestore or the network.
  BookingSubmission get _submission => widget.submission ?? BookingSubmission();

  /// Reports a saved booking whose listing has not gone through yet.
  ///
  /// The messenger is captured before the await that leads here: this screen
  /// is replaced on the way out, and the message has to survive that. Retry
  /// re-sends the same [eventId], which the server keys its index row on, so
  /// it can never produce a second booking.
  void _reportPendingListing(
    ScaffoldMessengerState messenger,
    String eventId,
    String reason,
  ) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(seconds: 8),
        backgroundColor: Colors.orange.shade800,
        content: Text(
          'Event saved, but the company has not been notified yet. $reason',
        ),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () async {
            final retried = await _submission.retryListing(eventId);

            if (retried.isListed) {
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(
                  content: Text('The event management company can now see '
                      'this event.'),
                ));
            } else {
              _reportPendingListing(
                  messenger, eventId, retried.listingError ?? '');
            }
          },
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = widget.screenHeight;
    final screenWidth = widget.screenWidth;
    final clientNameController = widget.clientNameController;
    final emailController = widget.emailController;
    final phoneNumberController = widget.phoneNumberController;
    final locationController = widget.locationController;
    final dateController = widget.dateController;
    final timeController = widget.timeController;
    final eventTypeController = widget.eventTypeController;
    final aboutController = widget.aboutController;
    final guestCountController = widget.guestCountController;
    final imagePath = widget.imagePath;
    final image = widget.image;
    final selectedColor = widget.selectedColor;
    final sum = widget.sum;

    // The constructor parameter is itself called `widget` and holds the
    // screen. Inside a State that name is taken, so it is aliased here rather
    // than renamed, which would change every call site.
    final screen = widget.widget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClientDeatailsWidget(
            screenHeight: screenHeight,
            clientNameController: clientNameController,
            emailController: emailController,
            phoneNumberController: phoneNumberController,
            locationController: locationController,
            dateController: dateController,
            timeController: timeController,
            locating: widget.locating),
        SizedBox(height: 16),
        EventTypeWidget(
            screenHeight: screenHeight,
            eventTypeController: eventTypeController,
            aboutController: aboutController,
            imagePath: imagePath,
            image: image,
            screenWidth: screenWidth),
        SizedBox(height: 16),
        StyleAndThemeWidget(
            screenHeight: screenHeight,
            selectedColor: selectedColor,
            guestCountController: guestCountController),
        SizedBox(height: 16),
        CustomHeadLineTextWidget(
            screenHeight: screenHeight, text: Assigns.selectedVendors),
        SelectedVendorsWidget(
            screenHeight: screenHeight,
            widget: screen,
            screenWidth: screenWidth),
        SizedBox(height: 16),
        CustomHeadLineTextWidget(
            screenHeight: screenHeight, text: Assigns.totalAmount),
        SizedBox(height: 16),
        Container(
          height: screenHeight * 0.062,
          width: screenWidth * 0.30,
          decoration: BoxDecoration(
              color: myColor, borderRadius: BorderRadius.circular(10)),
          child: Center(
              child: Text(
            '₹ ${sum}',
            style: TextStyle(
                color: Colors.black,
                fontSize: screenHeight * 0.020,
                fontWeight: FontWeight.w500),
          )),
        ),
        SizedBox(height: 16),
        if (_submitting)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Submitting…'),
              ],
            ),
          )
        else
          PushableButton_Widget(
              buttonText: 'Submit Details',
              onpressed: () async {
                if (_submitting) return;

                EventBookingMethods eventBookingMethods = EventBookingMethods();

                // The picture actually submitted: a file the user picked on
                // this screen, otherwise the template's default image.
                final String effectiveImagePath =
                    image != null ? image.path : (imagePath ?? '');

                // `imagePath != null` was the old check, and it never fired:
                // the field defaults to '' rather than null, so a booking with
                // no picture at all got as far as the upload and failed there
                // with a filesystem error.
                if (effectiveImagePath.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Please choose an image for this event')));
                  return;
                }

                if (clientNameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    phoneNumberController.text.isNotEmpty &&
                    locationController.text.isNotEmpty &&
                    dateController.text.isNotEmpty &&
                    timeController.text.isNotEmpty &&
                    eventTypeController.text.isNotEmpty &&
                    aboutController.text.isNotEmpty &&
                    guestCountController.text.isNotEmpty &&
                    selectedColor != null &&
                    screen.selectedVendors.isNotEmpty) {
                  String clientName = clientNameController.text.trim();
                  String email = emailController.text.trim();
                  String phoneNumber = phoneNumberController.text.trim();
                  String location = locationController.text.trim();
                  String date = dateController.text.trim();
                  String time = timeController.text.trim();
                  String eventType = eventTypeController.text.trim();
                  String eventAbout = aboutController.text.trim();
                  String guestCount = guestCountController.text.trim();
                  String selectedColorTheme =
                      selectedColor.value.toRadixString(16);

                  double sum = 0;
                  for (var vendor in screen.selectedVendors) {
                    sum += vendor['budget']['to'];
                  }

                  setState(() => _submitting = true);

                  // Captured before the awaits: this screen is replaced on the
                  // way out, and the outcome still has to be reported.
                  final messenger = ScaffoldMessenger.of(context);

                  try {
                    final result = await _submission.submit(
                      // The uid is read here rather than earlier: it is
                      // needed only by the save, and resolving it inside the
                      // callback is what guarantees that an unauthenticated
                      // caller never reaches the index endpoint — there is no
                      // booking to list.
                      saveBooking: () {
                        final user = FirebaseAuth.instance.currentUser;

                        if (user == null) {
                          throw Exception(
                              'Please sign in again to submit this event.');
                        }

                        return eventBookingMethods.addEvent(
                          EntrepreneurId: widget.EntrepreneurId,
                          uid: user.uid,
                          clientName: clientName,
                          email: email,
                          phoneNumber: phoneNumber,
                          guestCount: guestCount,
                          location: location,
                          date: date,
                          time: time,
                          eventype: eventType,
                          eventAbout: eventAbout,
                          imagePath: effectiveImagePath,
                          selectedColor: selectedColorTheme,
                          selectedVendors: screen.selectedVendors,
                          sum: sum.toString(),
                        );
                      },
                    );

                    // Saved either way from here on. A listing failure is
                    // reported as exactly that — the booking is never re-made,
                    // and nothing claims the company has it.
                    if (result.isListed) {
                      showCustomSnackBar(
                          'Submitted',
                          'The event management company can now '
                              'see this event.');
                    } else {
                      _reportPendingListing(
                          messenger, result.eventId, result.listingError ?? '');
                    }

                    Get.off(() => AllTemplatesScreen());
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Failed to add event: $e')));
                  } finally {
                    // Get.off disposes this State on success, so the flag is
                    // only worth clearing when the screen is still here.
                    if (mounted) setState(() => _submitting = false);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Please fill all the required fields')));
                }
              })
      ],
    );
  }
}
