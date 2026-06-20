#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include "autogest.h"
#include "sqlite3.h"

/*
==================== VALIDAR ====================
*/

int validar_km(double km_novo, double km_anterior){
    if(km_novo < km_anterior){
        return ERRO_KM_DECRESCENTE;
    }
    if(km_novo <= 0){
        return ERRO_VALOR_NEGATIVO;
    }
    return SUCESSO;
}

int validar_data(time_t data){
    time_t hoje = time(NULL);
    if(data>hoje){
        return ERRO_DATA_INVALIDA;
    }
    return SUCESSO;
}

int validar_valor(double valor){
    if(valor <= 0){
        return -ERRO_VALOR_NEGATIVO;
    }
    return SUCESSO;
}

int validar_litros(double litros){
    if(litros<=0){
        return ERRO_LITROS_NEGATIVO;
    }
    return SUCESSO;
}

int validar_intervalo_dias(int dias){
    if (dias <= 0) {
        return ERRO_INTERVALO_INVALIDO;
    }
    return SUCESSO;
}

int validar_string(char* str){
    if(str[0] == '\0'){
        return ERRO_CAMPO_VAZIO;
    }
    return SUCESSO;
}
/*
==================== EDITAR ====================
*/

int editar_veiculo(Veiculo* v, const char* campo, const char* valor) {
    if(!v || !campo || !valor){
        return ERRO_INDICE_INVALIDO;
    }

    if(strlen(valor) == 0){
        return ERRO_CAMPO_VAZIO;
    }

    if(strcmp(campo, "nome") == 0){
        strncpy(v->nome, valor, MAX_NOME - 1);
        v->nome[MAX_NOME - 1] = '\0';

    }else if (strcmp(campo, "placa") == 0){
        strncpy(v->placa, valor, MAX_PLACA - 1);
        v->placa[MAX_PLACA - 1] = '\0';

    }else if (strcmp(campo, "marca") == 0){
        strncpy(v->marca, valor, MAX_MARCA - 1);
        v->marca[MAX_MARCA - 1] = '\0';

    }else if (strcmp(campo, "modelo") == 0){
        strncpy(v->modelo, valor, MAX_MODELO - 1);
        v->modelo[MAX_MODELO - 1] = '\0';

    }else if (strcmp(campo, "ano") == 0){
        v->ano = atoi(valor);
    }else{
        return ERRO_INDICE_INVALIDO; /* Campo não reconhecido */
    }

    return SUCESSO;
}

int editar_abastecimento(Abastecimento* a, const char* campo, const char* valor) {
    if(!a || !campo || !valor){
        return ERRO_INDICE_INVALIDO;
    }

    if(strcmp(campo, "litros") == 0){
        double l = atof(valor);

        if(l <= 0){
            return ERRO_LITROS_NEGATIVO;
        }

        a->litros = l;

    }else if(strcmp(campo, "valor_total") == 0){
        double v = atof(valor);
        if(v <= 0){
            return ERRO_VALOR_NEGATIVO;
        }
        a->valor_total = v;

    }else if(strcmp(campo, "km") == 0){
        double k = atof(valor);
        a->km = k; // Validação de km decrescente exige contexto da lista anterior
    }else if(strcmp(campo, "combustivel") == 0){
        if(strlen(valor) == 0){
            return ERRO_CAMPO_VAZIO;
        }

        strncpy(a->combustivel, valor, MAX_COMBUSTIVEL - 1);
        a->combustivel[MAX_COMBUSTIVEL - 1] = '\0';

    }else{
        return ERRO_INDICE_INVALIDO;
    }
    return SUCESSO;
}

int editar_manutencao(Manutencao* m, const char* campo, const char* valor) {
    if(!m || !campo || !valor){
        return ERRO_INDICE_INVALIDO;
    }

    if(strcmp(campo, "descricao") == 0){
        if(strlen(valor) == 0){
            return ERRO_CAMPO_VAZIO;
        }

        strncpy(m->descricao, valor, MAX_DESCRICAO - 1);
        m->descricao[MAX_DESCRICAO - 1] = '\0';

    }else if(strcmp(campo, "custo") == 0){
        double c = atof(valor);

        if(c <= 0){
            return ERRO_VALOR_NEGATIVO;
        }

        m->custo = c;

    }else if(strcmp(campo, "intervalo_dias") == 0){
        int d = atoi(valor);

        if(d <= 0){
            return ERRO_INTERVALO_INVALIDO;
        }

        m->intervalo_dias = d;

    }else if(strcmp(campo, "tipo") == 0){


        m->tipo = (TipoManutencao)atoi(valor);
    }else{
        return ERRO_INDICE_INVALIDO;
    }

    return SUCESSO;
}