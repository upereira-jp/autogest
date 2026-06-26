#include <stdio.h>
#include "autogest.h"

int main(void) {
    int opcao;

    carregar_dados();

    do {
        mostrar_menu();
        opcao = ler_int("Escolha uma opcao: ");

        switch (opcao) {
            case 1:
                mostrar_dashboard();
                break;
            case 2:
                cadastrar_veiculo();
                break;
            case 3:
                cadastrar_abastecimento();
                break;
            case 4:
                listar_abastecimentos();
                break;
            case 5:
                cadastrar_manutencao();
                break;
            case 6:
                listar_manutencoes();
                break;
            case 7:
                mostrar_resumo_gastos();
                break;
            case 8:
                mostrar_alertas();
                break;
            case 0:
                printf("\nSaindo do AutoGest...\n");
                break;
            default:
                printf("\nOpcao invalida.\n");
                pausar();
        }
    } while (opcao != 0);

    return 0;
}

void mostrar_menu(void) {
    printf("\n========================================\n");
    printf("              AUTOGEST C\n");
    printf("========================================\n");
    printf("1 - Dashboard\n");
    printf("2 - Cadastrar/editar veiculo\n");
    printf("3 - Registrar abastecimento\n");
    printf("4 - Listar abastecimentos\n");
    printf("5 - Registrar manutencao\n");
    printf("6 - Listar manutencoes\n");
    printf("7 - Resumo de gastos\n");
    printf("8 - Alertas de manutencao\n");
    printf("0 - Sair\n");
    printf("========================================\n");
}
