// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'package:event_master/bussiness_layer.dart/repos/snack_bar.dart';
import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
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

class EventFieldsWidget extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
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
            timeController: timeController),
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
            widget: widget,
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
        PushableButton_Widget(
            buttonText: 'Submit Details',
            onpressed: () async {
              EventBookingMethods eventBookingMethods = EventBookingMethods();

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
                  imagePath != null &&
                  widget.selectedVendors.isNotEmpty) {
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

                String? imagePath = this.imagePath;
                if (image != null) {
                  imagePath = image!.path;
                }

                var user = FirebaseAuth.instance.currentUser;

                double sum = 0;
                for (var vendor in widget.selectedVendors) {
                  sum += vendor['budget']['to'];
                }

                try {
                  await eventBookingMethods.addEvent(
                    EntrepreneurId: widget.EntrepreneurId,
                    isValid: false,
                    uid: user!.uid,
                    clientName: clientName,
                    email: email,
                    phoneNumber: phoneNumber,
                    guestCount: guestCount,
                    location: location,
                    date: date,
                    time: time,
                    eventype: eventType,
                    eventAbout: eventAbout,
                    imagePath: imagePath!,
                    selectedColor: selectedColorTheme,
                    selectedVendors: widget.selectedVendors,
                    sum: sum.toString(),
                  );
                  showCustomSnackBar('Success', 'Event added successfully');
                  Get.off(() => AllTemplatesScreen());
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Failed to add event: $e')));
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
