import 'package:event_master/common/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';

/// One named colour the theme selector offers.
class _ThemeOption {
  const _ThemeOption(this.label, this.color);

  final String label;
  final Color color;
}

/// The event's colour theme.
///
/// The five options, their labels and the [ChangeColorTheme] event are exactly
/// the ones this selector has always had — nothing is added or removed.
///
/// What changed is that the circles do something. They used to be five bare
/// `CircleAvatar`s sitting beside the dropdown with no gesture on them and no
/// mark on the chosen one: the only way to pick a colour was the dropdown, and
/// the row of swatches was decoration that looked interactive. Tapping one now
/// selects it, and the selected one is ringed.
class ColorThemeSelector extends StatefulWidget {
  final Color selectedColor;

  ColorThemeSelector({Key? key, required this.selectedColor}) : super(key: key);

  @override
  _ColorThemeSelectorState createState() => _ColorThemeSelectorState();
}

class _ColorThemeSelectorState extends State<ColorThemeSelector> {
  late Color _selectedColor;

  /// Declared once and shared by the dropdown and the swatches, so the two can
  /// never offer different sets.
  static final List<_ThemeOption> _options = [
    const _ThemeOption('Blue', Colors.blue),
    const _ThemeOption('Red', Colors.red),
    const _ThemeOption('Green', Colors.green),
    const _ThemeOption('Yellow', Colors.yellow),
    _ThemeOption('Teal', myColor),
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor;
  }

  @override
  void didUpdateWidget(ColorThemeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The bloc is the source of truth. Without this the local copy and the
    // state diverged whenever anything else rebuilt the form.
    if (oldWidget.selectedColor != widget.selectedColor) {
      _selectedColor = widget.selectedColor;
    }
  }

  void _select(Color colour) {
    if (colour == _selectedColor) return;

    setState(() => _selectedColor = colour);
    context.read<DashboardBloc>().add(ChangeColorTheme(colour));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: kSurfaceAlt,
            borderRadius: BorderRadius.circular(kRadiusField),
            border: Border.all(color: kBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Color>(
              value: _selectedColor,
              isExpanded: true,
              dropdownColor: kSurfaceAlt,
              borderRadius: BorderRadius.circular(kRadiusField),
              icon: const Icon(Icons.expand_more_rounded,
                  color: kTextSecondary, size: 20),
              items: [
                for (final option in _options)
                  DropdownMenuItem(
                    value: option.color,
                    child: Row(
                      children: [
                        _Dot(colour: option.color, size: 16),
                        const SizedBox(width: 10),
                        Text(
                          option.label,
                          style: const TextStyle(
                              color: kTextPrimary, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
              ],
              onChanged: (Color? newColor) {
                if (newColor != null) _select(newColor);
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Wrap, not Row: five swatches plus their rings do not fit beside each
        // other on the narrowest phones, and a Row would overflow rather than
        // move one onto a second line.
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            for (final option in _options)
              _Swatch(
                option: option,
                selected: option.color == _selectedColor,
                onTap: () => _select(option.color),
              ),
          ],
        ),
      ],
    );
  }
}

/// A tappable colour, ringed when it is the chosen one.
class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _ThemeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      // "Green theme" rather than "Green": the dropdown above renders its
      // chosen item with the same word, so a bare colour name matches two
      // places on this screen — ambiguous to a screen reader as well as to a
      // test.
      label: '${option.label} theme',
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // The ring is the selection, drawn outside the colour so it reads
            // on a dark swatch as well as a bright one.
            border: Border.all(
              color: selected ? kTextPrimary : Colors.transparent,
              width: 2,
            ),
          ),
          child: _Dot(colour: option.color, size: 30, checked: selected),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.colour,
    required this.size,
    this.checked = false,
  });

  final Color colour;
  final double size;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colour,
        shape: BoxShape.circle,
        border: Border.all(color: kBorder),
      ),
      child: checked
          ? Icon(
              Icons.check_rounded,
              // Against yellow and teal a white tick disappears; these
              // swatches are all light, so the tick is dark.
              color: Colors.black.withValues(alpha: 0.75),
              size: size * 0.6,
            )
          : null,
    );
  }
}
