#ifndef AUTOGEST_H
#define AUTOGEST_H

#define ARQUIVO_DADOS "dados.dat"

#define MAX_NOME 50
#define MAX_PLACA 12
#define MAX_MARCA 30
#define MAX_MODELO 30
#define MAX_COMBUSTIVEL 20
#define MAX_DESCRICAO 100

#define MAX_ABASTECIMENTOS 300
#define MAX_MANUTENCOES 300
#define JANELA_AVISO_DIAS 30

typedef enum {
    REG_VEICULO = 1,
    REG_ABASTECIMENTO = 2,
    REG_MANUTENCAO = 3
} TipoRegistro;

typedef enum {
    TROCA_OLEO = 0,
    FILTRO_AR,
    FILTRO_COMBUSTIVEL,
    FILTRO_CABINE,
    PNEUS,
    CORREIA_DENTADA,
    ALINHAMENTO,
    BALANCEAMENTO,
    PASTILHA_FREIO,
    OUTROS,
    TOTAL_TIPOS_MANUTENCAO
} TipoManutencao;

typedef struct {
    int dia;
    int mes;
    int ano;
} Data;

typedef struct {
    char nome[MAX_NOME];
    char placa[MAX_PLACA];
    char marca[MAX_MARCA];
    char modelo[MAX_MODELO];
    int ano;
} Veiculo;

typedef struct {
    int id;
    Data data;
    double litros;
    double valor_total;
    double km;
    char combustivel[MAX_COMBUSTIVEL];
} Abastecimento;

typedef struct {
    int id;
    int tipo;
    char descricao[MAX_DESCRICAO];
    Data data;
    double custo;
    double km_ultima;
    int intervalo_dias;
} Manutencao;

typedef struct {
    int tipo_registro;
    union {
        Veiculo veiculo;
        Abastecimento abastecimento;
        Manutencao manutencao;
    } dados;
} Registro;

extern Veiculo veiculo_atual;
extern int tem_veiculo;

extern Abastecimento abastecimentos[MAX_ABASTECIMENTOS];
extern int total_abastecimentos;
extern int proximo_id_abastecimento;

extern Manutencao manutencoes[MAX_MANUTENCOES];
extern int total_manutencoes;
extern int proximo_id_manutencao;

extern const char *nomes_meses[12];
extern const char *nomes_manutencao[TOTAL_TIPOS_MANUTENCAO];

void mostrar_menu(void);

void pausar(void);
void ler_linha(const char *mensagem, char texto[], int tamanho);
int ler_int(const char *mensagem);
double ler_double(const char *mensagem);
void copiar_texto(char destino[], const char origem[], int tamanho);

Data ler_data(const char *mensagem);
int data_valida(Data data);
int data_no_futuro(Data data);
Data data_hoje(void);
Data somar_dias(Data data, int dias);
int dias_ate(Data data);
void imprimir_data(Data data);

void carregar_dados(void);
int salvar_registro(Registro registro);

void cadastrar_veiculo(void);

void cadastrar_abastecimento(void);
void listar_abastecimentos(void);

void cadastrar_manutencao(void);
void listar_manutencoes(void);
void mostrar_alertas(void);
const char *status_alerta(int dias_restantes);

void mostrar_dashboard(void);
void mostrar_resumo_gastos(void);
double obter_km_atual(void);
double obter_menor_km(void);
double calcular_consumo_medio(void);
double calcular_custo_por_km(void);
double total_gasto_abastecimentos(void);
double total_gasto_manutencoes(void);
double gasto_mes_atual(void);

#endif
