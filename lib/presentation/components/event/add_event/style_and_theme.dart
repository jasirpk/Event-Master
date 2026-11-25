import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/components/event/add_event/colortheme_selector.dart';
import 'package:event_master/presentation/components/event/add_event/custom_headline.dart';
import 'package:event_master/presentation/components/event/add_event/custom_textfeild.dart';
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kBorder),
      ),
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
                  // Was 'Number fo Guests'. A visible typo on a production
                  // form; the field, its controller and its validation are
                  // untouched.
                  labelText: 'Number of Guests',
                  hintText: 'e.g. 120',
                  prefixIcon: Icons.numbers,
                  isDense: true,
                  keyboardType: TextInputType.number,
                  readOnly: false),
            ],
          ),
        ),
      ),
    );
  }
}
