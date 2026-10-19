import 'dart:io';
import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
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
        borderRadius: BorderRadius.circular(14),
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
            const SizedBox(height: 14),
            CustomTextFieldWidget(
              controller: eventTypeController,
              readOnly: false,
              isDense: true,
              labelText: 'Event type',
              prefixIcon: Icons.event,
            ),
            const SizedBox(height: 12),
            CustomTextFieldWidget(
              controller: aboutController,
              readOnly: false,
              isDense: true,
              // Three lines rather than four: enough to read a short brief
              // without the field dominating the section.
              maxLines: 3,
              labelText: 'About',
            ),
            const SizedBox(height: 14),
            _ImagePreview(
              imagePath: imagePath,
              image: image,
              onChange: () =>
                  context.read<DashboardBloc>().add(PickImageEvent()),
            ),
          ],
        ),
      ),
    );
  }
}

/// The event picture, and one obvious way to replace it.
///
/// Three sources have to keep working and only one is local:
///
///  * [image]      — a file just picked on this device, which wins when set.
///  * an R2 key    — the `subcategory_images/…` default carried in from the
///                   template screens, or an `event_images/…` picture saved
///                   earlier. Both need signing, which [MediaImage] does.
///  * a legacy URL — an `https://…` Firebase Storage link on an older event,
///                   which [MediaImage] passes straight through.
class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.imagePath,
    required this.image,
    required this.onChange,
  });

  final String? imagePath;
  final File? image;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final path = imagePath ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Event image',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
            TextButton.icon(
              onPressed: onChange,
              style: TextButton.styleFrom(
                foregroundColor: myColor,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: Text(_hasPicture(path) ? 'Change image' : 'Add image'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: image != null
                ? Image.file(image!, fit: BoxFit.cover)
                : MediaImage(
                    imagePath: path,
                    builder: (context, resolved) => resolved == null
                        ? _Empty(onTap: onChange)
                        : Image(image: resolved, fit: BoxFit.cover),
                  ),
          ),
        ),
      ],
    );
  }

  bool _hasPicture(String path) => image != null || path.isNotEmpty;
}

/// Shown while a key is being signed, and when there is nothing to show.
class _Empty extends StatelessWidget {
  const _Empty({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.black.withValues(alpha: 0.18),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.collections_bookmark, color: myColor, size: 28),
              const SizedBox(height: 6),
              const Text(
                'Tap to choose an image',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
