import 'package:flutter/material.dart';

<<<<<<< HEAD
/// Design system único do Fhive.
///
/// Todas as telas devem usar SOMENTE estes tokens (cores, fontes, raios,
/// espaçamentos e estilos de texto). Valores fixos (`Color(0x...)`,
/// `fontSize: 13`, `BorderRadius.circular(17)`) não devem aparecer nas telas.
///
/// Escala visual:
///  - Fundo: gradiente amarelo ([AppGradients.main]).
///  - Cartões: creme ([AppColors.surfaceLight]) com raio [AppRadius.card].
///  - Texto e ícones: marrom ([AppColors.primary]).
///  - Botão principal: marrom com texto branco (definido no tema).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF964800);

  /// Marrom escuro: textos secundários, legendas e superfícies de destaque.
=======
/// Design system centralizado do Fhive.
///
/// As telas usam estes tokens para manter cores,
/// tipografia, espaçamentos e formas consistentes.
class AppColors {
  static const Color primary = Color(0xFF964800);

>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
  static const Color primaryDark = Color(0xFF6D3300);

  static const Color accent = Color(0xFFFFDE20);

  static const Color backgroundTop = Color(0xFFFFE832);

  static const Color backgroundMiddle = Color(0xFFFFCD1B);

  static const Color backgroundBottom = Color(0xFFF4A91A);

<<<<<<< HEAD
  /// Superfície amarelada para itens secundários.
  static const Color surface = Color(0xFFFFF6B5);

  /// Superfície para itens dentro de um painel ([surfaceStrong]).
  static const Color surfaceSoft = Color(0xFFFFF8CF);

  /// Cartão padrão (creme claro) e barra de navegação.
  static const Color surfaceLight = Color(0xFFFFFEF0);

  /// Painel que agrupa outros itens.
  static const Color surfaceStrong = Color(0xFFFFE86E);

  /// Superfície quente usada nos gráficos e seletores.
  static const Color surfaceWarm = Color(0xFFFFE8B0);

  /// Fundo dos campos de texto.
=======
  static const Color surface = Color(0xFFFFF6B5);

  static const Color surfaceSoft = Color(0xFFFFF8CF);

  static const Color surfaceLight = Color(0xFFFFFEF0);

  static const Color surfaceStrong = Color(0xFFFFE86E);

>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
  static const Color input = Color(0xFFFFFABE);

  static const Color divider = Color(0xFFB87817);

<<<<<<< HEAD
  /// Amarelo vivo para destaques e seleções.
=======
  static const Color danger = Color(0xFFE10D00);

  static const Color white = Colors.white;

  /// Amarelo vivo usado em detalhes e seleções das telas de autenticação.
>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
  static const Color highlight = Color(0xFFFFF261);

  /// Trilha/barra neutra dos gráficos e indicadores.
  static const Color track = Color(0xFFE8DDB8);

<<<<<<< HEAD
  static const Color white = Colors.white;

  /// Erro e ações destrutivas.
  static const Color danger = Color(0xFFE10D00);

  /// Estado positivo (ligado, conectado, economia).
  static const Color success = Color(0xFF438A37);

  static const Color successSoft = Color(0xFFD8F0C1);

  /// Alerta e valores em atenção.
  static const Color warning = Color(0xFFC46B00);
}

class AppFonts {
  AppFonts._();

  /// Títulos.
  static const String title = 'Arvo';

  /// Corpo de texto. Também é a fonte padrão do tema.
=======
  /// Superfície quente usada nos gráficos e seletores.
  static const Color surfaceWarm = Color(0xFFFFE8B0);

  /// Marrom escuro da tela de configurações.
  static const Color primaryDeep = Color(0xFF4A2100);

  /// Marrom dos cartões da tela de configurações.
  static const Color primaryCard = Color(0xFF663000);

  /// Creme claro usado nos controles da tela de configurações.
  static const Color cream = Color(0xFFFFFCEB);
}

class AppFonts {
  static const String title = 'Arvo';

>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
  static const String body = 'Montserrat';
}

class AppGradients {
<<<<<<< HEAD
  AppGradients._();

=======
>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
  static const LinearGradient main = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.backgroundTop,
      AppColors.backgroundMiddle,
      AppColors.backgroundBottom,
    ],
  );
<<<<<<< HEAD
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;

  static const double sm = 8;

  static const double md = 12;

  static const double lg = 16;

  static const double xl = 24;

=======

  static const LinearGradient auth = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF06A), Color(0xFFFFD91A), Color(0xFFFFBD00)],
  );
}

