#include <stdio.h>
#include <string.h>
#include "autogest.h"

void mostrar_dashboard(void) {
    double km_atual;
    double consumo;
    double custo_km;
    double gasto_mes;
    int i;
    int achou_alerta = 0;
    int menor_dias = 999999;
    int indice_alerta = -1;
    Data proxima;
    int dias;

    printf("\n--- Dashboard ---\n");

    if (tem_veiculo) {
        printf("Veiculo: %s\n", veiculo_atual.nome);
        if (strlen(veiculo_atual.marca) > 0 || strlen(veiculo_atual.modelo) > 0) {
            printf("Modelo: %s %s\n", veiculo_atual.marca, veiculo_atual.modelo);
        }
        if (strlen(veiculo_atual.placa) > 0) {
            printf("Placa: %s\n", veiculo_atual.placa);
        }
        if (veiculo_atual.ano > 0) {
            printf("Ano: %d\n", veiculo_atual.ano);
        }
    } else {
        printf("Veiculo: nenhum cadastrado\n");
    }

    km_atual = obter_km_atual();
    consumo = calcular_consumo_medio();
    custo_km = calcular_custo_por_km();
    gasto_mes = gasto_mes_atual();

    printf("Km atual: %.1f km\n", km_atual);

    if (consumo > 0) {
        printf("Consumo medio: %.2f km/L\n", consumo);
    } else {
        printf("Consumo medio: dados insuficientes\n");
    }

    if (custo_km > 0) {
        printf("Custo por km: R$ %.2f\n", custo_km);
    } else {
        printf("Custo por km: dados insuficientes\n");
    }

    printf("Gasto do mes: R$ %.2f\n", gasto_mes);

    for (i = 0; i < total_manutencoes; i++) {
        proxima = somar_dias(manutencoes[i].data, manutencoes[i].intervalo_dias);
        dias = dias_ate(proxima);

        if (dias <= JANELA_AVISO_DIAS && dias < menor_dias) {
            menor_dias = dias;
            indice_alerta = i;
            achou_alerta = 1;
        }
    }

    if (achou_alerta) {
        printf("Proxima manutencao: %s - %s (%d dia(s))\n",
               nomes_manutencao[manutencoes[indice_alerta].tipo],
               status_alerta(menor_dias),
               menor_dias);
    } else {
        printf("Proxima manutencao: nenhum alerta no momento\n");
    }

    pausar();
}

void mostrar_resumo_gastos(void) {
    double gasto_meses[12];
    double gasto_categorias[TOTAL_TIPOS_MANUTENCAO];
    int i;
    int mes;

    for (i = 0; i < 12; i++) {
        gasto_meses[i] = 0;
    }
    for (i = 0; i < TOTAL_TIPOS_MANUTENCAO; i++) {
        gasto_categorias[i] = 0;
    }

    for (i = 0; i < total_abastecimentos; i++) {
        mes = abastecimentos[i].data.mes - 1;
        if (mes >= 0 && mes < 12) {
            gasto_meses[mes] += abastecimentos[i].valor_total;
        }
    }

    for (i = 0; i < total_manutencoes; i++) {
        mes = manutencoes[i].data.mes - 1;
        if (mes >= 0 && mes < 12) {
            gasto_meses[mes] += manutencoes[i].custo;
        }
        if (manutencoes[i].tipo >= 0 && manutencoes[i].tipo < TOTAL_TIPOS_MANUTENCAO) {
            gasto_categorias[manutencoes[i].tipo] += manutencoes[i].custo;
        }
    }

    printf("\n--- Resumo de gastos ---\n");
    printf("Total com abastecimentos: R$ %.2f\n", total_gasto_abastecimentos());
    printf("Total com manutencoes: R$ %.2f\n", total_gasto_manutencoes());
    printf("Total geral: R$ %.2f\n",
           total_gasto_abastecimentos() + total_gasto_manutencoes());

    printf("\nGastos por mes:\n");
    for (i = 0; i < 12; i++) {
        if (gasto_meses[i] > 0) {
            printf("%s: R$ %.2f\n", nomes_meses[i], gasto_meses[i]);
        }
    }

    printf("\nGastos por tipo de manutencao:\n");
    for (i = 0; i < TOTAL_TIPOS_MANUTENCAO; i++) {
        if (gasto_categorias[i] > 0) {
            printf("%s: R$ %.2f\n", nomes_manutencao[i], gasto_categorias[i]);
        }
    }

    pausar();
}

double obter_km_atual(void) {
    int i;
    double maior = 0;

    for (i = 0; i < total_abastecimentos; i++) {
        if (abastecimentos[i].km > maior) {
            maior = abastecimentos[i].km;
        }
    }

    return maior;
}

double obter_menor_km(void) {
    int i;
    double menor;

    if (total_abastecimentos == 0) {
        return 0;
    }

    menor = abastecimentos[0].km;
    for (i = 1; i < total_abastecimentos; i++) {
        if (abastecimentos[i].km < menor) {
            menor = abastecimentos[i].km;
        }
    }

    return menor;
}

double calcular_consumo_medio(void) {
    int i;
    int indice_primeiro = 0;
    double menor;
    double maior;
    double litros = 0;

    if (total_abastecimentos < 2) {
        return 0;
    }

    menor = obter_menor_km();
    maior = obter_km_atual();

    if (maior <= menor) {
        return 0;
    }

    for (i = 0; i < total_abastecimentos; i++) {
        if (abastecimentos[i].km == menor) {
            indice_primeiro = i;
            break;
        }
    }

    for (i = 0; i < total_abastecimentos; i++) {
        if (i != indice_primeiro) {
            litros += abastecimentos[i].litros;
        }
    }

    if (litros <= 0) {
        return 0;
    }

    return (maior - menor) / litros;
}

double calcular_custo_por_km(void) {
    double menor = obter_menor_km();
    double maior = obter_km_atual();
    double km_rodado = maior - menor;

    if (total_abastecimentos < 2 || km_rodado <= 0) {
        return 0;
    }

    return total_gasto_abastecimentos() / km_rodado;
}

double total_gasto_abastecimentos(void) {
    int i;
    double total = 0;

    for (i = 0; i < total_abastecimentos; i++) {
        total += abastecimentos[i].valor_total;
    }

    return total;
}

double total_gasto_manutencoes(void) {
    int i;
    double total = 0;

    for (i = 0; i < total_manutencoes; i++) {
        total += manutencoes[i].custo;
    }

    return total;
}

double gasto_mes_atual(void) {
    int i;
    double total = 0;
    Data hoje = data_hoje();

    for (i = 0; i < total_abastecimentos; i++) {
        if (abastecimentos[i].data.mes == hoje.mes &&
            abastecimentos[i].data.ano == hoje.ano) {
            total += abastecimentos[i].valor_total;
        }
    }

    for (i = 0; i < total_manutencoes; i++) {
        if (manutencoes[i].data.mes == hoje.mes &&
            manutencoes[i].data.ano == hoje.ano) {
            total += manutencoes[i].custo;
        }
    }

    return total;
}
