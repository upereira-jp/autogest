import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/enums.dart';
import '../../models/manutencao.dart';
import '../../providers/manutencao_provider.dart';
import '../../widgets/campo_data.dart';
import '../../widgets/parse_num.dart';

/// Formulário de nova manutenção. Valida: intervalo > 0, custo ≥ 0,
/// data não futura. O campo `km_ultima` é preenchido pelo provider com o
/// km atual do veículo.
class ManutencaoForm extends StatefulWidget {
  const ManutencaoForm({super.key});

  @override
  State<ManutencaoForm> createState() => _ManutencaoFormState();
}

class _ManutencaoFormState extends State<ManutencaoForm> {
  final _formKey = GlobalKey<FormState>();
  final _descricao = TextEditingController();
  final _custo = TextEditingController();
  final _intervalo = TextEditingController();

  DateTime _data = DateTime.now();
  TipoManutencao _tipo = TipoManutencao.trocaOleo;

  @override
  void dispose() {
    _descricao.dispose();
    _custo.dispose();
    _intervalo.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final nova = Manutencao(
      tipo: _tipo,
      descricao: _descricao.text.trim(),
      data: _data,
      custo: parseNum(_custo.text) ?? 0,
      intervaloDias: int.parse(_intervalo.text.trim()),
    );
    await context.read<ManutencaoProvider>().adicionar(nova);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova manutenção')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<TipoManutencao>(
              initialValue: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: [
                for (final t in TipoManutencao.values)
                  DropdownMenuItem(value: t, child: Text(t.label)),
              ],
              onChanged: (v) => setState(() => _tipo = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricao,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
              ),
            ),
            const SizedBox(height: 16),
            CampoData(
              rotulo: 'Data',
              valor: _data,
              onChanged: (d) => setState(() => _data = d),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _custo,
              decoration: const InputDecoration(
                labelText: 'Custo',
                prefixText: r'R$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: (v) {
                final n = parseNum(v ?? '');
                if (n == null) return 'Informe o custo';
                if (n < 0) return 'Não pode ser negativo';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _intervalo,
              decoration: const InputDecoration(
                labelText: 'Intervalo',
                suffixText: 'dias',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null) return 'Informe o intervalo';
                if (n <= 0) return 'Deve ser maior que zero';
                return null;
              },
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _salvar,
              icon: const Icon(Icons.check),
              label: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
