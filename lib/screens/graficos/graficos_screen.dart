import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../../models/abastecimento.dart';
import '../../models/enums.dart';
import '../../models/manutencao.dart';
import '../../providers/abastecimento_provider.dart';
import '../../providers/manutencao_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/formatters.dart';

enum _ModoGasto { tudo, abastecimentos, manutencoes }

enum _CombustivelFiltro { todos, gasolina, alcool, diesel }

/// Aba de análise de gastos: consolida abastecimentos e manutenções com
/// filtros por período, tipo de gasto, combustível e tipo de manutenção.
class GraficosScreen extends StatefulWidget {
  const GraficosScreen({super.key});

  @override
  State<GraficosScreen> createState() => _GraficosScreenState();
}

class _GraficosScreenState extends State<GraficosScreen> {
  DateTimeRange? _periodo;
  _ModoGasto _modo = _ModoGasto.tudo;
  _CombustivelFiltro _combustivel = _CombustivelFiltro.todos;
  TipoManutencao? _tipoManutencao;

  Future<void> _atualizar() async {
    await Future.wait([
      context.read<AbastecimentoProvider>().carregar(),
      context.read<ManutencaoProvider>().carregar(),
    ]);
  }

  Future<void> _selecionarPeriodo() async {
    final hoje = DateTime.now();
    final inicial =
        _periodo ??
        DateTimeRange(start: DateTime(hoje.year, hoje.month), end: hoje);

    final escolhido = await showDateRangePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      firstDate: DateTime(2000),
      lastDate: hoje,
      currentDate: hoje,
      initialDateRange: inicial,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.acento,
            onPrimary: AppColors.fundo,
            surface: AppColors.superficie,
            onSurface: AppColors.texto,
          ),
        ),
        child: child!,
      ),
    );

    if (!mounted) return;
    if (escolhido != null) {
      setState(() => _periodo = escolhido);
    }
  }

  void _limparFiltros() {
    setState(() {
      _periodo = null;
      _modo = _ModoGasto.tudo;
      _combustivel = _CombustivelFiltro.todos;
      _tipoManutencao = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final abastecimentoProvider = context.watch<AbastecimentoProvider>();
    final manutencaoProvider = context.watch<ManutencaoProvider>();
    final carregando =
        abastecimentoProvider.carregando || manutencaoProvider.carregando;

    final resumo = _ResumoGraficos.from(
      abastecimentos: abastecimentoProvider.itens,
      manutencoes: manutencaoProvider.itens,
      periodo: _periodo,
      modo: _modo,
      combustivel: _combustivel,
      tipoManutencao: _tipoManutencao,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráficos de gastos'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: carregando ? null : _atualizar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _atualizar,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  _FiltrosCard(
                    periodo: _periodo,
                    modo: _modo,
                    combustivel: _combustivel,
                    tipoManutencao: _tipoManutencao,
                    onSelecionarPeriodo: _selecionarPeriodo,
                    onLimparPeriodo: () => setState(() => _periodo = null),
                    onLimparFiltros: _limparFiltros,
                    onModoChanged: (modo) {
                      setState(() {
                        _modo = modo;
                        if (modo == _ModoGasto.abastecimentos) {
                          _tipoManutencao = null;
                        }
                        if (modo == _ModoGasto.manutencoes) {
                          _combustivel = _CombustivelFiltro.todos;
                        }
                      });
                    },
                    onCombustivelChanged: (combustivel) {
                      setState(() => _combustivel = combustivel);
                    },
                    onTipoManutencaoChanged: (tipo) {
                      setState(() => _tipoManutencao = tipo);
                    },
                  ),
                  const SizedBox(height: 14),
                  _ResumoCards(resumo: resumo),
                  const SizedBox(height: 14),
                  _GraficoCard(resumo: resumo),
                  const SizedBox(height: 14),
                  _QuebrasSection(resumo: resumo),
                  const SizedBox(height: 14),
                  _UltimosGastosCard(eventos: resumo.eventosRecentes),
                ],
              ),
            ),
    );
  }
}

class _FiltrosCard extends StatelessWidget {
  const _FiltrosCard({
    required this.periodo,
    required this.modo,
    required this.combustivel,
    required this.tipoManutencao,
    required this.onSelecionarPeriodo,
    required this.onLimparPeriodo,
    required this.onLimparFiltros,
    required this.onModoChanged,
    required this.onCombustivelChanged,
    required this.onTipoManutencaoChanged,
  });

