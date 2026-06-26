#include <stdio.h>
#include <string.h>
#include "autogest.h"

static void escolher_combustivel(char combustivel[]) {
    int opcao;
    char outro[MAX_COMBUSTIVEL];

    printf("\nCombustivel:\n");
    printf("1 - Gasolina\n");
    printf("2 - Etanol\n");
    printf("3 - Diesel\n");
    printf("4 - Outro\n");

    do {
        opcao = ler_int("Escolha: ");
        if (opcao < 1 || opcao > 4) {
            printf("Opcao invalida.\n");
        }
    } while (opcao < 1 || opcao > 4);

    if (opcao == 1) {
        copiar_texto(combustivel, "Gasolina", MAX_COMBUSTIVEL);
    } else if (opcao == 2) {
        copiar_texto(combustivel, "Etanol", MAX_COMBUSTIVEL);
    } else if (opcao == 3) {
        copiar_texto(combustivel, "Diesel", MAX_COMBUSTIVEL);
    } else {
        ler_linha("Nome do combustivel: ", outro, MAX_COMBUSTIVEL);
        if (strlen(outro) == 0) {
            copiar_texto(combustivel, "Outro", MAX_COMBUSTIVEL);
        } else {
            copiar_texto(combustivel, outro, MAX_COMBUSTIVEL);
        }
    }
}

void cadastrar_abastecimento(void) {
    Registro registro;
    Abastecimento novo;
    double km_atual;

    if (total_abastecimentos >= MAX_ABASTECIMENTOS) {
        printf("\nLimite de abastecimentos atingido.\n");
        pausar();
        return;
    }

    printf("\n--- Novo abastecimento ---\n");

    novo.id = proximo_id_abastecimento;
    novo.data = ler_data("Data do abastecimento:");
    escolher_combustivel(novo.combustivel);

    do {
        novo.litros = ler_double("Litros: ");
        if (novo.litros <= 0) {
            printf("Litros deve ser maior que zero.\n");
        }
    } while (novo.litros <= 0);

    do {
        novo.valor_total = ler_double("Valor total (R$): ");
        if (novo.valor_total <= 0) {
            printf("Valor deve ser maior que zero.\n");
        }
    } while (novo.valor_total <= 0);

    km_atual = obter_km_atual();
    do {
        novo.km = ler_double("Quilometragem: ");
        if (novo.km < 0) {
            printf("Km nao pode ser negativo.\n");
        } else if (total_abastecimentos > 0 && novo.km < km_atual) {
            printf("Km nao pode ser menor que o atual: %.1f km.\n", km_atual);
        }
    } while (novo.km < 0 || (total_abastecimentos > 0 && novo.km < km_atual));

    registro.tipo_registro = REG_ABASTECIMENTO;
    registro.dados.abastecimento = novo;

    if (salvar_registro(registro)) {
        abastecimentos[total_abastecimentos] = novo;
        total_abastecimentos++;
        proximo_id_abastecimento++;
        printf("\nAbastecimento salvo com sucesso.\n");
    }

    pausar();
}

void listar_abastecimentos(void) {
    int i;
    double km_por_litro;
    double km_anterior;

    printf("\n--- Abastecimentos ---\n");

    if (total_abastecimentos == 0) {
        printf("Nenhum abastecimento cadastrado.\n");
        pausar();
        return;
    }

    for (i = total_abastecimentos - 1; i >= 0; i--) {
        printf("\nID: %d\n", abastecimentos[i].id);
        printf("Data: ");
        imprimir_data(abastecimentos[i].data);
        printf("\nCombustivel: %s\n", abastecimentos[i].combustivel);
        printf("Litros: %.2f L\n", abastecimentos[i].litros);
        printf("Valor: R$ %.2f\n", abastecimentos[i].valor_total);
        printf("Km: %.1f km\n", abastecimentos[i].km);

        if (i > 0) {
            km_anterior = abastecimentos[i - 1].km;
            if (abastecimentos[i].litros > 0 && abastecimentos[i].km >= km_anterior) {
                km_por_litro = (abastecimentos[i].km - km_anterior) /
                               abastecimentos[i].litros;
                printf("Consumo do trecho: %.2f km/L\n", km_por_litro);
            }
        }
    }

    pausar();
}
