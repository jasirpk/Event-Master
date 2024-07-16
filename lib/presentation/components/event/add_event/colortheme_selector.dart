import 'package:event_master/common/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_master/data_layer/dashboard/dashboard_bloc.dart';

class ColorThemeSelector extends StatefulWidget {
  final Color selectedColor;

  ColorThemeSelector({Key? key, required this.selectedColor}) : super(key: key);

  @override
  _ColorThemeSelectorState createState() => _ColorThemeSelectorState();
}

class _ColorThemeSelectorState extends State<ColorThemeSelector> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownButton<Color>(
          value: _selectedColor,
          items: [
            DropdownMenuItem(
              value: Colors.blue,
              child: Text('Blue', style: TextStyle(color: Colors.blue)),
            ),
            DropdownMenuItem(
              value: Colors.red,
              child: Text('Red', style: TextStyle(color: Colors.red)),
            ),
            DropdownMenuItem(
              value: Colors.green,
              child: Text('Green', style: TextStyle(color: Colors.green)),
            ),
            DropdownMenuItem(
              value: Colors.yellow,
              child: Text('Yellow', style: TextStyle(color: Colors.yellow)),
            ),
            DropdownMenuItem(
              value: myColor,
              child: Text('Teal', style: TextStyle(color: myColor)),
            ),
          ],
          onChanged: (Color? newColor) {
            if (newColor != null) {
              setState(() {
                _selectedColor = newColor;
              });
              context.read<DashboardBloc>().add(ChangeColorTheme(newColor));
            }
          },
        ),
        SizedBox(width: 10),
        CircleAvatar(backgroundColor: Colors.red, maxRadius: 15),
        SizedBox(width: 6),
        CircleAvatar(backgroundColor: Colors.green, maxRadius: 15),
        SizedBox(width: 6),
        CircleAvatar(backgroundColor: Colors.yellow, maxRadius: 15),
        SizedBox(width: 6),
        CircleAvatar(backgroundColor: Colors.blue, maxRadius: 15),
        SizedBox(width: 6),
        CircleAvatar(backgroundColor: myColor, maxRadius: 15),
      ],
    );
  }
}
