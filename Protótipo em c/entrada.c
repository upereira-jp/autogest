#include <stdio.h>
#include <string.h>
#include "autogest.h"

void pausar(void) {
    char enter[8];

    printf("\nPressione Enter para continuar...");
    fgets(enter, sizeof(enter), stdin);
}

void ler_linha(const char *mensagem, char texto[], int tamanho) {
    int len;

    printf("%s", mensagem);
    fgets(texto, tamanho, stdin);

    len = (int)strlen(texto);
    if (len > 0 && texto[len - 1] == '\n') {
        texto[len - 1] = '\0';
    }
}

int ler_int(const char *mensagem) {
    char texto[50];
    int valor;

    while (1) {
        ler_linha(mensagem, texto, sizeof(texto));
        if (sscanf(texto, "%d", &valor) == 1) {
            return valor;
        }
        printf("Digite um numero inteiro valido.\n");
    }
}

double ler_double(const char *mensagem) {
    char texto[50];
    double valor;
    int i;

    while (1) {
        ler_linha(mensagem, texto, sizeof(texto));

        for (i = 0; texto[i] != '\0'; i++) {
            if (texto[i] == ',') {
                texto[i] = '.';
            }
        }

        if (sscanf(texto, "%lf", &valor) == 1) {
            return valor;
        }
        printf("Digite um numero valido.\n");
    }
}

void copiar_texto(char destino[], const char origem[], int tamanho) {
    strncpy(destino, origem, tamanho - 1);
    destino[tamanho - 1] = '\0';
}
