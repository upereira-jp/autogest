import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema escuro automotivo do AutoGest (briefing §3): fundo quase preto,
/// superfícies/cards levemente mais claras, bordas sutis, acento âmbar,
/// cantos arredondados (~12px).
abstract final class AppTheme {
  /// Raio padrão dos cantos (cards, campos, botões).
  static const double raio = 12;

  /// Família monoespaçada para números (km/L, R$, km) — ar de mostrador.
  static const String fonteMono = 'RobotoMono';

  static ThemeData get dark {
    const acento = AppColors.acento;
    final base = ThemeData.dark(useMaterial3: true);

    final colorScheme = const ColorScheme.dark(
      primary: acento,
      onPrimary: AppColors.fundo,
      secondary: acento,
      surface: AppColors.superficie,
      onSurface: AppColors.texto,
      error: AppColors.vencido,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.fundo,
      colorScheme: colorScheme,
      canvasColor: AppColors.fundo,
      dividerColor: AppColors.borda,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.texto,
        displayColor: AppColors.texto,
      ),
      cardTheme: CardThemeData(
        color: AppColors.superficie,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(raio),
          side: const BorderSide(color: AppColors.borda),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fundo,
        foregroundColor: AppColors.texto,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: acento,
        foregroundColor: AppColors.fundo,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.superficie,
        selectedItemColor: acento,
        unselectedItemColor: AppColors.textoSecundario,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.superficie,
        hintStyle: const TextStyle(color: AppColors.textoSecundario),
        labelStyle: const TextStyle(color: AppColors.textoSecundario),
        enabledBorder: _borda(AppColors.borda),
        focusedBorder: _borda(acento),
        errorBorder: _borda(AppColors.vencido),
        focusedErrorBorder: _borda(AppColors.vencido),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(AppColors.superficie),
        ),
      ),
    );
  }

  static OutlineInputBorder _borda(Color cor) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(raio),
        borderSide: BorderSide(color: cor),
      );
}

/// Helpers de texto. Use [AppText.mono] para qualquer número que deva ter
/// aparência de mostrador de painel.
abstract final class AppText {
  /// Estilo monoespaçado (RobotoMono) para números.
  static TextStyle mono({
    double size = 16,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.texto,
    double? height,
  }) =>
      TextStyle(
        fontFamily: AppTheme.fonteMono,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );
}
