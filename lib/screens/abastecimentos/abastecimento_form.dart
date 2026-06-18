import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/abastecimento.dart';
import '../../providers/abastecimento_provider.dart';
import '../../theme/formatters.dart';
import '../../widgets/campo_data.dart';
import '../../widgets/parse_num.dart';

/// Formulário de novo abastecimento. Valida: litros e valor > 0,
/// km ≥ último registrado, data não futura.
class AbastecimentoForm extends StatefulWidget {
  const AbastecimentoForm({super.key});

  @override
  State<AbastecimentoForm> createState() => _AbastecimentoFormState();
}

class _AbastecimentoFormState extends State<AbastecimentoForm> {
  static const _combustiveis = ['Gasolina', 'Etanol', 'Diesel'];

  final _formKey = GlobalKey<FormState>();
  final _litros = TextEditingController();
  final _valor = TextEditingController();
  final _km = TextEditingController();

  DateTime _data = DateTime.now();
  String _combustivel = _combustiveis.first;

  @override
  void dispose() {
    _litros.dispose();
    _valor.dispose();
    _km.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    final novo = Abastecimento(
      data: _data,
      litros: parseNum(_litros.text)!,
      valorTotal: parseNum(_valor.text)!,
      km: parseNum(_km.text)!,
      combustivel: _combustivel,
    );
    await context.read<AbastecimentoProvider>().adicionar(novo);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final ultimoKm = context.read<AbastecimentoProvider>().ultimoKm;

    return Scaffold(
      appBar: AppBar(title: const Text('Novo abastecimento')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CampoData(
              rotulo: 'Data',
              valor: _data,
              onChanged: (d) => setState(() => _data = d),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _combustivel,
              decoration: const InputDecoration(labelText: 'Combustível'),
              items: [
                for (final c in _combustiveis)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (v) => setState(() => _combustivel = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _litros,
              decoration: const InputDecoration(
                labelText: 'Litros',
                suffixText: 'L',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_numFmt],
              validator: (v) => _validarPositivo(v, 'Informe os litros'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valor,
              decoration: const InputDecoration(
                labelText: 'Valor total',
                prefixText: r'R$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_numFmt],
              validator: (v) => _validarPositivo(v, 'Informe o valor'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _km,
              decoration: InputDecoration(
                labelText: 'Quilometragem',
                suffixText: 'km',
                helperText: ultimoKm == null
                    ? null
                    : 'Último registrado: ${Fmt.km(ultimoKm)}',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_numFmt],
              validator: (v) => _validarKm(v, ultimoKm),
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

  static final _numFmt =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

  String? _validarPositivo(String? v, String vazio) {
    final n = parseNum(v ?? '');
    if (n == null) return vazio;
    if (n <= 0) return 'Deve ser maior que zero';
    return null;
  }

  String? _validarKm(String? v, double? ultimoKm) {
    final n = parseNum(v ?? '');
    if (n == null) return 'Informe o km';
    if (n < 0) return 'Km inválido';
    if (ultimoKm != null && n < ultimoKm) {
      return 'Não pode ser menor que ${Fmt.km(ultimoKm)}';
    }
    return null;
  }
}