  final DateTimeRange? periodo;
  final _ModoGasto modo;
  final _CombustivelFiltro combustivel;
  final TipoManutencao? tipoManutencao;
  final VoidCallback onSelecionarPeriodo;
  final VoidCallback onLimparPeriodo;
  final VoidCallback onLimparFiltros;
  final ValueChanged<_ModoGasto> onModoChanged;
  final ValueChanged<_CombustivelFiltro> onCombustivelChanged;
  final ValueChanged<TipoManutencao?> onTipoManutencaoChanged;

  @override
  Widget build(BuildContext context) {
    final mostraAbastecimento = modo != _ModoGasto.manutencoes;
    final mostraManutencao = modo != _ModoGasto.abastecimentos;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.tune,
                  size: 18,
                  color: AppColors.textoSecundario,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Filtros',
                    style: TextStyle(
                      color: AppColors.texto,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onLimparFiltros,
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: const Text('Limpar'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: onSelecionarPeriodo,
                  icon: const Icon(Icons.date_range),
                  label: Text(_textoPeriodo(periodo)),
                ),
                if (periodo != null)
                  IconButton.outlined(
                    tooltip: 'Limpar período',
                    onPressed: onLimparPeriodo,
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            SegmentedButton<_ModoGasto>(
              segments: const [
                ButtonSegment(
                  value: _ModoGasto.tudo,
                  icon: Icon(Icons.stacked_bar_chart),
                  label: Text('Tudo'),
                ),
                ButtonSegment(
                  value: _ModoGasto.abastecimentos,
                  icon: Icon(Icons.local_gas_station),
                  label: Text('Abastec.'),
                ),
                ButtonSegment(
                  value: _ModoGasto.manutencoes,
                  icon: Icon(Icons.build),
                  label: Text('Manut.'),
                ),
              ],
              selected: {modo},
              showSelectedIcon: false,
              onSelectionChanged: (selecionado) =>
                  onModoChanged(selecionado.first),
            ),
            if (mostraAbastecimento) ...[
              const SizedBox(height: 14),
              const _FiltroRotulo('Combustível'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in _CombustivelFiltro.values)
                    ChoiceChip(
                      label: Text(item.label),
                      selected: combustivel == item,
                      onSelected: (_) => onCombustivelChanged(item),
                    ),
                ],
              ),
            ],
            if (mostraManutencao) ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                key: ValueKey(tipoManutencao?.index ?? -1),
                initialValue: tipoManutencao?.index ?? -1,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Tipo de manutenção',
                ),
                items: [
                  const DropdownMenuItem(
                    value: -1,
                    child: Text('Todas as manutenções'),
                  ),
                  for (final tipo in TipoManutencao.values)
                    DropdownMenuItem(
                      value: tipo.index,
                      child: Text(tipo.label),
                    ),
                ],
                onChanged: (valor) => onTipoManutencaoChanged(
                  valor == null || valor < 0
                      ? null
                      : TipoManutencao.values[valor],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _textoPeriodo(DateTimeRange? periodo) {
    if (periodo == null) return 'Todo período';
    return '${Fmt.data(periodo.start)} - ${Fmt.data(periodo.end)}';
  }
}

class _FiltroRotulo extends StatelessWidget {
  const _FiltroRotulo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Text(
    texto,
    style: const TextStyle(
      color: AppColors.textoSecundario,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _ResumoCards extends StatelessWidget {
  const _ResumoCards({required this.resumo});

  final _ResumoGraficos resumo;

  @override
  Widget build(BuildContext context) {
    final itens = [
      _ResumoItem(
        rotulo: 'Total',
        valor: Fmt.moeda(resumo.totalGeral),
        icone: Icons.payments_outlined,
      ),
      _ResumoItem(
        rotulo: 'Abastecimento',
        valor: Fmt.moeda(resumo.totalAbastecimentos),
        icone: Icons.local_gas_station_outlined,
      ),
      _ResumoItem(
        rotulo: 'Manutenção',
        valor: Fmt.moeda(resumo.totalManutencoes),
        icone: Icons.build_outlined,
      ),
      _ResumoItem(
        rotulo: 'Ticket médio',
        valor: resumo.totalRegistros == 0
            ? Fmt.moeda(0)
            : Fmt.moeda(resumo.totalGeral / resumo.totalRegistros),
        icone: Icons.receipt_long_outlined,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final colunas = constraints.maxWidth >= 720 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itens.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: colunas,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: constraints.maxWidth >= 720 ? 1.95 : 1.55,
          ),
          itemBuilder: (_, i) => _ResumoMetrica(item: itens[i]),
        );
      },
    );
  }
}

class _ResumoMetrica extends StatelessWidget {
  const _ResumoMetrica({required this.item});

