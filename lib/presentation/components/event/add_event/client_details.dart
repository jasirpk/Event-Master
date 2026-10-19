import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/presentation/components/event/add_event/custom_headline.dart';
import 'package:event_master/presentation/components/event/add_event/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientDeatailsWidget extends StatelessWidget {
  const ClientDeatailsWidget({
    super.key,
    required this.screenHeight,
    required this.clientNameController,
    required this.emailController,
    required this.phoneNumberController,
    required this.locationController,
    required this.dateController,
    required this.timeController,
    this.locating = false,
  });

  final double screenHeight;
  final TextEditingController clientNameController;
  final TextEditingController emailController;
  final TextEditingController phoneNumberController;
  final TextEditingController locationController;
  final TextEditingController dateController;
  final TextEditingController timeController;

  /// A location lookup is in flight.
  final bool locating;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: Assigns.clientInformation,
      screenHeight: screenHeight,
      children: [
        CustomTextFieldWidget(
          controller: clientNameController,
          readOnly: false,
          isDense: true,
          labelText: 'Name',
          prefixIcon: Icons.person,
        ),
        const SizedBox(height: 12),
        CustomTextFieldWidget(
          controller: emailController,
          readOnly: false,
          isDense: true,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email,
        ),
        const SizedBox(height: 12),
        CustomTextFieldWidget(
          controller: phoneNumberController,
          readOnly: false,
          isDense: true,
          labelText: 'Phone Number',
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone,
        ),
        const SizedBox(height: 12),
        _LocationCard(
          controller: locationController,
          locating: locating,
          onUseCurrent: () =>
              context.read<DashboardBloc>().add(FetchLocation()),
        ),
        const SizedBox(height: 12),
        _DateAndTime(
          dateController: dateController,
          timeController: timeController,
        ),
      ],
    );
  }
}

/// A titled panel. One place decides the card's padding, radius and tint.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.screenHeight,
    required this.children,
  });

  final String title;
  final double screenHeight;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomHeadLineTextWidget(screenHeight: screenHeight, text: title),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

/// The event location: what is set, and one explicit way to set it.
///
/// Replaces a full-width read-only "Enable location" text field whose only
/// affordance was tapping it. Two things changed beyond the layout: the value
/// is editable, so a refused or unavailable GPS fix is no longer a dead end
/// on a required field, and the lookup reports progress in place rather than
/// behind a modal spinner.
class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.controller,
    required this.locating,
    required this.onUseCurrent,
  });

  final TextEditingController controller;
  final bool locating;
  final VoidCallback onUseCurrent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.location_on, color: myColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Event location',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                TextField(
                  controller: controller,
                  maxLines: 1,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    border: InputBorder.none,
                    hintText: 'Use current location, or type it',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (locating)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton.icon(
              onPressed: onUseCurrent,
              style: TextButton.styleFrom(
                foregroundColor: myColor,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.my_location, size: 18),
              label: const Text('Use current'),
            ),
        ],
      ),
    );
  }
}

/// Date beside time, with the date given the wider share.
class _DateAndTime extends StatelessWidget {
  const _DateAndTime({
    required this.dateController,
    required this.timeController,
  });

  final TextEditingController dateController;
  final TextEditingController timeController;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 3:2 rather than an even split. A date is always ten characters and
        // a time is five, and splitting evenly left the date too narrow — the
        // year wrapped onto a second line on a phone.
        Expanded(
          flex: 3,
          child: CustomTextFieldWidget(
            controller: dateController,
            labelText: 'Date',
            hintText: 'dd/mm/yyyy',
            prefixIcon: Icons.calendar_today,
            readOnly: true,
            isDense: true,
            maxLines: 1,
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                // Zero-padded, so the text is a fixed ten characters and
                // cannot grow wider than the field was measured for.
                dateController.text =
                    '${_two(pickedDate.day)}/${_two(pickedDate.month)}/'
                    '${pickedDate.year}';
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: CustomTextFieldWidget(
            controller: timeController,
            labelText: 'Time',
            hintText: '00:00',
            prefixIcon: Icons.access_time,
            readOnly: true,
            isDense: true,
            maxLines: 1,
            onTap: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null && context.mounted) {
                final locallizations = MaterialLocalizations.of(context);
                timeController.text = locallizations.formatTimeOfDay(
                  pickedTime,
                  alwaysUse24HourFormat: false,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
