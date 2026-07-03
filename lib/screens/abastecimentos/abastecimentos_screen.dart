import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/abastecimento.dart';
import '../../providers/abastecimento_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/formatters.dart';
import 'abastecimento_form.dart';

/// Lista de abastecimentos. O km/L de cada trecho é derivado → "—" no mock.
class AbastecimentosScreen extends StatelessWidget {
  const AbastecimentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AbastecimentoProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Abastecimentos')),
      body: p.carregando
          ? const Center(child: CircularProgressIndicator())
          : p.itens.isEmpty
          ? const _Vazio()
          : RefreshIndicator(
              onRefresh: p.carregar,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: p.itens.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final a = p.itens[i];
                  return _AbastecimentoTile(
                    abastecimento: a,
                    kmPorLitro: p.kmPorLitroDe(a),
                  );
                },
              ),
            ),
    );
  }
}

class _AbastecimentoTile extends StatelessWidget {
  const _AbastecimentoTile({
    required this.abastecimento,
    required this.kmPorLitro,
  });

  final Abastecimento abastecimento;
  final double kmPorLitro;

  @override
  Widget build(BuildContext context) {
    final a = abastecimento;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    a.combustivel.isEmpty ? 'Abastecimento' : a.combustivel,
                    style: const TextStyle(
                      color: AppColors.texto,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  Fmt.moeda(a.valorTotal),
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
            const SizedBox(height: 4),
            Text(
              Fmt.data(a.data),
              style: const TextStyle(
                color: AppColors.textoSecundario,
                fontSize: 12,
              ),
            ),
            const Divider(height: 18, color: AppColors.borda),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Metrica(rotulo: 'Litros', valor: Fmt.litros(a.litros)),
                _Metrica(rotulo: 'Km', valor: Fmt.km(a.km)),
                _Metrica(rotulo: 'Consumo', valor: Fmt.consumo(kmPorLitro)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editar(BuildContext context) async {
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AbastecimentoForm(abastecimento: abastecimento),
      ),
    );

    if (salvou == true && context.mounted) {
      await context.read<DashboardProvider>().carregar();
    }
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          rotulo,
          style: const TextStyle(
            color: AppColors.textoSecundario,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(valor, style: AppText.mono(size: 13)),
      ],
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_gas_station_outlined,
              size: 48,
              color: AppColors.textoSecundario,
            ),
            SizedBox(height: 12),
            Text(
              'Nenhum abastecimento ainda.\nToque em "+" para registrar o primeiro.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textoSecundario),
            ),
          ],
        ),
      ),
    );
  }
}