  final _ResumoItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item.icone, size: 16, color: AppColors.textoSecundario),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.rotulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textoSecundario,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                item.valor,
                style: AppText.mono(size: 20, weight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GraficoCard extends StatelessWidget {
  const _GraficoCard({required this.resumo});

  final _ResumoGraficos resumo;

  @override
  Widget build(BuildContext context) {
    final titulo = resumo.granularidade == _Granularidade.mes
        ? 'Gastos por mês'
        : 'Gastos por dia';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.bar_chart,
                  size: 18,
                  color: AppColors.textoSecundario,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.texto,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _Legenda(modo: resumo.modo),
            const SizedBox(height: 12),
            if (resumo.barras.isEmpty)
              const _EstadoVazio()
            else
              SizedBox(
                height: 260,
                width: double.infinity,
                child: CustomPaint(
                  painter: _GastosChartPainter(
                    barras: resumo.barras,
                    modo: resumo.modo,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda({required this.modo});

  final _ModoGasto modo;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        if (modo != _ModoGasto.manutencoes)
          const _LegendaItem(texto: 'Abastecimento', cor: AppColors.acento),
        if (modo != _ModoGasto.abastecimentos)
          const _LegendaItem(texto: 'Manutenção', cor: AppColors.emDia),
      ],
    );
  }
}

class _LegendaItem extends StatelessWidget {
  const _LegendaItem({required this.texto, required this.cor});

  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          texto,
          style: const TextStyle(
            color: AppColors.textoSecundario,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _QuebrasSection extends StatelessWidget {
  const _QuebrasSection({required this.resumo});

  final _ResumoGraficos resumo;

  @override
  Widget build(BuildContext context) {
    final cards = [
      if (resumo.modo != _ModoGasto.manutencoes)
        _QuebraCard(
          titulo: 'Por combustível',
          icone: Icons.local_gas_station_outlined,
          cor: AppColors.acento,
          entradas: resumo.entradasCombustivel,
        ),
      if (resumo.modo != _ModoGasto.abastecimentos)
        _QuebraCard(
          titulo: 'Por manutenção',
          icone: Icons.build_outlined,
          cor: AppColors.emDia,
          entradas: resumo.entradasManutencao,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (cards.length == 2 && constraints.maxWidth >= 720) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
            ],
          );
        }

        return Column(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              cards[i],
              if (i != cards.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _QuebraCard extends StatelessWidget {
  const _QuebraCard({
    required this.titulo,
    required this.icone,
    required this.cor,
    required this.entradas,
  });

  final String titulo;
  final IconData icone;
  final Color cor;
  final List<_QuebraEntrada> entradas;

  @override
  Widget build(BuildContext context) {
    final maximo = entradas.fold<double>(
      0,
      (maior, item) => math.max(maior, item.valor),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, size: 18, color: AppColors.textoSecundario),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.texto,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (entradas.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  'Sem gastos para os filtros atuais.',
                  style: TextStyle(color: AppColors.textoSecundario),
                ),
              )
            else
              for (final entrada in entradas) ...[
                _LinhaQuebra(entrada: entrada, maximo: maximo, cor: cor),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

class _LinhaQuebra extends StatelessWidget {
  const _LinhaQuebra({
    required this.entrada,
    required this.maximo,
    required this.cor,
  });

  final _QuebraEntrada entrada;
  final double maximo;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final proporcao = maximo <= 0 ? 0.0 : entrada.valor / maximo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                entrada.rotulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.texto),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              Fmt.moeda(entrada.valor),
              style: AppText.mono(size: 13, color: AppColors.textoSecundario),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: proporcao.clamp(0, 1).toDouble(),
            minHeight: 8,
            backgroundColor: AppColors.borda,
            color: cor,
          ),
        ),
      ],
    );
  }
}

class _UltimosGastosCard extends StatelessWidget {
  const _UltimosGastosCard({required this.eventos});

  final List<_GastoEvento> eventos;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, size: 18, color: AppColors.textoSecundario),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Últimos gastos filtrados',
                    style: TextStyle(
                      color: AppColors.texto,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (eventos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Text(
                  'Nenhum gasto encontrado para os filtros atuais.',
                  style: TextStyle(color: AppColors.textoSecundario),
                ),
              )
            else
              for (var i = 0; i < eventos.length; i++) ...[
                _EventoTile(evento: eventos[i]),
                if (i != eventos.length - 1)
                  const Divider(height: 18, color: AppColors.borda),
              ],
          ],
        ),
      ),
    );
  }
}

