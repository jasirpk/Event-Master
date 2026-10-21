import 'package:event_master/presentation/components/settings/settings_ui.dart';
import 'package:event_master/presentation/pages/dashboard/profile_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The body of the Settings screen.
///
/// Extracted from ProfileScreen, which built the header, the detail rows and
/// the menu inline. Pulling it out mirrors how Admin Event Pro is already
/// arranged, so the two apps can share one look without sharing navigation
/// or business logic — every action still comes in from the screen.
class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({
    super.key,
    required this.userData,
    required this.items,
  });

  final Map<String, dynamic>? userData;

  /// The screen's own `{icon, text, section, onTap}` maps.
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final String profileImage = userData?['imagePath'] ?? '';
    final String userName = userData?['userName'] ?? 'No name';
    final String phoneNumber = userData?['phoneNumber'] ?? '';
    final String email = userData?['email'] ?? '';

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsHeader(
              imagePath: profileImage,
              name: userName,
              subtitle: email,
              // Unchanged destination and arguments.
              onEdit: () => Get.to(() => ProfileFormScreen(
                    userName: userName,
                    phoneNumber: phoneNumber.isEmpty ? '+91' : phoneNumber,
                    imagePath: profileImage,
                  )),
            ),
            const SettingsSectionLabel('Contact'),
            SettingsMenuCard(
              rows: [
                SettingsRow(
                  icon: Icons.call,
                  label: phoneNumber.isEmpty ? 'No phone number' : phoneNumber,
                ),
                SettingsRow(
                  icon: Icons.mail,
                  label: email.isEmpty ? 'No email' : email,
                ),
              ],
            ),
            for (final section in _sections)
              if (_rowsFor(section).isNotEmpty) ...[
                SettingsSectionLabel(section),
                SettingsMenuCard(rows: _rowsFor(section)),
              ],
            const SizedBox(height: 28),
            const Center(
              child: Text('Version 1.0.0+2',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  /// Section order. An item without a section falls into ABOUT, so an item
  /// added later still appears.
  static const List<String> _sections = ['ACCOUNT', 'ABOUT', 'DANGER'];

  /// `onTap` is passed straight through, so every destination stays exactly
  /// where the screen defined it.
  List<SettingsRow> _rowsFor(String section) {
    return items
        .where((item) => (item['section'] as String? ?? 'ABOUT') == section)
        .map((item) => SettingsRow(
              icon: item['icon'] as IconData,
              label: item['text'] as String,
              onTap: item['onTap'] as VoidCallback?,
              danger: section == 'DANGER',
            ))
        .toList();
  }
}
