// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/data_layer/services/create_event.dart';
import 'package:event_master/presentation/components/event/add_event/client_details.dart';
import 'package:event_master/presentation/components/event/add_event/custom_headline.dart';
import 'package:event_master/presentation/components/event/add_event/event_type.dart';
import 'package:event_master/presentation/components/event/add_event/style_and_theme.dart';
import 'package:event_master/presentation/components/ui/pushable_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class EditEventsScreen extends StatefulWidget {
  final String uid;
  final String eventId;
  final String clientName;
  final String clientEmail;
  final String phoneNumber;
  final String location;
  final String eventType;
  final String description;
  final String imagePath;
  final String guests;
  final String amount;
  final String date;
  final String time;

  const EditEventsScreen({
    super.key,
    required this.clientName,
    required this.clientEmail,
    required this.phoneNumber,
    required this.location,
    required this.eventType,
    required this.description,
    required this.imagePath,
    required this.guests,
    required this.amount,
    required this.date,
    required this.time,
    required this.uid,
    required this.eventId,
  });

  @override
  State<EditEventsScreen> createState() => _EditEventsScreenState();
}

class _EditEventsScreenState extends State<EditEventsScreen> {
  TextEditingController clientNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController eventTypeController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  TextEditingController guestCountController = TextEditingController();

  String? imagePath = '';
  dynamic sum = 0;
  File? image;

  @override
  void initState() {
    super.initState();
    eventTypeController.text = widget.eventType;
    aboutController.text = widget.description;
    imagePath = widget.imagePath;
    clientNameController.text = widget.clientName;
    emailController.text = widget.clientEmail;
    phoneNumberController.text = widget.phoneNumber;
    locationController.text = widget.location;
    guestCountController.text = widget.guests;
    sum = widget.amount;
    dateController.text = widget.date;
    timeController.text = widget.time;
  }

  DashboardBloc? generatedBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    generatedBloc = context.read<DashboardBloc>();
  }

  @override
  void dispose() {
    generatedBloc?.add(ClearImage());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Assigns.eventDetail,
          style: TextStyle(color: Colors.white, fontSize: screenHeight * 0.018),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(CupertinoIcons.back, color: Colors.white),
        ),
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is LocationFetchLoading) {
            showDialog(
              context: context,
              builder: (context) => Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
        builder: (context, state) {
          Color selectedColor =
              (state is ColorThemeChanged) ? state.newColor : Colors.blue;
          if (state is DashboardInitial) {
            image = state.pickImage;
          }
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
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
                ),
                SizedBox(height: 16),
                EventTypeWidget(
                  screenHeight: screenHeight,
                  eventTypeController: eventTypeController,
                  aboutController: aboutController,
                  imagePath: imagePath,
                  image: image,
                  screenWidth: screenWidth,
                ),
                SizedBox(height: 16),
                StyleAndThemeWidget(
                  screenHeight: screenHeight,
                  selectedColor: selectedColor,
                  guestCountController: guestCountController,
                ),
                SizedBox(height: 16),
                SizedBox(height: 16),
                CustomHeadLineTextWidget(
                  screenHeight: screenHeight,
                  text: Assigns.totalAmount,
                ),
                SizedBox(height: 16),
                Container(
                  height: screenHeight * 0.062,
                  width: screenWidth * 0.30,
                  decoration: BoxDecoration(
                    color: myColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '₹ $sum',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenHeight * 0.020,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                PushableButton_Widget(
                  buttonText: 'Submit Details',
                  onpressed: () async {
                    // Create an instance of EventBookingMethods
                    EventBookingMethods eventBookingMethods =
                        EventBookingMethods();

                    // Perform form validation
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
                        imagePath != null) {
                      String clientName = clientNameController.text.trim();
                      String email = emailController.text.trim();
                      String phoneNumber = phoneNumberController.text.trim();
                      String location = locationController.text.trim();
                      String date = dateController.text.trim();
                      String time = timeController.text.trim();
                      String eventType = eventTypeController.text.trim();
                      String eventAbout = aboutController.text.trim();
                      String guestCount = guestCountController.text.trim();

                      String? imagePath = this.widget.imagePath;
                      if (image != null) {
                        imagePath = image!.path;
                      }

                      try {
                        await eventBookingMethods.updateEvent(
                            uid: widget.uid,
                            eventId: widget.eventId,
                            clientName: clientName,
                            email: email,
                            phoneNumber: phoneNumber,
                            location: location,
                            date: date,
                            time: time,
                            eventType: eventType,
                            eventAbout: eventAbout,
                            imagePath: imagePath,
                            guestCount: guestCount,
                            sum: sum);

                        Get.back();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Failed to add event: $e')));
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content:
                              Text('Please fill all the required fields')));
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