class _EventoTile extends StatelessWidget {
  const _EventoTile({required this.evento});

  final _GastoEvento evento;

  @override
  Widget build(BuildContext context) {
    final abastecimento = evento.origem == _OrigemGasto.abastecimento;

    return Row(
      children: [
        Icon(
          abastecimento
              ? Icons.local_gas_station_outlined
              : Icons.build_outlined,
          size: 20,
          color: abastecimento ? AppColors.acento : AppColors.emDia,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                evento.titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.texto,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                Fmt.data(evento.data),
                style: const TextStyle(
                  color: AppColors.textoSecundario,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          Fmt.moeda(evento.valor),
          style: AppText.mono(size: 14, color: AppColors.texto),
        ),
      ],
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.query_stats, size: 42, color: AppColors.textoSecundario),
            SizedBox(height: 10),
            Text(
              'Nenhum gasto encontrado para os filtros atuais.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textoSecundario),
            ),
          ],
        ),
      ),
    );
  }
}

class _GastosChartPainter extends CustomPainter {
  const _GastosChartPainter({required this.barras, required this.modo});

  final List<_BarraPeriodo> barras;
  final _ModoGasto modo;

  @override
  void paint(Canvas canvas, Size size) {
    if (barras.isEmpty) return;

    const left = 56.0;
    const top = 12.0;
    const right = 8.0;
    const bottom = 42.0;
    final area = Rect.fromLTWH(
      left,
      top,
      size.width - left - right,
      size.height - top - bottom,
    );
    if (area.width <= 0 || area.height <= 0) return;

    final maximo = barras
        .map((b) => b.total)
        .fold<double>(0, (maior, valor) => math.max(maior, valor));
    final escalaMax = maximo <= 0 ? 1.0 : maximo;

    final gridPaint = Paint()
      ..color = AppColors.borda
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = area.bottom - area.height * (i / 4);
      canvas.drawLine(Offset(area.left, y), Offset(area.right, y), gridPaint);
      _drawText(
        canvas,
        _moedaCurta(escalaMax * (i / 4)),
        Offset(0, y - 8),
        const TextStyle(color: AppColors.textoSecundario, fontSize: 10),
        maxWidth: left - 8,
      );
    }

    final slot = area.width / barras.length;
    final barraLargura = math.max(4.0, math.min(28.0, slot * 0.62));
    final labelEvery = math.max(1, (barras.length / 6).ceil());

    for (var i = 0; i < barras.length; i++) {
      final barra = barras[i];
      final xCentro = area.left + slot * i + slot / 2;
      var yCursor = area.bottom;

      if (modo != _ModoGasto.manutencoes && barra.abastecimentos > 0) {
        final h = area.height * (barra.abastecimentos / escalaMax);
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            xCentro - barraLargura / 2,
            yCursor - h,
            barraLargura,
            h,
          ),
          const Radius.circular(3),
        );
        canvas.drawRRect(rect, Paint()..color = AppColors.acento);
        yCursor -= h;
      }

      if (modo != _ModoGasto.abastecimentos && barra.manutencoes > 0) {
        final h = area.height * (barra.manutencoes / escalaMax);
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            xCentro - barraLargura / 2,
            yCursor - h,
            barraLargura,
            h,
          ),
          const Radius.circular(3),
        );
        canvas.drawRRect(rect, Paint()..color = AppColors.emDia);
      }

      if (i % labelEvery == 0 || i == barras.length - 1) {
        _drawText(
          canvas,
          barra.label,
          Offset(xCentro - slot / 2, area.bottom + 10),
          const TextStyle(color: AppColors.textoSecundario, fontSize: 10),
          maxWidth: slot,
          textAlign: TextAlign.center,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GastosChartPainter oldDelegate) =>
      oldDelegate.barras != barras || oldDelegate.modo != modo;

  static void _drawText(
    Canvas canvas,
    String texto,
    Offset offset,
    TextStyle style, {
    required double maxWidth,
    TextAlign textAlign = TextAlign.left,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: texto, style: style),
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
      maxLines: 1,
      ellipsis: '...',
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, offset);
  }
}

class _ResumoGraficos {
  const _ResumoGraficos({
    required this.modo,
    required this.granularidade,
    required this.barras,
    required this.entradasCombustivel,
    required this.entradasManutencao,
    required this.eventosRecentes,
    required this.totalAbastecimentos,
    required this.totalManutencoes,
    required this.totalRegistros,
  });

