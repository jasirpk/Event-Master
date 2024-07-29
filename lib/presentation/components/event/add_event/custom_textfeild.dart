import 'package:flutter/material.dart';

class CustomTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String labelText;
  final IconData? prefixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final IconData? suffixIcon;

  const CustomTextFieldWidget({
    super.key,
    required this.controller,
    this.keyboardType,
    this.maxLines,
    required this.labelText,
    this.prefixIcon,
    this.onTap,
    required this.readOnly,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        suffixIcon: Icon(
          suffixIcon,
          color: Colors.white,
        ),
        prefixIcon: Icon(prefixIcon),
        prefixIconColor: Colors.white,
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white70),
        alignLabelWithHint: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
