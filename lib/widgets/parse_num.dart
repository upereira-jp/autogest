/// Converte um texto digitado (pt-BR) em [double].
///
/// Aceita vírgula ou ponto como separador decimal: "45,50" e "45.50" viram
/// 45.5. Retorna `null` se o texto não for um número válido.
double? parseNum(String texto) {
  final limpo = texto.trim().replaceAll(',', '.');
  if (limpo.isEmpty) return null;
  return double.tryParse(limpo);
}
