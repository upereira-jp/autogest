import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/alerta.dart';
import '../../models/manutencao.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/manutencao_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/formatters.dart';
import '../../widgets/status_pill.dart';
import 'manutencao_form.dart';

/// Manutenções: alertas (status + dias restantes) no topo e a lista das
/// manutenções realizadas. Status e dias são derivados → vazios no mock.
class ManutencoesScreen extends StatelessWidget {
  const ManutencoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ManutencaoProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manutenções')),
      body: p.carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: p.carregar,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  if (p.alertas.isNotEmpty) ...[
                    const _TituloSecao('Alertas'),
                    const SizedBox(height: 8),
                    for (final a in p.alertas) _AlertaTile(alerta: a),
                    const SizedBox(height: 16),
                  ],
                  const _TituloSecao('Realizadas'),
                  const SizedBox(height: 8),
                  if (p.itens.isEmpty)
                    const _Vazio()
                  else
                    for (final m in p.itens) ...[
                      _ManutencaoTile(manutencao: m),
                      const SizedBox(height: 10),
                    ],
                ],
              ),
            ),
    );
  }
}

class _TituloSecao extends StatelessWidget {
  const _TituloSecao(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Text(
    texto,
    style: const TextStyle(
      color: AppColors.texto,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _AlertaTile extends StatelessWidget {
  const _AlertaTile({required this.alerta});
  final Alerta alerta;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alerta.tipo.label,
                    style: const TextStyle(
                      color: AppColors.texto,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${alerta.diasRestantes} dia(s) restante(s)',
                    style: const TextStyle(
                      color: AppColors.textoSecundario,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            StatusPill(status: alerta.status),
          ],
        ),
      ),
    );
  }
}

class _ManutencaoTile extends StatelessWidget {
  const _ManutencaoTile({required this.manutencao});
  final Manutencao manutencao;

  @override
  Widget build(BuildContext context) {
    final m = manutencao;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.tipo.label,
                    style: const TextStyle(
                      color: AppColors.texto,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (m.descricao.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      m.descricao,
                      style: const TextStyle(color: AppColors.textoSecundario),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${Fmt.data(m.data)} • a cada ${m.intervaloDias} dia(s)',
                    style: const TextStyle(
                      color: AppColors.textoSecundario,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              Fmt.moeda(m.custo),
              style: AppText.mono(size: 15, color: AppColors.acento),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Editar',
              onPressed: () => _editar(context),
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.textoSecundario,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editar(BuildContext context) async {
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ManutencaoForm(manutencao: manutencao)),
    );

    if (salvou == true && context.mounted) {
      await context.read<DashboardProvider>().carregar();
    }
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          'Nenhuma manutenção registrada.\nToque em "+" para adicionar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textoSecundario),
        ),
      ),
    );
  }
}
