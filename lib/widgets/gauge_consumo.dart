import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/formatters.dart';

/// Medidor semicircular (gauge) do consumo médio — o "herói" do dashboard.
///
/// Desenhado à mão com [CustomPainter] (sem dependências). Mostra o valor
/// em km/L como ponteiro sobre um arco; quando [valor] é `NaN` (placeholder
/// do mock), o arco fica vazio, o ponteiro no mínimo e o centro exibe "—".
class GaugeConsumo extends StatelessWidget {
  const GaugeConsumo({
    super.key,
    required this.valor,
    this.maximo = 20,
  });

  /// Consumo em km/L (pode ser `NaN` = ainda não calculado).
  final double valor;

  /// Fim da escala do medidor (km/L).
  final double maximo;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: CustomPaint(
        painter: _GaugePainter(valor: valor, maximo: maximo),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.valor, required this.maximo});

  final double valor;
  final double maximo;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = Offset(size.width / 2, size.height * 0.92);
    final raio = math.min(size.width * 0.46, size.height * 0.92);
    final rect = Rect.fromCircle(center: centro, radius: raio);

    const inicio = math.pi; // semicírculo superior (esquerda → direita)
    const total = math.pi;

    final temValor = !valor.isNaN;
    final fracao = temValor ? (valor / maximo).clamp(0.0, 1.0) : 0.0;

    // Trilho de fundo.
    final trilho = Paint()
      ..color = AppColors.borda
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, inicio, total, false, trilho);

    // Arco do valor.
    if (temValor && fracao > 0) {
      final arco = Paint()
        ..color = AppColors.acento
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, inicio, total * fracao, false, arco);
    }

    // Marcas (ticks) a cada 1/8 da escala.
    final tick = Paint()
      ..color = AppColors.textoSecundario
      ..strokeWidth = 2;
    for (var i = 0; i <= 8; i++) {
      final ang = inicio + total * (i / 8);
      final p1 = centro + Offset(math.cos(ang), math.sin(ang)) * (raio - 22);
      final p2 = centro + Offset(math.cos(ang), math.sin(ang)) * (raio - 14);
      canvas.drawLine(p1, p2, tick);
    }

    // Ponteiro.
    final angPonteiro = inicio + total * fracao;
    final ponta =
        centro + Offset(math.cos(angPonteiro), math.sin(angPonteiro)) * (raio - 26);
    final ponteiro = Paint()
      ..color = temValor ? AppColors.acento : AppColors.textoSecundario
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(centro, ponta, ponteiro);
    canvas.drawCircle(centro, 7, Paint()..color = AppColors.texto);
    canvas.drawCircle(
        centro, 7, Paint()
      ..color = AppColors.acento
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);

    // Valor central + unidade.
    _texto(
      canvas,
      temValor ? Fmt.numero(valor) : Fmt.placeholder,
      Offset(centro.dx, centro.dy - raio * 0.42),
      AppText.mono(size: 30, weight: FontWeight.w600, color: AppColors.texto),
    );
    _texto(
      canvas,
      'km/L',
      Offset(centro.dx, centro.dy - raio * 0.18),
      const TextStyle(color: AppColors.textoSecundario, fontSize: 13),
    );
  }

  void _texto(Canvas canvas, String texto, Offset centro, TextStyle estilo) {
    final tp = TextPainter(
      text: TextSpan(text: texto, style: estilo),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, centro - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.valor != valor || old.maximo != maximo;
}
