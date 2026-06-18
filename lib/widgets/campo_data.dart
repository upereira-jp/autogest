import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/formatters.dart';

/// Campo de seleção de data que nunca permite uma data futura
/// (validação visual do briefing: "data não pode ser futura").
class CampoData extends StatelessWidget {
  const CampoData({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.onChanged,
  });

  final String rotulo;
  final DateTime valor;
  final ValueChanged<DateTime> onChanged;

  Future<void> _escolher(BuildContext context) async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: valor,
      firstDate: DateTime(2000),
      lastDate: hoje, // bloqueia datas futuras
    );
    if (escolhida != null) onChanged(escolhida);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.raio),
      onTap: () => _escolher(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: rotulo,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(
          Fmt.data(valor),
          style: AppText.mono(size: 15, color: AppColors.texto),
        ),
      ),
    );
  }
}
