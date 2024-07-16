import 'package:event_master/common/assigns.dart';
import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';
import 'package:event_master/presentation/components/create_event/custom_headline.dart';
import 'package:event_master/presentation/components/create_event/custom_textfeild.dart';
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
  });

  final double screenHeight;
  final TextEditingController clientNameController;
  final TextEditingController emailController;
  final TextEditingController phoneNumberController;
  final TextEditingController locationController;
  final TextEditingController dateController;
  final TextEditingController timeController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeadLineTextWidget(
              screenHeight: screenHeight,
              text: Assigns.clientInformation,
            ),
            SizedBox(height: 16),
            CustomTextFieldWidget(
              controller: clientNameController,
              readOnly: false,
              labelText: 'Name',
              prefixIcon: Icons.person,
            ),
            SizedBox(height: 16),
            CustomTextFieldWidget(
              controller: emailController,
              readOnly: false,
              labelText: 'Email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email,
            ),
            SizedBox(height: 16),
            CustomTextFieldWidget(
              controller: phoneNumberController,
              readOnly: false,
              labelText: 'Phone Number',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone,
            ),
            SizedBox(height: 16),
            CustomTextFieldWidget(
              controller: locationController,
              readOnly: true,
              labelText: 'Enable location',
              prefixIcon: Icons.location_on,
              onTap: () {
                context.read<DashboardBloc>().add(FetchLocation());
              },
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextFieldWidget(
                    controller: dateController,
                    labelText: 'dd/mm/yyyy',
                    prefixIcon: Icons.calendar_today,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        dateController.text =
                            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      }
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CustomTextFieldWidget(
                    controller: timeController,
                    labelText: '00:00',
                    prefixIcon: Icons.access_time,
                    readOnly: true,
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        timeController.text =
                            "${pickedTime.hour}:${pickedTime.minute}";
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
