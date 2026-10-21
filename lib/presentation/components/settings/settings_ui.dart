import 'package:event_master/common/assigns.dart';
import 'package:event_master/common/style.dart';
import 'package:event_master/presentation/components/media/media_image.dart';
import 'package:flutter/material.dart';

/// Shared building blocks for the Settings screen.
///
/// Both apps draw the same surfaces — a profile header, labelled sections and
/// charcoal menu cards — over the existing black theme and the existing teal
/// accent. Nothing here knows what a row does; the screens keep owning their
/// own actions and destinations.

/// The charcoal every menu card is drawn on.
const Color kSettingsCard = Color(0xFF1C1C1E);

/// Hairline between rows inside one card.
const Color kSettingsDivider = Color(0x14FFFFFF);

/// Avatar, name and email, with a clearly labelled edit action.
///
/// The avatar keeps the MediaImage convention: since the media migration an
/// image path is an R2 object key, which only MediaImage can resolve, and a
/// missing one falls back to the person placeholder.
class SettingsHeader extends StatelessWidget {
  const SettingsHeader({
    super.key,
    required this.imagePath,
    required this.name,
    required this.subtitle,
    required this.onEdit,
  });

  final String imagePath;
  final String name;

  /// Email, or whatever the app shows beneath the name.
  final String subtitle;

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: myColor, width: 2),
          ),
          child: ClipOval(
            child: SizedBox(
              width: 96,
              height: 96,
              child: MediaImage(
                imagePath: imagePath,
                placeholder: AssetImage(Assigns.personImage),
                builder: (context, image) => Image(
                  image: image ?? AssetImage(Assigns.personImage),
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
        const SizedBox(height: 16),
        // A labelled control rather than the old unlabelled icon tucked
        // against the avatar: easier to see, easier to hit, and readable by
        // a screen reader.
        Semantics(
          button: true,
          label: 'Edit profile',
          child: SizedBox(
            height: 40,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, size: 17, color: myColor),
              label: Text(
                'Edit profile',
                style: TextStyle(
                    color: myColor, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: myColor.withAlpha(110)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A small all-caps heading above a group of rows, such as ACCOUNT or ABOUT.
class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// One row's content. The screens build these from their own item maps, so
/// an action's destination and meaning stay where they already live.
class SettingsRow {
  const SettingsRow({
    required this.icon,
    required this.label,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;

  /// Null for a row that only displays a value, such as a phone number.
  /// Such a row shows no chevron and gives no tap feedback, so it does not
  /// promise something to open.
  final VoidCallback? onTap;

  /// Drawn in a warning tint instead of teal.
  final bool danger;
}

/// A rounded charcoal card holding one group of rows, hairline-separated.
class SettingsMenuCard extends StatelessWidget {
  const SettingsMenuCard({super.key, required this.rows});

  final List<SettingsRow> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: kSettingsCard,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 56,
                color: kSettingsDivider,
              ),
            _SettingsTile(row: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.row});

  final SettingsRow row;

  @override
  Widget build(BuildContext context) {
    final Color tint = row.danger ? const Color(0xFFFF6B6B) : myColor;
    final bool interactive = row.onTap != null;

    final Widget content = Padding(
      // 56 of height before text scaling, comfortably past the 48dp
      // minimum touch target.
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: tint.withAlpha(28),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(row.icon, size: 17, color: tint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              row.label,
              style: TextStyle(
                color: row.danger ? tint : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Only a row that goes somewhere says so.
          if (interactive)
            const Icon(Icons.chevron_right, size: 20, color: Colors.white30),
        ],
      ),
    );

    if (!interactive) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: row.onTap, child: content),
    );
  }
}