class AppSpacing {
>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
  static const double pageHorizontal = 20;

  static const double pageTop = 20;

  static const double pageBottom = 20;

<<<<<<< HEAD
  /// Espaço entre blocos/seções de uma página.
  static const double section = 20;

  /// Espaço entre cartões.
=======
  static const double section = 20;

>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
  static const double cardGap = 14;
}

class AppRadius {
<<<<<<< HEAD
  AppRadius._();

  /// Cartões, painéis e diálogos.
  static const double card = 18;

  /// Botões, campos de texto, itens internos de painéis e menus.
  static const double button = 14;

  /// Chips e etiquetas pequenas.
  static const double chip = 12;
=======
  static const double card = 18;

  static const double largeCard = 22;

  static const double button = 14;
>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0

  static const double bottomSheet = 25;

  static const double navigation = 28;
}

<<<<<<< HEAD
class AppShadows {
  AppShadows._();

  /// Sombra discreta para elementos que precisam se destacar do fundo.
  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x18000000), offset: Offset(0, 4), blurRadius: 12),
  ];
}

/// Estilos de texto. Escala: 24 · 19 · 16 · 14 · 12.
///
/// Para mudar apenas a cor use `.copyWith(color: ...)`.
class AppTextStyles {
  AppTextStyles._();

  /// Título grande de telas de entrada (login, cadastro, logo).
  static const TextStyle display = TextStyle(
    color: AppColors.primary,
    fontSize: 40,
    fontFamily: AppFonts.title,
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  /// Título da página (cabeçalho).
=======
class AppTextStyles {
>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
  static const TextStyle pageTitle = TextStyle(
    color: AppColors.primary,
    fontSize: 24,
    fontFamily: AppFonts.title,
    fontWeight: FontWeight.w800,
  );

<<<<<<< HEAD
  /// Título de seção dentro da página.
=======
>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.primary,
    fontSize: 19,
    fontFamily: AppFonts.title,
    fontWeight: FontWeight.w800,
  );

<<<<<<< HEAD
  /// Título de cartão, nome de aparelho, item de lista em destaque.
  static const TextStyle cardTitle = TextStyle(
    color: AppColors.primary,
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

=======
>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
  static const TextStyle body = TextStyle(
    color: AppColors.primary,
    fontFamily: AppFonts.body,
    fontSize: 14,
  );

  static const TextStyle bodyBold = TextStyle(
    color: AppColors.primary,
    fontFamily: AppFonts.body,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
<<<<<<< HEAD

  /// Legendas, subtítulos, status e textos de apoio.
  static const TextStyle caption = TextStyle(
    color: AppColors.primaryDark,
    fontFamily: AppFonts.body,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Texto de botões.
  static const TextStyle button = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  /// Rótulos pequenos de gráficos (eixos, legendas de pontos).
  static const TextStyle chartLabel = TextStyle(
    color: AppColors.primaryDark,
    fontFamily: AppFonts.body,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );
=======
>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
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
      child: SlideTransition(position: slideAnimation, child: child),
    );
  }
}

class AppTheme {
<<<<<<< HEAD
  AppTheme._();

  static ThemeData get data {
    final base = ThemeData.light(useMaterial3: true);

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    );

    OutlineInputBorder campoBorda([BorderSide lado = BorderSide.none]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
        borderSide: lado,
      );
    }

=======
  static ThemeData get data {
    final base = ThemeData.light(useMaterial3: true);

>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundTop,

      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
<<<<<<< HEAD
        onPrimary: AppColors.white,
        secondary: AppColors.accent,
        onSecondary: AppColors.primary,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.primary,
        error: AppColors.danger,
        onError: AppColors.white,
        surfaceTint: Colors.transparent,
      ),

      // Fonte do corpo e cor do texto padrão em todo o app.
      textTheme: base.textTheme
          .apply(
            fontFamily: AppFonts.body,
            bodyColor: AppColors.primary,
            displayColor: AppColors.primary,
          )
          .copyWith(titleLarge: AppTextStyles.sectionTitle),

      iconTheme: const IconThemeData(color: AppColors.primary),

      // AppBar das telas secundárias (Perfil, Ajuda): mesma cor do topo do
      // gradiente, para a barra e o fundo parecerem uma coisa só.
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundTop,
        foregroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.sectionTitle,
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.primary),
      ),

      // =====================================================
      // BOTÕES
      // =====================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.25),
          disabledForegroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: AppTextStyles.button,
          shape: buttonShape,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: AppTextStyles.button,
          shape: buttonShape,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.primary.withValues(alpha: 0.35),
          side: const BorderSide(color: AppColors.primary, width: 1.2),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: AppTextStyles.button,
          shape: buttonShape,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.bodyBold,
        ),
      ),

      // =====================================================
      // CAMPOS DE TEXTO
      // =====================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.input,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.primary.withValues(alpha: 0.68),
        ),
        labelStyle: AppTextStyles.body.copyWith(
          color: AppColors.primary.withValues(alpha: 0.85),
        ),
        floatingLabelStyle: AppTextStyles.bodyBold,
        helperStyle: AppTextStyles.caption,
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.danger),
        prefixIconColor: AppColors.primary,
        suffixIconColor: AppColors.primary,
        border: campoBorda(),
        enabledBorder: campoBorda(),
        disabledBorder: campoBorda(),
        focusedBorder: campoBorda(
          const BorderSide(color: AppColors.primary, width: 1.2),
        ),
        errorBorder: campoBorda(
          const BorderSide(color: AppColors.danger, width: 1.2),
        ),
        focusedErrorBorder: campoBorda(
          const BorderSide(color: AppColors.danger, width: 1.6),
        ),
      ),

      // =====================================================
      // CONTROLES
      // =====================================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.white
              : AppColors.primary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.surfaceStrong,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : AppColors.primary.withValues(alpha: 0.5),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.accent,
        checkmarkColor: AppColors.primary,
        labelStyle: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.16)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.primary.withValues(alpha: 0.15),
        thickness: 1,
        space: 1,
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.primary,
        textColor: AppColors.primary,
      ),

      expansionTileTheme: const ExpansionTileThemeData(
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.primary,
        textColor: AppColors.primary,
        collapsedTextColor: AppColors.primary,
        shape: Border(),
        collapsedShape: Border(),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.track,
      ),

      // =====================================================
      // MENUS, DIÁLOGOS E AVISOS
      // =====================================================
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        textStyle: AppTextStyles.body,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.10)),
=======
        secondary: AppColors.accent,
        surface: AppColors.surfaceLight,
        error: AppColors.danger,
      ),

      textTheme: base.textTheme.copyWith(
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          fontFamily: AppFonts.body,
          color: AppColors.primary,
        ),

        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontFamily: AppFonts.body,
          color: AppColors.primary,
        ),

        bodySmall: base.textTheme.bodySmall?.copyWith(
          fontFamily: AppFonts.body,
          color: AppColors.primary,
        ),

        titleLarge: AppTextStyles.sectionTitle,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        fillColor: AppColors.input,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: 10,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
