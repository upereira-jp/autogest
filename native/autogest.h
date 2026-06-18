#ifndef AUTOGEST_H
#define AUTOGEST_H

#include <time.h>   /* time_t */

/* ==================================================================== *
 *  AutoGest — Contrato FFI (header)
 *  Declara structs, enums, constantes e as 21 funcoes do nucleo em C.
 *  Implementacoes ficam em: dados.c, validacao.c, calculos.c, alertas.c
 *
 *  Convencoes:
 *   - Datas: time_t (inteiro). O Dart envia/recebe como numero.
 *   - Erros: int com valores do enum CodigoErro (0 = sucesso, <0 = erro).
 *   - Strings: recebidas como const char*, copiadas com strncpy.
 *   - Listas dinamicas: alocadas com malloc; liberadas pelo chamador.
 *   - Campos dormentes (km_ultima, intervalo_km, criterio): existem na
 *     struct mas nao geram comportamento na Fase 1.
 * ==================================================================== */

/* -------------------------------------------------------------------- *
 *  CONSTANTES
 * -------------------------------------------------------------------- */
#define MAX_NOME             50
#define MAX_PLACA             9
#define MAX_MARCA            30
#define MAX_MODELO           30
#define MAX_COMBUSTIVEL      20
#define MAX_DESCRICAO       100
#define JANELA_AVISO_PADRAO  30   /* dias de antecedencia do alerta "PROXIMO" */

/* -------------------------------------------------------------------- *
 *  ENUMS
 * -------------------------------------------------------------------- */
typedef enum {
    TROCA_OLEO,
    FILTRO_AR,
    FILTRO_COMBUSTIVEL,
    FILTRO_CABINE,
    PNEUS,
    CORREIA_DENTADA,
    ALINHAMENTO,
    BALANCEAMENTO,
    PASTILHA_FREIO,
    OUTROS,
    TOTAL_TIPOS_MANUTENCAO      /* sentinela — vale como contagem */
} TipoManutencao;

typedef enum {
    EM_DIA,
    PROXIMO,
    VENCIDO
} StatusAlerta;

typedef enum {
    POR_TEMPO,
    POR_KM,
    POR_AMBOS
} CriterioAlerta;

typedef enum {
    SUCESSO                 =  0,
    ERRO_KM_DECRESCENTE     = -1,
    ERRO_VALOR_NEGATIVO     = -2,
    ERRO_LITROS_NEGATIVO    = -3,
    ERRO_DATA_INVALIDA      = -4,
    ERRO_INTERVALO_INVALIDO = -5,
    ERRO_INDICE_INVALIDO    = -6,
    ERRO_MEMORIA            = -7,
    ERRO_CAMPO_VAZIO        = -8
} CodigoErro;

/* -------------------------------------------------------------------- *
 *  STRUCTS
 * -------------------------------------------------------------------- */
typedef struct {
    char nome[MAX_NOME];
    char placa[MAX_PLACA];
    char marca[MAX_MARCA];
    char modelo[MAX_MODELO];
    int  ano;
} Veiculo;

typedef struct {
    int    id;
    time_t data;
    double litros;
    double valor_total;
    double km;
    char   combustivel[MAX_COMBUSTIVEL];
} Abastecimento;

typedef struct {
    int            id;
    TipoManutencao tipo;
    char           descricao[MAX_DESCRICAO];
    time_t         data_realizada;
    double         custo;
    double         km_ultima;       /* dormente — preenchido pelo km atual */
    double         intervalo_km;    /* dormente — reservado para a Fase 2  */
    int            intervalo_dias;
    CriterioAlerta criterio;        /* Fase 1: sempre POR_TEMPO            */
} Manutencao;

typedef struct {
    int            id_manutencao;
    TipoManutencao tipo;
    StatusAlerta   status;
    int            dias_restantes;
    time_t         data_proxima;
} Alerta;

typedef struct {
    double gasto_por_mes[12];                            /* indice 0 = janeiro      */
    double gasto_por_categoria[TOTAL_TIPOS_MANUTENCAO];  /* indice = TipoManutencao */
    double total_abastecimentos;
    double total_manutencoes;
    double total_geral;
} ResumoGastos;

/* ==================================================================== *
 *  GRUPO 1 — DADOS   (src/dados.c)
 *  Preenchem e retornam uma struct. Nao validam — a validacao e feita
 *  antes, pelas funcoes do Grupo 2.
 * ==================================================================== */
Veiculo       criar_veiculo(const char* nome, const char* placa,
                            const char* marca, const char* modelo, int ano);

Abastecimento criar_abastecimento(int id, time_t data, double litros,
                                  double valor_total, double km,
                                  const char* combustivel);

Manutencao    criar_manutencao(int id, TipoManutencao tipo, const char* descricao,
                               time_t data_realizada, double custo,
                               int intervalo_dias);

/* ==================================================================== *
 *  GRUPO 2 — VALIDACAO   (src/validacao.c)
 *  Retornam int (CodigoErro): SUCESSO (0) ou um codigo negativo.
 * ==================================================================== */
int validar_km(double km_novo, double km_anterior);
int validar_data(time_t data);
int validar_valor(double valor);
int validar_litros(double litros);
int validar_intervalo_dias(int dias);

int editar_veiculo(Veiculo* v, const char* campo, const char* valor);
int editar_abastecimento(Abastecimento* a, const char* campo, const char* valor);
int editar_manutencao(Manutencao* m, const char* campo, const char* valor);

/* ==================================================================== *
 *  GRUPO 3 — CALCULOS   (src/calculos.c)
 *  Recebem vetores de registros (vindos do banco) e devolvem valores.
 * ==================================================================== */
double calcular_custo_por_km(Abastecimento* lista, int total,
                             double km_inicio, double km_fim);

double calcular_gasto_periodo(Abastecimento* lista, int total,
                              time_t inicio, time_t fim);

double calcular_km_por_litro(double km_atual, double km_anterior, double litros);

double obter_km_atual(Abastecimento* lista, int total);

double calcular_km_por_litro_geral(Abastecimento* lista, int total);

ResumoGastos calcular_resumo_gastos(Abastecimento* abastecimentos, int total_abast,
                                    Manutencao* manutencoes, int total_manut);

/* ==================================================================== *
 *  GRUPO 4 — MOTOR DE ALERTAS   (src/alertas.c)
 *  gerar_lista_alertas aloca com malloc; o chamador libera com
 *  liberar_lista_alertas (seguro chamar com NULL).
 * ==================================================================== */
int          calcular_dias_restantes(time_t data_realizada, int intervalo_dias,
                                     time_t hoje);

StatusAlerta classificar_alerta(int dias_restantes, int janela_aviso);

Alerta*      gerar_lista_alertas(Manutencao* manutencoes, int total_manut,
                                 time_t hoje, int janela_aviso,
                                 int* total_alertas);

void         liberar_lista_alertas(Alerta* lista);

#endif /* AUTOGEST_H */
