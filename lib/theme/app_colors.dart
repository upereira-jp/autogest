import 'package:flutter/material.dart';

import '../models/enums.dart';

/// Paleta travada do tema escuro automotivo (briefing §3).
/// Não inventar cores — usar só estas constantes.
abstract final class AppColors {
  // Base
  static const fundo = Color(0xFF0E0F13);
  static const superficie = Color(0xFF181B22);
  static const borda = Color(0xFF262A33);
  static const acento = Color(0xFFF6A623); // âmbar painel
  static const texto = Color(0xFFF1F2F4);
  static const textoSecundario = Color(0xFF9A9DA6);

  // Status de alerta (correspondem ao enum StatusAlerta do C)
  static const vencido = Color(0xFFE5484D);
  static const proximo = Color(0xFFF6A623);
  static const emDia = Color(0xFF46C98B);

  /// Cor correspondente a um [StatusAlerta].
  static Color doStatus(StatusAlerta status) => switch (status) {
        StatusAlerta.vencido => vencido,
        StatusAlerta.proximo => proximo,
        StatusAlerta.emDia => emDia,
      };
}