<<<<<<< HEAD
          borderRadius: BorderRadius.circular(AppRadius.card),
=======
          borderRadius: BorderRadius.circular(22),
>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.10),
            width: 1,
          ),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.primary,
          fontFamily: AppFonts.body,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.primary,
          fontFamily: AppFonts.body,
          fontSize: 14,
          height: 1.4,
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      ),

<<<<<<< HEAD
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: const TextStyle(
          color: AppColors.white,
          fontFamily: AppFonts.body,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: buttonShape,
        // Mantém a mensagem acima da barra de navegação inferior
        // (68 px) para ela não cobrir os ícones de navegação.
        insetPadding: const EdgeInsets.fromLTRB(18, 0, 18, 80),
=======
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.primary,

        contentTextStyle: TextStyle(
          color: Colors.white,
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w600,
        ),

        behavior: SnackBarBehavior.floating,

        // Mantém a mensagem acima da barra de navegação inferior
        // (68 px) para ela não cobrir os ícones de navegação.
        insetPadding: EdgeInsets.fromLTRB(18, 0, 18, 80),
>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
<<<<<<< HEAD
        surfaceTintColor: Colors.transparent,
=======

>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheet),
          ),
        ),
      ),

      // =====================================================
      // TRANSIÇÃO SUAVE ENTRE AS TELAS
      // =====================================================
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SmoothPageTransitionsBuilder(),
<<<<<<< HEAD
          TargetPlatform.iOS: SmoothPageTransitionsBuilder(),
          TargetPlatform.windows: SmoothPageTransitionsBuilder(),
          TargetPlatform.macOS: SmoothPageTransitionsBuilder(),
=======

          TargetPlatform.iOS: SmoothPageTransitionsBuilder(),

          TargetPlatform.windows: SmoothPageTransitionsBuilder(),

          TargetPlatform.macOS: SmoothPageTransitionsBuilder(),

>>>>>>> bad908162c3cad30cc4e0aae7d34347b836cc1d0
          TargetPlatform.linux: SmoothPageTransitionsBuilder(),
        },
      ),
    );
  }
}
