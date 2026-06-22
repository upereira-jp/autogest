#include <assert.h>
#include <math.h>
#include <time.h>
#include <stdio.h>

#include "autogest.h"

static int quase_igual(double valor, double esperado) {
    return fabs(valor - esperado) < 0.000001;
}

static void testar_validacoes(void) {
    assert(validar_km(100.0, 90.0) == SUCESSO);
    assert(validar_km(80.0, 90.0) == ERRO_KM_DECRESCENTE);
    assert(validar_km(-1.0, 0.0) == ERRO_VALOR_NEGATIVO);

    assert(validar_valor(0.0) == SUCESSO);
    assert(validar_valor(-1.0) == ERRO_VALOR_NEGATIVO);

    assert(validar_litros(40.0) == SUCESSO);
    assert(validar_litros(0.0) == ERRO_LITROS_NEGATIVO);

    assert(validar_intervalo_dias(30) == SUCESSO);
    assert(validar_intervalo_dias(0) == ERRO_INTERVALO_INVALIDO);

    assert(validar_string(NULL) == ERRO_CAMPO_VAZIO);
    assert(validar_string("") == ERRO_CAMPO_VAZIO);
    assert(validar_string("Troca de óleo") == SUCESSO);
}

static void testar_calculos_basicos(void) {
    double consumo = calcular_km_por_litro(
        1400.0,
        1000.0,
        40.0
    );

    assert(quase_igual(consumo, 10.0));

    assert(classificar_alerta(-1, 30) == VENCIDO);
    assert(classificar_alerta(15, 30) == PROXIMO);
    assert(classificar_alerta(31, 30) == EM_DIA);
}

static void testar_datas(void) {
    int64_t agora = (int64_t)time(NULL);

    assert(validar_data(agora) == SUCESSO);
    assert(validar_data(agora + 86400) == ERRO_DATA_INVALIDA);
    assert(validar_data(0) == ERRO_DATA_INVALIDA);
}

static void testar_geracao_alertas(void) {
    const int64_t dia = 86400;
    const int64_t hoje = 2000000000;

    Manutencao manutencoes[3];

    manutencoes[0] = criar_manutencao(
        1,
        TROCA_OLEO,
        "Troca vencida",
        hoje - 40 * dia,
        100.0,
        30
    );

    manutencoes[1] = criar_manutencao(
        2,
        PNEUS,
        "Troca próxima",
        hoje - 10 * dia,
        200.0,
        30
    );

    manutencoes[2] = criar_manutencao(
        3,
        FILTRO_AR,
        "Manutenção em dia",
        hoje,
        50.0,
        90
    );

    int total_alertas = 0;

    Alerta *alertas = gerar_lista_alertas(
        manutencoes,
        3,
        hoje,
        30,
        &total_alertas
    );

    assert(alertas != NULL);
    assert(total_alertas == 2);

    assert(alertas[0].id_manutencao == 1);
    assert(alertas[0].status == VENCIDO);
    assert(alertas[0].dias_restantes == -10);

    assert(alertas[1].id_manutencao == 2);
    assert(alertas[1].status == PROXIMO);
    assert(alertas[1].dias_restantes == 20);

    liberar_lista_alertas(alertas);
}

static void testar_lista_abastecimentos(void) {
    Abastecimento abastecimentos[3];

    abastecimentos[0] = criar_abastecimento(
        1, 100, 40.0, 200.0, 1000.0, "Gasolina"
    );

    abastecimentos[1] = criar_abastecimento(
        2, 200, 40.0, 240.0, 1400.0, "Gasolina"
    );

    abastecimentos[2] = criar_abastecimento(
        3, 300, 50.0, 300.0, 1800.0, "Gasolina"
    );

    double km_atual = obter_km_atual(abastecimentos, 3);
    assert(quase_igual(km_atual, 1800.0));

    double consumo_geral =
        calcular_km_por_litro_geral(abastecimentos, 3);

    assert(quase_igual(consumo_geral, 800.0 / 90.0));

    double gasto_periodo =
        calcular_gasto_periodo(abastecimentos, 3, 150, 250);

    assert(quase_igual(gasto_periodo, 240.0));

    double custo_por_km =
        calcular_custo_por_km(abastecimentos, 3, 1000.0, 1800.0);

    assert(quase_igual(custo_por_km, 0.925));

    assert(quase_igual(obter_km_atual(NULL, 0), 0.0));
    assert(quase_igual(
        calcular_km_por_litro_geral(abastecimentos, 1),
        0.0
    ));
}

static int64_t criar_data_local(
    int ano,
    int mes,
    int dia
) {
    struct tm data = {0};

    data.tm_year = ano - 1900;
    data.tm_mon = mes - 1;
    data.tm_mday = dia;
    data.tm_hour = 12;
    data.tm_isdst = -1;

    return (int64_t)mktime(&data);
}

static void testar_resumo_gastos(void) {
    Abastecimento abastecimentos[2];

    abastecimentos[0] = criar_abastecimento(
        1,
        criar_data_local(2026, 1, 10),
        20.0,
        100.0,
        1000.0,
        "Gasolina"
    );

    abastecimentos[1] = criar_abastecimento(
        2,
        criar_data_local(2026, 2, 10),
        30.0,
        200.0,
        1300.0,
        "Gasolina"
    );

    Manutencao manutencoes[2];

    manutencoes[0] = criar_manutencao(
        1,
        TROCA_OLEO,
        "Troca de óleo",
        criar_data_local(2026, 1, 15),
        50.0,
        180
    );

    manutencoes[1] = criar_manutencao(
        2,
        PNEUS,
        "Troca de pneus",
        criar_data_local(2026, 2, 15),
        80.0,
        365
    );

    ResumoGastos resumo = calcular_resumo_gastos(
        abastecimentos,
        2,
        manutencoes,
        2
    );

    assert(quase_igual(resumo.total_abastecimentos, 300.0));
    assert(quase_igual(resumo.total_manutencoes, 130.0));
    assert(quase_igual(resumo.total_geral, 430.0));

    assert(quase_igual(resumo.gasto_por_mes[0], 150.0));
    assert(quase_igual(resumo.gasto_por_mes[1], 280.0));

    assert(quase_igual(
        resumo.gasto_por_categoria[TROCA_OLEO],
        50.0
    ));

    assert(quase_igual(
        resumo.gasto_por_categoria[PNEUS],
        80.0
    ));

    assert(quase_igual(
        resumo.gasto_por_mes_categoria[0][CATEGORIA_COMBUSTIVEL],
        100.0
    ));

    assert(quase_igual(
        resumo.gasto_por_mes_categoria[1][CATEGORIA_COMBUSTIVEL],
        200.0
    ));

    assert(quase_igual(
        resumo.gasto_por_mes_categoria[0][TROCA_OLEO + 1],
        50.0
    ));

    assert(quase_igual(
        resumo.gasto_por_mes_categoria[1][PNEUS + 1],
        80.0
    ));
}

int main(void) {
    testar_resumo_gastos();
    testar_lista_abastecimentos();
    testar_validacoes();
    testar_calculos_basicos();
    testar_datas();
    testar_geracao_alertas();

    printf("Todos os testes passaram!\n");

    return 0;
}