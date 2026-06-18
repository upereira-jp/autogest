import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/veiculo.dart';
import '../../providers/dashboard_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/formatters.dart';
import '../../widgets/gauge_consumo.dart';
import '../../widgets/info_card.dart';
import '../../widgets/status_pill.dart';
import 'veiculo_dialog.dart';

/// Tela Início (dashboard): cabeçalho do veículo, medidor de consumo,
/// cards de gasto/custo e o alerta resumido.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DashboardProvider>();
    final veiculo = p.veiculo;

    return Scaffold(
      body: SafeArea(
        child: p.carregando
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: p.carregar,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _Cabecalho(
                      veiculo: veiculo,
                      kmAtual: p.kmAtual,
                      onEditar: () => _editarVeiculo(context, veiculo),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Consumo médio',
                        style: const TextStyle(
                          color: AppColors.textoSecundario,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GaugeConsumo(valor: p.consumoMedio),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: InfoCard(
                            rotulo: 'Gasto do mês',
                            valor: Fmt.moeda(p.gastoMes),
                            icone: Icons.calendar_month_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InfoCard(
                            rotulo: 'Custo por km',
                            valor: Fmt.moeda(p.custoPorKm),
                            icone: Icons.route_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _AlertaResumo(provider: p),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _editarVeiculo(BuildContext context, Veiculo? atual) async {
    final novo = await showDialog<Veiculo>(
      context: context,
      builder: (_) => VeiculoDialog(inicial: atual),
    );
    if (novo != null && context.mounted) {
      await context.read<DashboardProvider>().salvarVeiculo(novo);
    }
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({
    required this.veiculo,
    required this.kmAtual,
    required this.onEditar,
  });

  final Veiculo? veiculo;
  final double? kmAtual;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    final nome = veiculo?.nome.isNotEmpty == true ? veiculo!.nome : 'Meu carro';
    final modelo = [veiculo?.marca, veiculo?.modelo]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nome,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.texto,
                ),
              ),
              if (modelo.isNotEmpty)
                Text(
                  modelo,
                  style: const TextStyle(color: AppColors.textoSecundario),
                ),
              const SizedBox(height: 6),
              Text(
                kmAtual == null ? '${Fmt.placeholder} km' : Fmt.km(kmAtual!),
                style: AppText.mono(size: 15, color: AppColors.acento),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onEditar,
          icon: const Icon(Icons.edit_outlined, color: AppColors.textoSecundario),
          tooltip: 'Editar veículo',
        ),
      ],
    );
  }
}

class _AlertaResumo extends StatelessWidget {
  const _AlertaResumo({required this.provider});

  final DashboardProvider provider;

  @override
  Widget build(BuildContext context) {
    final alerta = provider.proximoAlerta;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.notifications_outlined,
                color: AppColors.textoSecundario),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Próxima manutenção',
                    style: TextStyle(
                      color: AppColors.textoSecundario,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alerta == null
                        ? 'Nenhum alerta no momento'
                        : '${alerta.tipo.label} • ${alerta.diasRestantes} dia(s)',
                    style: const TextStyle(color: AppColors.texto),
                  ),
                ],
              ),
            ),
            if (alerta != null) StatusPill(status: alerta.status),
          ],
        ),
      ),
    );
  }
}
