#include <stdio.h>
#include <string.h>
#include <time.h>
#include "autogest.h"

static int eh_bissexto(int ano) {
    if (ano % 400 == 0) {
        return 1;
    }
    if (ano % 100 == 0) {
        return 0;
    }
    return ano % 4 == 0;
}

static int dias_no_mes(int mes, int ano) {
    int dias[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

    if (mes == 2 && eh_bissexto(ano)) {
        return 29;
    }
    return dias[mes - 1];
}

static int comparar_datas(Data a, Data b) {
    if (a.ano != b.ano) {
        return a.ano - b.ano;
    }
    if (a.mes != b.mes) {
        return a.mes - b.mes;
    }
    return a.dia - b.dia;
}

static time_t data_para_tempo(Data data) {
    struct tm info;

    memset(&info, 0, sizeof(info));
    info.tm_mday = data.dia;
    info.tm_mon = data.mes - 1;
    info.tm_year = data.ano - 1900;
    info.tm_hour = 12;

    return mktime(&info);
}

static Data tempo_para_data(time_t tempo) {
    struct tm *info = localtime(&tempo);
    Data data;

    data.dia = info->tm_mday;
    data.mes = info->tm_mon + 1;
    data.ano = info->tm_year + 1900;

    return data;
}

Data ler_data(const char *mensagem) {
    Data data;

    while (1) {
        printf("%s\n", mensagem);
        data.dia = ler_int("Dia: ");
        data.mes = ler_int("Mes: ");
        data.ano = ler_int("Ano: ");

        if (!data_valida(data)) {
            printf("Data invalida. Tente novamente.\n");
        } else if (data_no_futuro(data)) {
            printf("A data nao pode ser futura.\n");
        } else {
            return data;
        }
    }
}

int data_valida(Data data) {
    if (data.ano < 1900 || data.ano > 2100) {
        return 0;
    }
    if (data.mes < 1 || data.mes > 12) {
        return 0;
    }
    if (data.dia < 1 || data.dia > dias_no_mes(data.mes, data.ano)) {
        return 0;
    }
    return 1;
}

int data_no_futuro(Data data) {
    return comparar_datas(data, data_hoje()) > 0;
}

Data data_hoje(void) {
    time_t agora = time(NULL);
    struct tm *info = localtime(&agora);
    Data data;

    data.dia = info->tm_mday;
    data.mes = info->tm_mon + 1;
    data.ano = info->tm_year + 1900;

    return data;
}

Data somar_dias(Data data, int dias) {
    time_t tempo = data_para_tempo(data);
    tempo += (time_t)dias * 24 * 60 * 60;
    return tempo_para_data(tempo);
}

int dias_ate(Data data) {
    time_t destino = data_para_tempo(data);
    time_t hoje = data_para_tempo(data_hoje());
    double diferenca = difftime(destino, hoje);

    return (int)(diferenca / (24 * 60 * 60));
}

void imprimir_data(Data data) {
    printf("%02d/%02d/%04d", data.dia, data.mes, data.ano);
}