  final _ModoGasto modo;
  final _Granularidade granularidade;
  final List<_BarraPeriodo> barras;
  final List<_QuebraEntrada> entradasCombustivel;
  final List<_QuebraEntrada> entradasManutencao;
  final List<_GastoEvento> eventosRecentes;
  final double totalAbastecimentos;
  final double totalManutencoes;
  final int totalRegistros;

  double get totalGeral => totalAbastecimentos + totalManutencoes;

  static _ResumoGraficos from({
    required List<Abastecimento> abastecimentos,
    required List<Manutencao> manutencoes,
    required DateTimeRange? periodo,
    required _ModoGasto modo,
    required _CombustivelFiltro combustivel,
    required TipoManutencao? tipoManutencao,
  }) {
    final usaAbastecimento = modo != _ModoGasto.manutencoes;
    final usaManutencao = modo != _ModoGasto.abastecimentos;

    final abastecimentosFiltrados = usaAbastecimento
        ? abastecimentos.where((a) {
            return _dentroDoPeriodo(a.data, periodo) &&
                combustivel.combinaCom(a.combustivel);
          }).toList()
        : <Abastecimento>[];

    final manutencoesFiltradas = usaManutencao
        ? manutencoes.where((m) {
            return _dentroDoPeriodo(m.data, periodo) &&
                (tipoManutencao == null || m.tipo == tipoManutencao);
          }).toList()
        : <Manutencao>[];

    final eventos = [
      for (final a in abastecimentosFiltrados)
        _GastoEvento(
          data: a.data,
          valor: a.valorTotal,
          origem: _OrigemGasto.abastecimento,
          titulo: _labelCombustivel(a.combustivel),
        ),
      for (final m in manutencoesFiltradas)
        _GastoEvento(
          data: m.data,
          valor: m.custo,
          origem: _OrigemGasto.manutencao,
          titulo: m.tipo.label,
        ),
    ]..sort((a, b) => a.data.compareTo(b.data));

    final granularidade = _granularidadePara(eventos, periodo);
    final barras = _barrasPorPeriodo(eventos, granularidade);
    final totalAbastecimentos = abastecimentosFiltrados.fold<double>(
      0,
      (soma, a) => soma + a.valorTotal,
    );
    final totalManutencoes = manutencoesFiltradas.fold<double>(
      0,
      (soma, m) => soma + m.custo,
    );

    final eventosRecentes = [...eventos]
      ..sort((a, b) => b.data.compareTo(a.data));

    return _ResumoGraficos(
      modo: modo,
      granularidade: granularidade,
      barras: barras,
      entradasCombustivel: _entradasCombustivel(abastecimentosFiltrados),
      entradasManutencao: _entradasManutencao(manutencoesFiltradas),
      eventosRecentes: eventosRecentes.take(6).toList(),
      totalAbastecimentos: totalAbastecimentos,
      totalManutencoes: totalManutencoes,
      totalRegistros:
          abastecimentosFiltrados.length + manutencoesFiltradas.length,
    );
  }

  static bool _dentroDoPeriodo(DateTime data, DateTimeRange? periodo) {
    if (periodo == null) return true;
    final inicio = DateTime(
      periodo.start.year,
      periodo.start.month,
      periodo.start.day,
    );
    final fimExclusivo = DateTime(
      periodo.end.year,
      periodo.end.month,
      periodo.end.day,
    ).add(const Duration(days: 1));
    return !data.isBefore(inicio) && data.isBefore(fimExclusivo);
  }

  static _Granularidade _granularidadePara(
    List<_GastoEvento> eventos,
    DateTimeRange? periodo,
  ) {
    if (periodo != null) {
      return periodo.duration.inDays > 92
          ? _Granularidade.mes
          : _Granularidade.dia;
    }
    if (eventos.length < 2) return _Granularidade.dia;
    final dias = eventos.last.data.difference(eventos.first.data).inDays.abs();
    return dias > 92 ? _Granularidade.mes : _Granularidade.dia;
  }

