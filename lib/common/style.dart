import 'package:flutter/material.dart';

Color myColor = Color(0xFF0CFCDF);
var sizedbox = SizedBox(height: 20);
var sizedBoxWidth = SizedBox(
  width: 20,
);
Color myCustomColor = Color(0xFF840CFC);

// --------------------------------------------------------------- surfaces
//
// The form screens were built on `Colors.white30` — a translucent white wash
// over the black scaffold, which renders as flat grey mud and changes shade
// depending on what is behind it. These are opaque, so a card looks the same
// everywhere, and they step rather than blend: background → card → field.
//
// Added alongside the existing names rather than replacing them; nothing that
// already uses `myColor` or `myCustomColor` changes.

/// A card sitting on the black scaffold.
const Color kSurface = Color(0xFF17191C);

/// A field or inner panel sitting on [kSurface], one step lighter.
const Color kSurfaceAlt = Color(0xFF212429);

/// Hairlines. Deliberately dim — the old solid `Colors.white` borders on every
/// field drew more attention than the values inside them.
const Color kBorder = Color(0xFF32363C);

/// A border on the field the user is in.
const Color kBorderFocused = Color(0xFF4A5057);

const Color kTextPrimary = Color(0xFFF2F4F5);
const Color kTextSecondary = Color(0xFFA7ADB4);
const Color kTextMuted = Color(0xFF6F767E);

/// One radius for cards, one for the fields inside them.
const double kRadiusCard = 16;
const double kRadiusField = 12;
