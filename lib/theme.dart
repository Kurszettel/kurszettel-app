import 'package:flutter/material.dart';

/// Farbwelt Kurszettel (Projektnotiz design-logo.md, verbindlich).
class KZ {
  static const navy = Color(0xFF0F1A2B);
  static const panel = Color(0xFF172238);
  static const linie = Color(0xFF2A3650);
  static const creme = Color(0xFFF3EFE6);
  static const grau = Color(0xFF9AA6B8);
  static const gold = Color(0xFFB8962E);
  static const gruen = Color(0xFF7FBF8E);
  static const rot = Color(0xFFD08A7A);

  /// Wortmarke und Titel
  static const caslon = 'LibreCaslonText';

  /// Meta, Rubriken, Zeiten
  static const mono = 'IBMPlexMono';

  /// Fließtext
  static const sans = 'IBMPlexSans';

  /// Rubrik-Überschrift: Plex Mono, Versalien, gesperrt, Gold.
  static const rubrik = TextStyle(fontFamily: mono, fontSize: 12, letterSpacing: 2.2, fontWeight: FontWeight.w500, color: gold);

  /// Kleine Metazeile (Datum, Quelle).
  static const meta = TextStyle(fontFamily: mono, fontSize: 12, color: grau, height: 1.4);

  static TextStyle titel(double size) =>
      TextStyle(fontFamily: caslon, fontWeight: FontWeight.w700, fontSize: size, color: creme, height: 1.2);
}

ThemeData kurszettelThema() {
  const schema = ColorScheme(
    brightness: Brightness.dark,
    primary: KZ.gold,
    onPrimary: KZ.navy,
    secondary: KZ.gold,
    onSecondary: KZ.navy,
    error: KZ.rot,
    onError: KZ.navy,
    surface: KZ.navy,
    onSurface: KZ.creme,
    surfaceContainerHighest: KZ.panel,
    surfaceContainerHigh: KZ.panel,
    surfaceContainer: KZ.panel,
    outline: KZ.linie,
    outlineVariant: KZ.linie,
  );
  final basis = ThemeData(colorScheme: schema, useMaterial3: true, fontFamily: KZ.sans);
  return basis.copyWith(
    scaffoldBackgroundColor: KZ.navy,
    appBarTheme: const AppBarTheme(
      backgroundColor: KZ.navy,
      foregroundColor: KZ.creme,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontFamily: KZ.caslon, fontWeight: FontWeight.w700, fontSize: 20, color: KZ.creme),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: KZ.panel,
      indicatorColor: KZ.gold.withValues(alpha: 0.22),
      iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(color: s.contains(WidgetState.selected) ? KZ.gold : KZ.grau)),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
          fontFamily: KZ.mono,
          fontSize: 11,
          letterSpacing: 0.6,
          color: s.contains(WidgetState.selected) ? KZ.gold : KZ.grau)),
    ),
    dividerTheme: const DividerThemeData(color: KZ.linie, thickness: 1, space: 1),
    cardTheme: const CardThemeData(color: KZ.panel, elevation: 0, margin: EdgeInsets.zero),
    listTileTheme: const ListTileThemeData(iconColor: KZ.grau, textColor: KZ.creme),
    chipTheme: ChipThemeData(
      backgroundColor: KZ.navy,
      selectedColor: KZ.gold,
      side: const BorderSide(color: KZ.linie),
      labelStyle: const TextStyle(fontFamily: KZ.mono, fontSize: 12, color: KZ.creme),
      secondaryLabelStyle: const TextStyle(fontFamily: KZ.mono, fontSize: 12, color: KZ.navy),
      checkmarkColor: KZ.navy,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? KZ.navy : KZ.grau),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? KZ.gold : KZ.linie),
    ),
    sliderTheme: const SliderThemeData(activeTrackColor: KZ.gold, thumbColor: KZ.gold, inactiveTrackColor: KZ.linie),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: KZ.gold),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: KZ.gold)),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(backgroundColor: KZ.gold, foregroundColor: KZ.navy, textStyle: const TextStyle(fontWeight: FontWeight.w600)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(foregroundColor: KZ.creme, side: const BorderSide(color: KZ.linie)),
    ),
    snackBarTheme: const SnackBarThemeData(backgroundColor: KZ.panel, contentTextStyle: TextStyle(color: KZ.creme)),
    textTheme: basis.textTheme.apply(bodyColor: KZ.creme, displayColor: KZ.creme).copyWith(
          titleLarge: KZ.titel(22),
          titleMedium: const TextStyle(fontFamily: KZ.sans, fontWeight: FontWeight.w600, fontSize: 16, color: KZ.creme),
          bodySmall: KZ.meta,
        ),
  );
}
