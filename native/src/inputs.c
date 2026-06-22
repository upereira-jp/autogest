//calma edmundo, que aqui é o pai que tá no controle; Código preenche as entradas e retorna uma struct.
//max - 1, para ter espaço para o '/0', deixando claro
#include "autogest.h"

Veiculo criar_veiculo(const char* nome, const char* placa, const char* marca, const char* modelo, int ano) {
    Veiculo v;
    int i;
    for (i = 0; i < MAX_NOME - 1 && nome[i] != '\0'; i++){
        v.nome[i] = nome[i];
    }
    v.nome[i] = '\0';
    for (i = 0; i < MAX_PLACA - 1 && placa[i] != '\0'; i++){
        v.placa[i] = placa[i];
    }
    v.placa[i] = '\0';
    for (i = 0; i < MAX_MARCA - 1 && marca[i] != '\0'; i++){
        v.marca[i] = marca[i];
    }
    v.marca[i] = '\0';
    for (i = 0; i < MAX_MODELO - 1 && modelo[i] != '\0'; i++){
        v.modelo[i] = modelo[i];
    }
    v.modelo[i] = '\0';
    v.ano = ano;
    return v;
}

Abastecimento criar_abastecimento(int id, int64_t data, double litros, double valor_total, double km, const char* combustivel) {
    Abastecimento a;
    int i;
    a.id = id;
    a.data = data;
    a.litros = litros;
    a.valor_total = valor_total;
    a.km = km;
    for (i = 0; i < MAX_COMBUSTIVEL - 1 && combustivel[i] != '\0'; i++){
        a.combustivel[i] = combustivel[i];
    }
    a.combustivel[i] = '\0';
    return a;
}

Manutencao criar_manutencao(int id, TipoManutencao tipo, const char* descricao, int64_t data_realizada, double custo, int intervalo_dias) {
    Manutencao m;
    int i;
    m.id = id;
    m.tipo = tipo;
    for (i = 0; i < MAX_DESCRICAO - 1 && descricao[i] != '\0'; i++){
        m.descricao[i] = descricao[i];
    }
    m.descricao[i] = '\0';
    m.data_realizada = data_realizada;
    m.custo = custo;
    m.intervalo_dias = intervalo_dias;
    m.km_ultima = 0.0;
    m.intervalo_km = 0.0;
    m.criterio = POR_TEMPO;
    return m;
}
