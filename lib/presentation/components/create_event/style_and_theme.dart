import 'package:event_master/common/assigns.dart';
import 'package:event_master/presentation/components/create_event/colortheme_selector.dart';
import 'package:event_master/presentation/components/create_event/custom_headline.dart';
import 'package:event_master/presentation/components/create_event/custom_textfeild.dart';
import 'package:flutter/material.dart';

class StyleAndThemeWidget extends StatelessWidget {
  const StyleAndThemeWidget({
    super.key,
    required this.screenHeight,
    required this.selectedColor,
    required this.guestCountController,
  });

  final double screenHeight;
  final Color selectedColor;
  final TextEditingController guestCountController;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white30,
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomHeadLineTextWidget(
                  screenHeight: screenHeight, text: Assigns.styleAndTheme),
              SizedBox(height: 16),
              ColorThemeSelector(
                selectedColor: selectedColor,
              ),
              SizedBox(height: 16),
              CustomHeadLineTextWidget(
                  screenHeight: screenHeight, text: Assigns.guestList),
              SizedBox(height: 16),
              CustomTextFieldWidget(
                  controller: guestCountController,
                  labelText: 'Number fo Guests',
                  prefixIcon: Icons.numbers,
                  keyboardType: TextInputType.number,
                  readOnly: false),
            ],
          ),
        ),
      ),
    );
  }
}
