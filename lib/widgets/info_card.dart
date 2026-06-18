import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Card compacto com um rótulo e um valor numérico em fonte mono — usado
/// nos dois cards do dashboard (gasto do mês, custo por km).
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.rotulo,
    required this.valor,
    this.icone,
  });

  final String rotulo;
  final String valor;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icone != null) ...[
                  Icon(icone, size: 16, color: AppColors.textoSecundario),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    rotulo,
                    style: const TextStyle(
                      color: AppColors.textoSecundario,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              valor,
              style: AppText.mono(size: 20, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
