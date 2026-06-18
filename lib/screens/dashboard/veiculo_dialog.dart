import 'package:flutter/material.dart';

import '../../models/veiculo.dart';

/// Diálogo simples para cadastrar/editar os dados do veículo.
/// Retorna o [Veiculo] preenchido, ou `null` se cancelado.
class VeiculoDialog extends StatefulWidget {
  const VeiculoDialog({super.key, this.inicial});

  final Veiculo? inicial;

  @override
  State<VeiculoDialog> createState() => _VeiculoDialogState();
}

class _VeiculoDialogState extends State<VeiculoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _marca;
  late final TextEditingController _modelo;
  late final TextEditingController _placa;
  late final TextEditingController _ano;

  @override
  void initState() {
    super.initState();
    final v = widget.inicial;
    _nome = TextEditingController(text: v?.nome ?? '');
    _marca = TextEditingController(text: v?.marca ?? '');
    _modelo = TextEditingController(text: v?.modelo ?? '');
    _placa = TextEditingController(text: v?.placa ?? '');
    _ano = TextEditingController(
        text: (v?.ano ?? 0) > 0 ? '${v!.ano}' : '');
  }

  @override
  void dispose() {
    _nome.dispose();
    _marca.dispose();
    _modelo.dispose();
    _placa.dispose();
    _ano.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      Veiculo(
        nome: _nome.text.trim(),
        marca: _marca.text.trim(),
        modelo: _modelo.text.trim(),
        placa: _placa.text.trim(),
        ano: int.tryParse(_ano.text.trim()) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Veículo'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _marca,
                decoration: const InputDecoration(labelText: 'Marca'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _modelo,
                decoration: const InputDecoration(labelText: 'Modelo'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _placa,
                decoration: const InputDecoration(labelText: 'Placa'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ano,
                decoration: const InputDecoration(labelText: 'Ano'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _salvar, child: const Text('Salvar')),
      ],
    );
  }
}
