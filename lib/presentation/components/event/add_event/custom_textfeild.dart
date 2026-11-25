import 'package:event_master/common/style.dart';
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
      style: const TextStyle(color: kTextPrimary, fontSize: 15),
      cursorColor: myColor,
      decoration: InputDecoration(
        isDense: isDense,
        contentPadding: isDense
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 14)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        filled: true,
        fillColor: kSurfaceAlt,
        // Built only when there is one to show. `Icon(null)` is still a
        // widget: it reserved a 48px box on the trailing edge of every field
        // on this screen, which is most of the dead space in the middle of
        // the inputs.
        suffixIcon: suffixIcon == null
            ? null
            : Icon(suffixIcon, color: kTextSecondary, size: 20),
        prefixIcon:
            prefixIcon == null ? null : Icon(prefixIcon, size: 20),
        prefixIconColor: kTextSecondary,
        labelText: labelText,
        hintText: hintText,
        hintStyle: const TextStyle(color: kTextMuted, fontSize: 14),
        labelStyle: const TextStyle(color: kTextSecondary, fontSize: 14),
        floatingLabelStyle: TextStyle(color: myColor, fontSize: 13),
        alignLabelWithHint: true,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kBorder),
          borderRadius: BorderRadius.circular(kRadiusField),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: myColor, width: 1.4),
          borderRadius: BorderRadius.circular(kRadiusField),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: kBorder),
          borderRadius: BorderRadius.circular(kRadiusField),
        ),
      ),
    );
  }
}
