import 'package:flutter/material.dart';

/// Provides the shared Material 3 theme variants used by CascadeFlow.
abstract final class CascadeAppTheme {
  static ThemeData _buildTheme(Brightness brightness) => ThemeData(
    colorSchemeSeed: Colors.indigo,
    useMaterial3: true,
    brightness: brightness,
  );

  /// Light theme tailored for CascadeFlow's brand palette.
  static final ThemeData light = _buildTheme(Brightness.light);

  /// Dark theme counterpart that mirrors the light palette.
  static final ThemeData dark = _buildTheme(Brightness.dark);
}
