import 'dart:io';
import 'package:event_master/common/assigns.dart';
import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/presentation/components/event/add_event/custom_headline.dart';
import 'package:event_master/presentation/components/event/add_event/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventTypeWidget extends StatelessWidget {
  const EventTypeWidget({
    super.key,
    required this.screenHeight,
    required this.eventTypeController,
    required this.aboutController,
    required this.imagePath,
    required this.image,
    required this.screenWidth,
  });

  final double screenHeight;
  final TextEditingController eventTypeController;
  final TextEditingController aboutController;
  final String? imagePath;
  final File? image;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeadLineTextWidget(
              screenHeight: screenHeight,
              text: Assigns.eventOverview,
            ),
            SizedBox(height: 16),
            CustomTextFieldWidget(
              controller: eventTypeController,
              readOnly: false,
              labelText: 'Event type',
              prefixIcon: Icons.event,
            ),
            SizedBox(height: 16),
            CustomTextFieldWidget(
              controller: aboutController,
              readOnly: false,
              maxLines: 4,
              labelText: 'About',
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey,
                  image: imagePath!.isEmpty
                      ? (image != null
                          ? DecorationImage(
                              image: FileImage(image!), fit: BoxFit.cover)
                          : null)
                      : DecorationImage(
                          image: imagePath!.startsWith('http')
                              ? NetworkImage(imagePath!)
                              : AssetImage(imagePath!) as ImageProvider,
                          fit: BoxFit.cover)),
              child: Center(
                  child: IconButton(
                      onPressed: () {
                        context.read<DashboardBloc>().add(PickImageEvent());
                      },
                      icon: Icon(
                        Icons.collections_bookmark,
                      ))),
              width: screenWidth * 0.4,
              height: screenHeight * 0.16,
            ),
          ],
        ),
      ),
    );
  }
}
