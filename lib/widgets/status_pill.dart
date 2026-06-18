import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../theme/app_colors.dart';

/// Pílula colorida com o status de um alerta de manutenção
/// (vencido / próximo / em dia), conforme o enum [StatusAlerta] do C.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final StatusAlerta status;

  @override
  Widget build(BuildContext context) {
    final cor = AppColors.doStatus(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cor),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: cor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
