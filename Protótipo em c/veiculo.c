#include <stdio.h>
#include <string.h>
#include "autogest.h"

void cadastrar_veiculo(void) {
    Registro registro;
    Veiculo novo;

    printf("\n--- Cadastro do veiculo ---\n");

    do {
        ler_linha("Nome do veiculo: ", novo.nome, MAX_NOME);
        if (strlen(novo.nome) == 0) {
            printf("O nome nao pode ficar vazio.\n");
        }
    } while (strlen(novo.nome) == 0);

    ler_linha("Marca: ", novo.marca, MAX_MARCA);
    ler_linha("Modelo: ", novo.modelo, MAX_MODELO);
    ler_linha("Placa: ", novo.placa, MAX_PLACA);

    novo.ano = ler_int("Ano: ");
    while (novo.ano < 0) {
        printf("Ano invalido.\n");
        novo.ano = ler_int("Ano: ");
    }

    registro.tipo_registro = REG_VEICULO;
    registro.dados.veiculo = novo;

    if (salvar_registro(registro)) {
        veiculo_atual = novo;
        tem_veiculo = 1;
        printf("\nVeiculo salvo com sucesso.\n");
    }

    if (strlen(novo.placa) > 0) {
        printf("Placa cadastrada: %s\n", novo.placa);
    }

    pausar();
}
