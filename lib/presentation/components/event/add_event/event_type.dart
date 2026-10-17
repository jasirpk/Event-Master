import 'dart:io';
import 'package:event_master/common/assigns.dart';
import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/presentation/components/event/add_event/custom_headline.dart';
import 'package:event_master/presentation/components/event/add_event/custom_textfeild.dart';
import 'package:event_master/presentation/components/media/media_image.dart';
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
            // The event picture arrives as a subcategory's R2 object key
            // ("subcategory_images/..."), which startsWith('http') pushed
            // into AssetImage — Flutter then looked for a bundled asset of
            // that name and threw "Unable to load asset". MediaImage signs a
            // key and passes a legacy URL straight through.
            //
            // A locally picked file still wins only when no stored path is
            // set, which is the precedence this widget already had. The
            // placeholder stays null deliberately: this box is the image
            // picker's tap target, and a stand-in photo would read as a
            // chosen image rather than an empty slot.
            MediaImage(
              imagePath: imagePath,
              builder: (context, resolved) {
                final String path = imagePath ?? '';
                final DecorationImage? background = path.isEmpty
                    ? (image != null
                        ? DecorationImage(
                            image: FileImage(image!), fit: BoxFit.cover)
                        : null)
                    : (resolved != null
                        ? DecorationImage(image: resolved, fit: BoxFit.cover)
                        : null);

                return Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey,
                      image: background),
                  width: screenWidth * 0.4,
                  height: screenHeight * 0.16,
                  child: Center(
                      child: IconButton(
                          onPressed: () {
                            context.read<DashboardBloc>().add(PickImageEvent());
                          },
                          icon: Icon(
                            Icons.collections_bookmark,
                          ))),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
