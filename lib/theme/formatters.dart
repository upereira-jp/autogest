import 'package:intl/intl.dart';

/// Formatação pt-BR de números, dinheiro, km e datas.
///
/// Convenção de placeholder: qualquer valor derivado ainda não calculado
/// (a [MockService] devolve `double.nan`) é exibido como [placeholder]
/// — o traço "—". Assim a UI fica pronta e os números reais entram
/// sozinhos quando o núcleo em C assumir.
abstract final class Fmt {
  /// Texto exibido no lugar de um número ainda não calculado.
  static const String placeholder = '—';

  static final NumberFormat _doisDec =
      NumberFormat('#,##0.00', 'pt_BR');
  static final NumberFormat _umDec = NumberFormat('#,##0.0', 'pt_BR');
  static final NumberFormat _inteiro = NumberFormat('#,##0', 'pt_BR');
  static final NumberFormat _moeda =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  static final DateFormat _data = DateFormat('dd/MM/yyyy', 'pt_BR');

  /// Número genérico com 2 casas; "—" se [v] for `NaN`.
  static String numero(double v) => v.isNaN ? placeholder : _doisDec.format(v);

  /// Valor em reais; "R\$ —" se [v] for `NaN`.
  static String moeda(double v) =>
      v.isNaN ? 'R\$ $placeholder' : _moeda.format(v);

  /// Quilometragem (inteiro) com sufixo " km"; "— km" se `NaN`.
  static String km(double v) =>
      v.isNaN ? '$placeholder km' : '${_inteiro.format(v)} km';

  /// Consumo (km/L) com 1 casa e sufixo; "— km/L" se `NaN`.
  static String consumo(double v) =>
      v.isNaN ? '$placeholder km/L' : '${_umDec.format(v)} km/L';

  /// Litros com 2 casas e sufixo " L".
  static String litros(double v) =>
      v.isNaN ? '$placeholder L' : '${_doisDec.format(v)} L';

  /// Data no formato dd/MM/yyyy.
  static String data(DateTime d) => _data.format(d);
}
