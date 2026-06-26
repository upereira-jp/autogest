#include <stdio.h>
#include <string.h>
#include "autogest.h"

static int escolher_tipo_manutencao(void) {
    int i;
    int opcao;

    printf("\nTipo de manutencao:\n");
    for (i = 0; i < TOTAL_TIPOS_MANUTENCAO; i++) {
        printf("%d - %s\n", i + 1, nomes_manutencao[i]);
    }

    do {
        opcao = ler_int("Escolha: ");
        if (opcao < 1 || opcao > TOTAL_TIPOS_MANUTENCAO) {
            printf("Opcao invalida.\n");
        }
    } while (opcao < 1 || opcao > TOTAL_TIPOS_MANUTENCAO);

    return opcao - 1;
}

void cadastrar_manutencao(void) {
    Registro registro;
    Manutencao nova;

    if (total_manutencoes >= MAX_MANUTENCOES) {
        printf("\nLimite de manutencoes atingido.\n");
        pausar();
        return;
    }

    printf("\n--- Nova manutencao ---\n");

    nova.id = proximo_id_manutencao;
    nova.tipo = escolher_tipo_manutencao();
    ler_linha("Descricao (opcional): ", nova.descricao, MAX_DESCRICAO);
    nova.data = ler_data("Data da manutencao:");

    do {
        nova.custo = ler_double("Custo (R$): ");
        if (nova.custo < 0) {
            printf("Custo nao pode ser negativo.\n");
        }
    } while (nova.custo < 0);

    do {
        nova.intervalo_dias = ler_int("Intervalo para repetir (dias): ");
        if (nova.intervalo_dias <= 0) {
            printf("Intervalo deve ser maior que zero.\n");
        }
    } while (nova.intervalo_dias <= 0);

    nova.km_ultima = obter_km_atual();

    registro.tipo_registro = REG_MANUTENCAO;
    registro.dados.manutencao = nova;

    if (salvar_registro(registro)) {
        manutencoes[total_manutencoes] = nova;
        total_manutencoes++;
        proximo_id_manutencao++;
        printf("\nManutencao salva com sucesso.\n");
    }

    pausar();
}

void listar_manutencoes(void) {
    int i;
    Data proxima;
    int dias;

    printf("\n--- Manutencoes ---\n");

    if (total_manutencoes == 0) {
        printf("Nenhuma manutencao cadastrada.\n");
        pausar();
        return;
    }

    for (i = total_manutencoes - 1; i >= 0; i--) {
        proxima = somar_dias(manutencoes[i].data, manutencoes[i].intervalo_dias);
        dias = dias_ate(proxima);

        printf("\nID: %d\n", manutencoes[i].id);
        printf("Tipo: %s\n", nomes_manutencao[manutencoes[i].tipo]);
        if (strlen(manutencoes[i].descricao) > 0) {
            printf("Descricao: %s\n", manutencoes[i].descricao);
        }
        printf("Data realizada: ");
        imprimir_data(manutencoes[i].data);
        printf("\nCusto: R$ %.2f\n", manutencoes[i].custo);
        printf("Km no cadastro: %.1f km\n", manutencoes[i].km_ultima);
        printf("Intervalo: %d dias\n", manutencoes[i].intervalo_dias);
        printf("Proxima data: ");
        imprimir_data(proxima);
        printf(" (%s, %d dia(s))\n", status_alerta(dias), dias);
    }

    pausar();
}

void mostrar_alertas(void) {
    int i;
    int encontrou = 0;
    Data proxima;
    int dias;

    printf("\n--- Alertas de manutencao ---\n");

    for (i = 0; i < total_manutencoes; i++) {
        proxima = somar_dias(manutencoes[i].data, manutencoes[i].intervalo_dias);
        dias = dias_ate(proxima);

        if (dias <= JANELA_AVISO_DIAS) {
            encontrou = 1;
            printf("\n%s\n", nomes_manutencao[manutencoes[i].tipo]);
            printf("Status: %s\n", status_alerta(dias));
            printf("Proxima data: ");
            imprimir_data(proxima);
            printf("\nDias restantes: %d\n", dias);
        }
    }

    if (!encontrou) {
        printf("Nenhum alerta no momento.\n");
    }

    pausar();
}

const char *status_alerta(int dias_restantes) {
    if (dias_restantes < 0) {
        return "VENCIDO";
    }
    if (dias_restantes <= JANELA_AVISO_DIAS) {
        return "PROXIMO";
    }
    return "EM DIA";
}
