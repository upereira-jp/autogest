/// Enums que espelham os `typedef enum` do núcleo em C (`native/autogest.h`).
///
/// A ORDEM dos valores aqui é idêntica à do header — o índice de cada
/// valor (`Enum.index`) corresponde ao inteiro usado pelo C e pelo SQLite.
/// Não reordenar.
library;

/// Categorias de manutenção — espelha `TipoManutencao` do C.
///
/// O sentinela `TOTAL_TIPOS_MANUTENCAO` do header é apenas a contagem
/// (= 10) e por isso não vira um valor de enum aqui.
enum TipoManutencao {
  trocaOleo('Troca de óleo'),
  filtroAr('Filtro de ar'),
  filtroCombustivel('Filtro de combustível'),
  filtroCabine('Filtro de cabine'),
  pneus('Pneus'),
  correiaDentada('Correia dentada'),
  alinhamento('Alinhamento'),
  balanceamento('Balanceamento'),
  pastilhaFreio('Pastilha de freio'),
  outros('Outros');

  const TipoManutencao(this.label);

  /// Rótulo em PT-BR exibido na UI (dropdowns, listas).
  final String label;
}

/// Situação de um alerta de manutenção — espelha `StatusAlerta` do C.
enum StatusAlerta {
  emDia('Em dia'),
  proximo('Próximo'),
  vencido('Vencido');

  const StatusAlerta(this.label);

  final String label;
}

/// Critério que dispara um alerta — espelha `CriterioAlerta` do C.
///
/// Na Fase 1 todas as manutenções usam [porTempo]; os demais valores
/// existem para casar com o header e ficam reservados para a Fase 2.
enum CriterioAlerta {
  porTempo,
  porKm,
  porAmbos,
}
