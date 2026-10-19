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

  /// Tightens the field's vertical padding. Off by default, so every existing
  /// caller renders exactly as before.
  final bool isDense;

  /// Shown in place of a floating label when the field is empty.
  final String? hintText;

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
    this.isDense = false,
    this.hintText,
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
        isDense: isDense,
        contentPadding: isDense
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 14)
            : null,
        suffixIcon: Icon(
          suffixIcon,
          color: Colors.white,
        ),
        prefixIcon: Icon(prefixIcon),
        prefixIconColor: Colors.white,
        labelText: labelText,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white38),
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
