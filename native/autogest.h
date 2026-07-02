#ifndef AUTOGEST_H
#define AUTOGEST_H

//#include <time.h> time_t 
#include <stdint.h>
/* ==================================================================== *
 *  Declara as funções do nucleo em C.
 *
 *  Convenções:
 *   - Datas: int64_t (inteiro). O Dart envia/recebe como numero.
 *   - Erros: int com valores do enum CodigoErro (0 = sucesso, <0 = erro).
 *   - Strings: recebidas como const char*, copiadas com strncpy.
 *   - Listas dinamicas: alocadas com malloc; liberadas pelo chamador.
 *   - Campos que não estçao sendo utilizados no momento: km_ultima, intervalo_km, criterio.
 * ==================================================================== */

//Constantes
#define MAX_NOME             50
#define MAX_PLACA             9
#define MAX_MARCA            30
#define MAX_MODELO           30
#define MAX_COMBUSTIVEL      20
#define MAX_DESCRICAO       100
#define JANELA_AVISO_PADRAO  30   /* dias de antecedencia do alerta "PROXIMO" */

//enums
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
    TOTAL_TIPOS_MANUTENCAO      // sentinela — vale como contagem
} TipoManutencao;

#define CATEGORIA_COMBUSTIVEL 0
#define TOTAL_CATEGORIAS_GASTO (TOTAL_TIPOS_MANUTENCAO + 1)

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
    SUCESSO =  0,
    ERRO_KM_DECRESCENTE = -1,
    ERRO_VALOR_NEGATIVO = -2,
    ERRO_LITROS_NEGATIVO = -3,
    ERRO_DATA_INVALIDA = -4,
    ERRO_INTERVALO_INVALIDO = -5,
    ERRO_INDICE_INVALIDO = -6,
    ERRO_MEMORIA = -7,
    ERRO_CAMPO_VAZIO = -8
} CodigoErro;

//structs
typedef struct {
    char nome[MAX_NOME];
    char placa[MAX_PLACA];
    char marca[MAX_MARCA];
    char modelo[MAX_MODELO];
    int  ano;
} Veiculo;

typedef struct {
    int id;
    int64_t data;
    double litros;
    double valor_total;
    double km;
    char combustivel[MAX_COMBUSTIVEL];
} Abastecimento;

typedef struct {
    int            id;
    TipoManutencao tipo;
    char descricao[MAX_DESCRICAO];
    int64_t data_realizada;
    double custo;
    double km_ultima;   // dormente — preenchido pelo km atual
    double intervalo_km;  //dormente — reservado para a Fase 2
    int intervalo_dias;
    CriterioAlerta criterio;  // Fase 1: sempre POR_TEMPO
} Manutencao;

typedef struct {
    int id_manutencao;
    TipoManutencao tipo;
    StatusAlerta status;
    int dias_restantes;
    int64_t data_proxima;
} Alerta;

typedef struct {
    double gasto_por_mes[12];                            /* indice 0 = janeiro      */
    double gasto_por_categoria[TOTAL_TIPOS_MANUTENCAO];  /* indice = TipoManutencao */
    double total_abastecimentos;
    double total_manutencoes;
    double total_geral;
    double gasto_por_mes_categoria[12][TOTAL_CATEGORIAS_GASTO];
} ResumoGastos;

//inputs-dados; Preenchem e retornam uma struct. Validacao feita pelas funcoes de validacao.
Veiculo criar_veiculo(const char* nome, const char* placa, const char* marca, const char* modelo, int ano);
Abastecimento criar_abastecimento(int id, int64_t data, double litros, double valor_total, double km, const char* combustivel);
Manutencao criar_manutencao(int id, TipoManutencao tipo, const char* descricao, int64_t data_realizada, double custo, int intervalo_dias);

//validação; Retornam int (CodigoErro): SUCESSO (0) ou um codigo negativo.
int validar_km(double km_novo, double km_anterior);
int validar_data(int64_t data);
int validar_valor(double valor);
int validar_litros(double litros);
int validar_intervalo_dias(int dias);
int validar_string(const char *str); //Para verificar se string n ta vazia

int editar_veiculo(Veiculo* v, const char* campo, const char* valor);
int editar_abastecimento(Abastecimento* a, const char* campo, const char* valor);
int editar_manutencao(Manutencao* m, const char* campo, const char* valor);

//calúlos;  Recebem vetores de registros (vindos do banco) e devolvem valores.
double calcular_custo_por_km(Abastecimento* lista, int total, double km_inicio, double km_fim);
double calcular_gasto_periodo(Abastecimento* lista, int total, int64_t inicio, int64_t fim);
double calcular_km_por_litro(double km_atual, double km_anterior, double litros);
double obter_km_atual(Abastecimento* lista, int total);
double calcular_km_por_litro_geral(Abastecimento* lista, int total);
ResumoGastos calcular_resumo_gastos(Abastecimento* abastecimentos, int total_abast, Manutencao* manutencoes, int total_manut);

//Alertas;  gerar_lista_alertas aloca com malloc; o chamador libera com liberar_lista_alertas (dboa chamar com NULL).
int calcular_dias_restantes(int64_t data_realizada, int intervalo_dias,  int64_t hoje);
StatusAlerta classificar_alerta(int dias_restantes, int janela_aviso);
Alerta* gerar_lista_alertas(Manutencao* manutencoes, int total_manut, int64_t hoje, int janela_aviso,int* total_alertas);
void liberar_lista_alertas(Alerta* lista);

#endif
