#include <stdlib.h>
#include <time.h>
#include "autogest.h"

//Converte o intervalo de dias para segundos (1 dia = 86400 segundos),  soma à data realizada para achar o vencimento e compara com a data de hoje.
int calcular_dias_restantes(int64_t data_realizada, int intervalo_dias, int64_t hoje) {
    int64_t data_vencimento = data_realizada + (int64_t)intervalo_dias * 86400;
    int64_t diferenca_segundos = data_vencimento - hoje;
    return (int)(diferenca_segundos / 86400);
}

//Recebe os dias restantes e a janela de aviso (ex: 30 dias). Retorna VENCIDO se < 0, PROXIMO se estiver dentro da janela, e EM_DIA caso contrário.
StatusAlerta classificar_alerta(int dias_restantes, int janela_aviso) {
    if (dias_restantes < 0) {
        return VENCIDO;
    } else if (dias_restantes <= janela_aviso) {
        return PROXIMO;
    }
    return EM_DIA;
}

//Aloca a lista de alertas dinamicamente (com malloc) e retorna o ponteiro.
Alerta* gerar_lista_alertas(Manutencao* manutencoes, int total_manut, int64_t hoje, int janela_aviso, int* total_alertas) {
    int contagem_ativos = 0, indice_atual = 0;
    //Caso de ponteiros nulos
    if (manutencoes == NULL || total_manut <= 0 || total_alertas == NULL) {
        if (total_alertas != NULL) *total_alertas = 0;
        return NULL;
    }

    //quantos alertas ativos existem
    for (int i = 0; i < total_manut; i++) {
        int dias = calcular_dias_restantes(manutencoes[i].data_realizada, manutencoes[i].intervalo_dias, hoje);
        StatusAlerta status = classificar_alerta(dias, janela_aviso);
        if (status == PROXIMO || status == VENCIDO) {
            contagem_ativos++;
        }
    }
    
    *total_alertas = contagem_ativos; //Variável que o Flutter vai ler para saber o tamanho da lista
    if (contagem_ativos == 0) { // Se nenhum veículo estiver com manutenção pendente, não precisa alocar nada
        return NULL;
    }
    //Alocar memória dinamicamente só para a quantidade necessária
    Alerta* lista_alertas = (Alerta*)malloc(contagem_ativos * sizeof(Alerta));
    if (lista_alertas == NULL) {
        *total_alertas = 0;
        return NULL; 
    }
    //Preenche a lista com os dados das manutenções ativas
    for (int i = 0; i < total_manut; i++) {
        int dias = calcular_dias_restantes(manutencoes[i].data_realizada, manutencoes[i].intervalo_dias, hoje);
        StatusAlerta status = classificar_alerta(dias, janela_aviso);
        
        if (status == PROXIMO || status == VENCIDO) {
            lista_alertas[indice_atual].id_manutencao = manutencoes[i].id;
            lista_alertas[indice_atual].tipo = manutencoes[i].tipo;
            lista_alertas[indice_atual].status = status;
            lista_alertas[indice_atual].dias_restantes = dias;
            
            // Calcula e salva o timestamp de quando é a data limite exata
            lista_alertas[indice_atual].data_proxima = manutencoes[i].data_realizada + (int64_t)manutencoes[i].intervalo_dias * 86400;
            indice_atual++;
        }
    }
    return lista_alertas;
}

//free da memória consumida pelo malloc.
void liberar_lista_alertas(Alerta* lista) {
    if (lista != NULL) {
        free(lista);
    }
}
