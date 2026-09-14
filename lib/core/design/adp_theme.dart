import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AdpColors {
  // Mediterranean Warm Luxury Palette (Studio Parity)
  static const canvas = Color(0xFFFBF9F5); // Warm chaux & sable djerbien
  static const canvasSoft = Color(0xFFF4F1EA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF7F5EE);

  static const ink = Color(0xFF0E2129); // Deep Mediterranean night ink
  static const inkSoft = Color(0xFF2D424B);
  static const muted = Color(0xFF687B82);
  static const mutedLight = Color(0xFF9EADB4);

  static const terracotta = Color(0xFFD46238); // Argile de Guellala
  static const terracottaSoft = Color(0x17D46238);
  static const ocean = Color(0xFF0D6274); // Mer de Djerba
  static const oceanSoft = Color(0x170D6274);
  static const oceanDark = Color(0xFF093E4A);
  static const sandGold = Color(0xFFD5AB72);
  static const success = Color(0xFF1F8A65);
  static const successSoft = Color(0x1A1F8A65);

  // Backward-compatible aliases
  static const navy = oceanDark;
  static const lagoon = ocean;
  static const sand = canvas;
  static const background = canvas;
  static const border = Color(0xFFE6E2D8);
  static const night = Color(0xFF0D1117);
}

abstract final class AdpSpace {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

ThemeData adpTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AdpColors.ocean,
    brightness: Brightness.light,
    primary: AdpColors.ocean,
    secondary: AdpColors.terracotta,
    surface: AdpColors.surface,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AdpColors.canvas,
    textTheme:
        GoogleFonts.manropeTextTheme(Typography.material2021().black).copyWith(
      displayLarge: GoogleFonts.barlowCondensed(
          fontSize: 56,
          height: .9,
          fontWeight: FontWeight.w800,
          color: AdpColors.ink),
      displayMedium: GoogleFonts.barlowCondensed(
          fontSize: 46,
          height: .94,
          fontWeight: FontWeight.w800,
          color: AdpColors.ink),
      headlineMedium: GoogleFonts.barlowCondensed(
          fontSize: 36,
          height: .96,
          fontWeight: FontWeight.w800,
          color: AdpColors.ink),
      titleLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.w800, color: AdpColors.ink),
      bodyLarge: GoogleFonts.manrope(height: 1.45, color: AdpColors.ink),
      bodyMedium: GoogleFonts.manrope(height: 1.45, color: AdpColors.ink),
      labelMedium: GoogleFonts.manrope(fontWeight: FontWeight.w700),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.barlowCondensed(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
        color: AdpColors.ink,
      ),
      iconTheme: const IconThemeData(color: AdpColors.ink),
    ),
    cardTheme: CardThemeData(
      color: AdpColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: AdpColors.ink.withValues(alpha: 0.06), width: 1),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AdpColors.surface,
        indicatorColor: AdpColors.ocean.withValues(alpha: .14),
        labelTextStyle: WidgetStatePropertyAll(
            GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800))),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AdpColors.ink,
      contentTextStyle: GoogleFonts.manrope(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AdpColors.surface,
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      titleTextStyle: GoogleFonts.barlowCondensed(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AdpColors.ink,
      ),
      contentTextStyle: GoogleFonts.manrope(
        fontSize: 14,
        height: 1.45,
        color: AdpColors.muted,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AdpColors.surface,
      modalBackgroundColor: AdpColors.surface,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      showDragHandle: true,
      dragHandleColor: AdpColors.mutedLight,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AdpColors.surface,
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AdpColors.ink,
      ),
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AdpColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AdpColors.ink, width: 1.5)),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AdpColors.terracotta)),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AdpColors.terracotta, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

class AdpStudioBackButton extends StatelessWidget {
  const AdpStudioBackButton({super.key, this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AdpColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AdpColors.ink.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: AdpColors.ink.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back_rounded, size: 18, color: AdpColors.ink),
          onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}

