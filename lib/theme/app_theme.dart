import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ══════════════════════════════════════════════════════════════
//  WHISEN COLOR TOKENS
// ══════════════════════════════════════════════════════════════
class AppColors {
  AppColors._();

  // Brand tokens
  static const Color brandRed   = Color(0xFFA50034);
  static const Color brandGray  = Color(0xFF63666A);
  static const Color brandBlack = Color(0xFF2D2926);

  // Light
  static const Color accentLight         = Color(0xFFA50034);
  static const Color accentOnLight       = Color(0xFFFFFFFF);
  static const Color accentContLight     = Color(0xFFFDE8ED);
  static const Color bgLight             = Color(0xFFFFFFFF);
  static const Color surfaceLight        = Color(0xFFF5F5F6);
  static const Color surface2Light       = Color(0xFFEBECED);
  static const Color onSurfaceLight      = Color(0xFF2D2926);
  static const Color onSurfaceMutedLight = Color(0xFF63666A);
  static const Color outlineLight        = Color(0xFFD1D2D4);
  static const Color outlineFocusLight   = Color(0xFFA50034);

  // Dark
  static const Color accentDark         = Color(0xFFE84C75);
  static const Color accentOnDark       = Color(0xFF1A1816);
  static const Color accentContDark     = Color(0xFF3D1520);
  static const Color bgDark             = Color(0xFF1A1816);
  static const Color surfaceDark        = Color(0xFF252220);
  static const Color surface2Dark       = Color(0xFF302D2A);
  static const Color onSurfaceDark      = Color(0xFFF0EFEE);
  static const Color onSurfaceMutedDark = Color(0xFF9B9DA0);
  static const Color outlineDark        = Color(0xFF3E3B38);
  static const Color outlineFocusDark   = Color(0xFFE84C75);

  // Shared semantic
  static const Color tierStandard = Color(0xFF2E9E33);
  static const Color tierOptimal  = Color(0xFF0099CC);
  static const Color tierPremium  = Color(0xFFD4912E);
  static const Color cooling      = Color(0xFF0099CC);
  static const Color heating      = Color(0xFFE8622A);
  static const Color energy       = Color(0xFFD4912E);
  static const Color money        = Color(0xFF2E9E33);
  static const Color error        = Color(0xFFD93B3B);
  static const Color warning      = Color(0xFFD4912E);

  // Convenience getters — використовує поточну тему
  static Color accent(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? accentDark : accentLight;
  static Color onSurface(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? onSurfaceDark : onSurfaceLight;
  static Color muted(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? onSurfaceMutedDark : onSurfaceMutedLight;
  static Color outline(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? outlineDark : outlineLight;
  static Color surface(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? surfaceDark : surfaceLight;
  static Color surface2(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? surface2Dark : surface2Light;
}

// ══════════════════════════════════════════════════════════════
//  THEME BUILDER
// ══════════════════════════════════════════════════════════════
class AppTheme {
  AppTheme._();

  static ThemeData dark() => _build(
    brightness:   Brightness.dark,
    accent:       AppColors.accentDark,
    accentOn:     AppColors.accentOnDark,
    accentCont:   AppColors.accentContDark,
    bg:           AppColors.bgDark,
    surface:      AppColors.surfaceDark,
    surface2:     AppColors.surface2Dark,
    onSurface:    AppColors.onSurfaceDark,
    muted:        AppColors.onSurfaceMutedDark,
    outline:      AppColors.outlineDark,
    outlineFocus: AppColors.outlineFocusDark,
  );

  static ThemeData light() => _build(
    brightness:   Brightness.light,
    accent:       AppColors.accentLight,
    accentOn:     AppColors.accentOnLight,
    accentCont:   AppColors.accentContLight,
    bg:           AppColors.bgLight,
    surface:      AppColors.surfaceLight,
    surface2:     AppColors.surface2Light,
    onSurface:    AppColors.onSurfaceLight,
    muted:        AppColors.onSurfaceMutedLight,
    outline:      AppColors.outlineLight,
    outlineFocus: AppColors.outlineFocusLight,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color accent,
    required Color accentOn,
    required Color accentCont,
    required Color bg,
    required Color surface,
    required Color surface2,
    required Color onSurface,
    required Color muted,
    required Color outline,
    required Color outlineFocus,
  }) {
    final isDark = brightness == Brightness.dark;
    final base   = isDark ? ThemeData.dark(useMaterial3: true)
                          : ThemeData.light(useMaterial3: true);

    final colorScheme = isDark
        ? ColorScheme.dark(
            primary:                 accent,
            onPrimary:               accentOn,
            primaryContainer:        accentCont,
            onPrimaryContainer:      accent,
            secondary:               AppColors.tierOptimal,
            surface:                 surface,
            onSurface:               onSurface,
            surfaceContainerHighest: surface2,
            outline:                 outline,
            outlineVariant:          outlineFocus,
            error:                   AppColors.error,
          )
        : ColorScheme.light(
            primary:                 accent,
            onPrimary:               accentOn,
            primaryContainer:        accentCont,
            onPrimaryContainer:      accent,
            secondary:               AppColors.tierOptimal,
            surface:                 surface,
            onSurface:               onSurface,
            surfaceContainerHighest: surface2,
            outline:                 outline,
            outlineVariant:          outlineFocus,
            error:                   AppColors.error,
          );

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme:             colorScheme,

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: outline),
        ),
        margin: EdgeInsets.zero,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        iconTheme: IconThemeData(color: onSurface),
        actionsIconTheme: IconThemeData(color: muted),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: muted,
        indicatorColor: accent,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: outline,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        labelStyle: TextStyle(color: muted),
        floatingLabelStyle: TextStyle(color: accent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outlineFocus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: accentOn,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.4),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(color: accent, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.4),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: accentOn,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? accent : muted),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? accent.withValues(alpha: 0.35)
                : outline),
      ),

      dividerTheme: DividerThemeData(
          color: outline, thickness: 1, space: 1),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface2,
        contentTextStyle: TextStyle(color: onSurface),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      textTheme: base.textTheme.copyWith(
        headlineLarge:  TextStyle(color: onSurface, fontSize: 32,
            fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: onSurface, fontSize: 26,
            fontWeight: FontWeight.w700),
        headlineSmall:  TextStyle(color: onSurface, fontSize: 20,
            fontWeight: FontWeight.w600),
        titleLarge:     TextStyle(color: onSurface, fontSize: 17,
            fontWeight: FontWeight.w600),
        titleMedium:    TextStyle(color: onSurface, fontSize: 15,
            fontWeight: FontWeight.w500),
        bodyLarge:      TextStyle(color: onSurface, fontSize: 15),
        bodyMedium:     TextStyle(
            color: onSurface.withValues(alpha: 0.85), fontSize: 14),
        bodySmall:      TextStyle(color: muted, fontSize: 12),
        labelMedium:    TextStyle(color: muted, fontSize: 12,
            fontWeight: FontWeight.w500, letterSpacing: 0.6),
      ),
    );
  }
}
