import 'package:flutter/material.dart';

/// Design system centralizado do Fhive.
///
/// As telas usam estes tokens para manter cores,
/// tipografia, espaçamentos e formas consistentes.
class AppColors {
  static const Color primary = Color(0xFF964800);

  static const Color primaryDark = Color(0xFF6D3300);

  static const Color accent = Color(0xFFFFDE20);

  static const Color backgroundTop = Color(0xFFFFE832);

  static const Color backgroundMiddle = Color(0xFFFFCD1B);

  static const Color backgroundBottom = Color(0xFFF4A91A);

  static const Color surface = Color(0xFFFFF6B5);

  static const Color surfaceSoft = Color(0xFFFFF8CF);

  static const Color surfaceLight = Color(0xFFFFFEF0);

  static const Color surfaceStrong = Color(0xFFFFE86E);

  static const Color input = Color(0xFFFFFABE);

  static const Color divider = Color(0xFFB87817);

  static const Color danger = Color(0xFFE10D00);

  static const Color white = Colors.white;
}

class AppGradients {
  static const LinearGradient main = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.backgroundTop,
      AppColors.backgroundMiddle,
      AppColors.backgroundBottom,
    ],
  );

  static const LinearGradient auth = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF06A),
      Color(0xFFFFD91A),
      Color(0xFFFFBD00),
    ],
  );
}

class AppSpacing {
  static const double pageHorizontal = 20;

  static const double pageTop = 20;

  static const double pageBottom = 20;

  static const double section = 20;

  static const double cardGap = 14;
}

class AppRadius {
  static const double card = 18;

  static const double largeCard = 22;

  static const double button = 14;

  static const double bottomSheet = 25;

  static const double navigation = 28;
}

class AppTextStyles {
  static const TextStyle pageTitle = TextStyle(
    color: AppColors.primary,
    fontSize: 24,
    fontFamily: 'Arvo',
    fontWeight: FontWeight.w800,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.primary,
    fontSize: 19,
    fontFamily: 'Arvo',
    fontWeight: FontWeight.w800,
  );

  static const TextStyle body = TextStyle(
    color: AppColors.primary,
    fontFamily: 'Montserrat',
    fontSize: 14,
  );

  static const TextStyle bodyBold = TextStyle(
    color: AppColors.primary,
    fontFamily: 'Montserrat',
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
}

/// Transição suave utilizada entre as telas do aplicativo.
///
/// Combina um pequeno movimento lateral com fade,
/// deixando a navegação mais fluida.
class SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(curvedAnimation);

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curvedAnimation);

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
}

class AppTheme {
  static ThemeData get data {
    final base = ThemeData.light(
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundTop,

      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surfaceLight,
        error: AppColors.danger,
      ),

      textTheme: base.textTheme.copyWith(
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          fontFamily: 'Montserrat',
          color: AppColors.primary,
        ),

        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontFamily: 'Montserrat',
          color: AppColors.primary,
        ),

        bodySmall: base.textTheme.bodySmall?.copyWith(
          fontFamily: 'Montserrat',
          color: AppColors.primary,
        ),

        titleLarge: AppTextStyles.sectionTitle,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        fillColor: AppColors.input,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.button,
          ),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.button,
          ),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppRadius.button,
          ),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.2,
          ),
        ),
      ),

      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surfaceLight,

        titleTextStyle: TextStyle(
          color: AppColors.primary,
          fontFamily: 'Montserrat',
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),

        contentTextStyle: TextStyle(
          color: AppColors.primary,
          fontFamily: 'Montserrat',
          fontSize: 14,
        ),
      ),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.primary,

        contentTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
        ),

        behavior: SnackBarBehavior.floating,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              AppRadius.bottomSheet,
            ),
          ),
        ),
      ),

      // =====================================================
      // TRANSIÇÃO SUAVE ENTRE AS TELAS
      // =====================================================

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android:
              SmoothPageTransitionsBuilder(),

          TargetPlatform.iOS:
              SmoothPageTransitionsBuilder(),

          TargetPlatform.windows:
              SmoothPageTransitionsBuilder(),

          TargetPlatform.macOS:
              SmoothPageTransitionsBuilder(),

          TargetPlatform.linux:
              SmoothPageTransitionsBuilder(),
        },
      ),
    );
  }
}