  static List<_BarraPeriodo> _barrasPorPeriodo(
    List<_GastoEvento> eventos,
    _Granularidade granularidade,
  ) {
    final parciais = <DateTime, _ParcialPeriodo>{};
    for (final evento in eventos) {
      final chave = granularidade == _Granularidade.mes
          ? DateTime(evento.data.year, evento.data.month)
          : DateTime(evento.data.year, evento.data.month, evento.data.day);
      final parcial = parciais.putIfAbsent(chave, _ParcialPeriodo.new);
      if (evento.origem == _OrigemGasto.abastecimento) {
        parcial.abastecimentos += evento.valor;
      } else {
        parcial.manutencoes += evento.valor;
      }
    }

    final datas = parciais.keys.toList()..sort();
    return [
      for (final data in datas)
        _BarraPeriodo(
          data: data,
          label: granularidade == _Granularidade.mes
              ? _fmtMes.format(data)
              : _fmtDia.format(data),
          abastecimentos: parciais[data]!.abastecimentos,
          manutencoes: parciais[data]!.manutencoes,
        ),
    ];
  }

  static List<_QuebraEntrada> _entradasCombustivel(
    List<Abastecimento> abastecimentos,
  ) {
    final totais = <String, double>{'Gasolina': 0, 'Álcool': 0, 'Diesel': 0};

    for (final abastecimento in abastecimentos) {
      final label = _labelCombustivel(abastecimento.combustivel);
      totais[label] = (totais[label] ?? 0) + abastecimento.valorTotal;
    }

    return _ordenarEntradas(totais);
  }

  static List<_QuebraEntrada> _entradasManutencao(
    List<Manutencao> manutencoes,
  ) {
    final totais = <String, double>{};
    for (final manutencao in manutencoes) {
      totais[manutencao.tipo.label] =
          (totais[manutencao.tipo.label] ?? 0) + manutencao.custo;
    }
    return _ordenarEntradas(totais);
  }

  static List<_QuebraEntrada> _ordenarEntradas(Map<String, double> totais) {
    final entradas = [
      for (final item in totais.entries)
        if (item.value > 0) _QuebraEntrada(item.key, item.value),
    ]..sort((a, b) => b.valor.compareTo(a.valor));
    return entradas;
  }
}

class _ResumoItem {
  const _ResumoItem({
    required this.rotulo,
    required this.valor,
    required this.icone,
  });

  final String rotulo;
  final String valor;
  final IconData icone;
}

class _BarraPeriodo {
  const _BarraPeriodo({
    required this.data,
    required this.label,
    required this.abastecimentos,
    required this.manutencoes,
  });

  final DateTime data;
  final String label;
  final double abastecimentos;
  final double manutencoes;

  double get total => abastecimentos + manutencoes;
}

class _ParcialPeriodo {
  double abastecimentos = 0;
  double manutencoes = 0;
}

class _QuebraEntrada {
  const _QuebraEntrada(this.rotulo, this.valor);

  final String rotulo;
  final double valor;
}

class _GastoEvento {
  const _GastoEvento({
    required this.data,
    required this.valor,
    required this.origem,
    required this.titulo,
  });

  final DateTime data;
  final double valor;
  final _OrigemGasto origem;
  final String titulo;
}

enum _OrigemGasto { abastecimento, manutencao }

enum _Granularidade { dia, mes }

extension on _CombustivelFiltro {
  String get label => switch (this) {
    _CombustivelFiltro.todos => 'Todos',
    _CombustivelFiltro.gasolina => 'Gasolina',
    _CombustivelFiltro.alcool => 'Álcool',
    _CombustivelFiltro.diesel => 'Diesel',
  };

  bool combinaCom(String combustivel) {
    if (this == _CombustivelFiltro.todos) return true;
    return _normalizarCombustivel(combustivel) == name;
  }
}

String _normalizarCombustivel(String valor) {
  final texto = valor.toLowerCase();
  if (texto.contains('diesel')) return 'diesel';
  if (texto.contains('alcool') ||
      texto.contains('álcool') ||
      texto.contains('etanol')) {
    return 'alcool';
  }
  return 'gasolina';
}

String _labelCombustivel(String valor) =>
    switch (_normalizarCombustivel(valor)) {
      'diesel' => 'Diesel',
      'alcool' => 'Álcool',
      _ => 'Gasolina',
    };

String _moedaCurta(double valor) {
  if (valor >= 1000000) {
    return 'R\$ ${(valor / 1000000).toStringAsFixed(1).replaceAll('.', ',')} mi';
  }
  if (valor >= 1000) {
    return 'R\$ ${(valor / 1000).toStringAsFixed(1).replaceAll('.', ',')} mil';
  }
  return 'R\$ ${valor.round()}';
}

final _fmtDia = intl.DateFormat('dd/MM', 'pt_BR');
final _fmtMes = intl.DateFormat('MMM/yy', 'pt_BR');
