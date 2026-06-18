import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Placeholder da aba Gráficos (será o histórico de consumo ao longo do
/// tempo quando o núcleo C fornecer a série).
class GraficosScreen extends StatelessWidget {
  const GraficosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gráficos')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart, size: 48, color: AppColors.textoSecundario),
              SizedBox(height: 12),
              Text(
                'Histórico de consumo — em breve',
                style: TextStyle(color: AppColors.textoSecundario),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
