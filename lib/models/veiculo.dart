/// Espelha a struct `Veiculo` do C (`native/autogest.h`).
///
/// O km atual NÃO é guardado aqui — ele é derivado do maior `km`
/// registrado na tabela de abastecimentos (ver [AbastecimentoDao]).
class Veiculo {
  const Veiculo({
    required this.nome,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.ano,
  });

  final String nome;
  final String placa;
  final String marca;
  final String modelo;
  final int ano;

  Map<String, Object?> toMap() => {
        'nome': nome,
        'placa': placa,
        'marca': marca,
        'modelo': modelo,
        'ano': ano,
      };

  factory Veiculo.fromMap(Map<String, Object?> map) => Veiculo(
        nome: map['nome'] as String? ?? '',
        placa: map['placa'] as String? ?? '',
        marca: map['marca'] as String? ?? '',
        modelo: map['modelo'] as String? ?? '',
        ano: (map['ano'] as int?) ?? 0,
      );
}
