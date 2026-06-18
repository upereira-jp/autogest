import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/dashboard_provider.dart';
import 'abastecimentos/abastecimento_form.dart';
import 'abastecimentos/abastecimentos_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'graficos/graficos_screen.dart';
import 'manutencoes/manutencao_form.dart';
import 'manutencoes/manutencoes_screen.dart';

/// Casca do app: barra de navegação inferior com 4 abas e o FAB âmbar
/// contextual (aparece em Abastecimentos e Manutenções para adicionar).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _aba = 0;

  static const _telas = [
    DashboardScreen(),
    AbastecimentosScreen(),
    ManutencoesScreen(),
    GraficosScreen(),
  ];

  /// Abre o formulário da aba atual; ao salvar, atualiza o dashboard.
  Future<void> _adicionar() async {
    final salvou = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            _aba == 1 ? const AbastecimentoForm() : const ManutencaoForm(),
      ),
    );
    if (salvou == true && mounted) {
      await context.read<DashboardProvider>().carregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mostraFab = _aba == 1 || _aba == 2;
    return Scaffold(
      body: IndexedStack(index: _aba, children: _telas),
      floatingActionButton: mostraFab
          ? FloatingActionButton(
              onPressed: _adicionar,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _aba,
        onTap: (i) => setState(() => _aba = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.speed_outlined),
            activeIcon: Icon(Icons.speed),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_gas_station_outlined),
            activeIcon: Icon(Icons.local_gas_station),
            label: 'Abastecimentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build),
            label: 'Manutenções',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            activeIcon: Icon(Icons.show_chart),
            label: 'Gráficos',
          ),
        ],
      ),
    );
  }
}
