import 'package:dorm_chef/theme/color.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() => FlexThemeData.light(
    colorScheme: lightColorScheme,
    useMaterial3: true,
    subThemesData: const FlexSubThemesData(
      defaultRadius: 16,
      inputDecoratorRadius: 12,
      elevatedButtonRadius: 14,
      outlinedButtonRadius: 14,
      filledButtonRadius: 14,
      chipRadius: 12,
    ),
    visualDensity: VisualDensity.standard,
  );

  static ThemeData dark() => FlexThemeData.dark(
    colorScheme: darkColorScheme,
    useMaterial3: true,
    subThemesData: const FlexSubThemesData(
      defaultRadius: 16,
      inputDecoratorRadius: 12,
      elevatedButtonRadius: 14,
      outlinedButtonRadius: 14,
      filledButtonRadius: 14,
      chipRadius: 12,
    ),
    visualDensity: VisualDensity.standard,
  );
}
