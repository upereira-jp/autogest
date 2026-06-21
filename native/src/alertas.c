#include <stdlib.h>
#include <time.h>
#include "autogest.h"

/**
 * 1. calcular_dias_restantes
 * Lógica: Converte o intervalo de dias para segundos (1 dia = 86400 segundos), 
 * soma à data realizada para achar o vencimento e compara com a data de hoje.
 */
int calcular_dias_restantes(time_t data_realizada, int intervalo_dias, time_t hoje) {
    // Calcula a data de vencimento em timestamp
    time_t data_vencimento = data_realizada + (time_t)(intervalo_dias * 86400);
    
    // difftime retorna a diferença em segundos de forma segura
    double diferenca_segundos = difftime(data_vencimento, hoje);
    
    // Converte de volta para dias e trunca (casting para int)
    return (int)(diferenca_segundos / 86400.0);
}

/**
 * 2. classificar_alerta
 * Lógica: Recebe os dias restantes e a janela de aviso (ex: 30 dias).
 * Retorna VENCIDO se < 0, PROXIMO se estiver dentro da janela, e EM_DIA caso contrário.
 */
StatusAlerta classificar_alerta(int dias_restantes, int janela_aviso) {
    if (dias_restantes < 0) {
        return VENCIDO;
    } else if (dias_restantes <= janela_aviso) {
        return PROXIMO;
    }
    return EM_DIA;
}

/**
 * 3. gerar_lista_alertas
 * Lógica: Percorre as manutenções buscando quais precisam de atenção.
 * Aloca a lista de alertas dinamicamente (com malloc) e retorna o ponteiro.
 */
Alerta* gerar_lista_alertas(Manutencao* manutencoes, int total_manut, time_t hoje, int janela_aviso, int* total_alertas) {
    // Proteção contra ponteiros nulos
    if (manutencoes == NULL || total_manut <= 0 || total_alertas == NULL) {
        if (total_alertas != NULL) *total_alertas = 0;
        return NULL;
    }

    // Passo 1: Contar quantos alertas ativos existem (PROXIMO ou VENCIDO)
    int contagem_ativos = 0;
    for (int i = 0; i < total_manut; i++) {
        int dias = calcular_dias_restantes(manutencoes[i].data_realizada, manutencoes[i].intervalo_dias, hoje);
        StatusAlerta status = classificar_alerta(dias, janela_aviso);
        
        if (status == PROXIMO || status == VENCIDO) {
            contagem_ativos++;
        }
    }

    // Atualiza a variável que o Flutter vai ler para saber o tamanho da lista
    *total_alertas = contagem_ativos;

    // Se nenhum veículo estiver com manutenção pendente, não precisa alocar nada
    if (contagem_ativos == 0) {
        return NULL;
    }

    // Passo 2: Alocar memória dinamicamente só para a quantidade necessária
    Alerta* lista_alertas = (Alerta*)malloc(contagem_ativos * sizeof(Alerta));
    if (lista_alertas == NULL) {
        *total_alertas = 0; // Previne erros caso falte memória no celular
        return NULL; 
    }

    // Passo 3: Preencher a lista com os dados das manutenções ativas
    int indice_atual = 0;
    for (int i = 0; i < total_manut; i++) {
        int dias = calcular_dias_restantes(manutencoes[i].data_realizada, manutencoes[i].intervalo_dias, hoje);
        StatusAlerta status = classificar_alerta(dias, janela_aviso);
        
        if (status == PROXIMO || status == VENCIDO) {
            lista_alertas[indice_atual].id_manutencao = manutencoes[i].id;
            lista_alertas[indice_atual].tipo          = manutencoes[i].tipo;
            lista_alertas[indice_atual].status        = status;
            lista_alertas[indice_atual].dias_restantes = dias;
            
            // Calcula e salva o timestamp de quando é a data limite exata
            lista_alertas[indice_atual].data_proxima  = manutencoes[i].data_realizada + (time_t)(manutencoes[i].intervalo_dias * 86400);
            
            indice_atual++;
        }
    }

    return lista_alertas;
}

/**
 * 4. liberar_lista_alertas
 * Lógica: O Flutter deve chamar essa função obrigatoriamente após usar os alertas 
 * para limpar a memória RAM consumida pelo malloc acima.
 */
void liberar_lista_alertas(Alerta* lista) {
    if (lista != NULL) {
        free(lista);
    }
}