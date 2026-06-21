#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <ctype.h>
#include <time.h>
#include "autogest.h"
#include "sqlite3.h"

//valor total de abastecimento por km
double calcular_custo_por_km(Abastecimento* lista, int total, double km_inicio, double km_fim) {
    if(lista == NULL || total <= 0){
        return 0.0;
    }
    
    double km_rodada = km_fim - km_inicio;
    if(km_rodada <= 0){
        return 0.0;
    }

    double custo_total_no_intervalo = 0.0;

    for(int i = 0; i < total; i++){
        if(lista[i].km >= km_inicio && lista[i].km <= km_fim){
            custo_total_no_intervalo += lista[i].valor_total;
        }
    }

    return custo_total_no_intervalo / km_rodada;
}

//soma de valor por periodo de tempo (obviamente)
double calcular_gasto_periodo(Abastecimento* lista, int total, time_t inicio, time_t fim) {
    if(lista == NULL || total <= 0){
        return 0.0;
    }

    double soma_gastos = 0.0;

    for(int i = 0; i < total; i++){
        if(lista[i].data >= inicio && lista[i].data <= fim){
            soma_gastos += lista[i].valor_total;
        }
    }

    return soma_gastos;
}

//(KM atual - KM Anterior) / qnt abastecida
double calcular_km_por_litro(double km_atual, double km_anterior, double litros){
    if(litros <= 0){
        return 0.0;
    }
    
    double diferenca_km = km_atual - km_anterior;
    if(diferenca_km < 0){ // Evita cálculo caso o carro diminuiu o km
        return 0.0;
    }

    return diferenca_km / litros;
}

//retorna maior quilometragem dentre os abastecimentos
double obter_km_atual(Abastecimento* lista, int total){
    if(lista == NULL || total <= 0){
        return 0.0;
    }

    double maior_km = 0.0;

    for(int i = 0; i < total; i++){
        if(lista[i].km > maior_km){
            maior_km = lista[i].km;
        }
    }

    return maior_km;
}

//variação total de km (maior - menor) dividida pelo total de litros - desconsidera os litros do primeiro abastecimento
double calcular_km_por_litro_geral(Abastecimento* lista, int total) {
    if(lista == NULL || total < 2){
        return 0.0; // Precisamos de pelo menos 2 registros para ter variação
    }

    double menor_km = lista[0].km;
    double maior_km = lista[0].km;
    double total_litros_consumidos = 0.0;
    
    // Encontra a menor e maior KM histórica
    for(int i = 0; i < total; i++){
        if(lista[i].km < menor_km){
            menor_km = lista[i].km;
        }
        if(lista[i].km > maior_km){
            maior_km = lista[i].km;
        }
    }

    double delta_km = maior_km - menor_km;
    if(delta_km <= 0){
        return 0.0;
    }

    // Encontra o primeiro registro (menor KM) para não somar os litros dele
    int indice_primeiro = 0;
    for(int i = 1; i < total; i++){
        if(lista[i].km == menor_km){
            indice_primeiro = i;
            break;
        }
    }

    // Soma os litros de todos os abastecimentos, exceto do primeirao
    for(int i = 0; i < total; i++){
        if(i != indice_primeiro){
            total_litros_consumidos += lista[i].litros;
        }
    }

    if(total_litros_consumidos <= 0){
        return 0.0;
    }

    return delta_km / total_litros_consumidos;
}

/**
 * 6. calcular_resumo_gastos
 * Lógica: Alimenta a estrutura ResumoGastos separando os custos por categoria de manutenção,
 * acumulando os totais gerais e mapeando os gastos de manutenção/abastecimento de acordo 
 * com o mês (usando a função localtime para descobrir o mês de cada registro).
 */
ResumoGastos calcular_resumo_gastos(Abastecimento* abastecimentos, int total_abast,
                             Manutencao* manutencoes, int total_manut) {
    ResumoGastos resumo;
    
    resumo.total_abastecimentos = 0.0;
    resumo.total_manutencoes = 0.0;
    resumo.total_geral = 0.0;
    
    for(int i = 0; i < 12; i++){
        resumo.gasto_por_mes[i] = 0.0;
    }
    for(int i = 0; i < TOTAL_TIPOS_MANUTENCAO; i++){
        resumo.gasto_por_categoria[i] = 0.0;
    }

    //Processa Abastecimentos
    if(abastecimentos != NULL){
        for(int i = 0; i < total_abast; i++){
            resumo.total_abastecimentos += abastecimentos[i].valor_total;
            
            // Descobre o mês do abastecimento
            struct tm* info_tempo = localtime(&abastecimentos[i].data);
            if(info_tempo != NULL){
                int mes = info_tempo->tm_mon; // 0 = Janeiro, 11 = Dezembro
                if(mes >= 0 && mes < 12){
                    resumo.gasto_por_mes[mes] += abastecimentos[i].valor_total;
                }
            }
        }
    }

    //Processa Manutenções
    if(manutencoes != NULL){
        for(int i = 0; i < total_manut; i++){
            resumo.total_manutencoes += manutencoes[i].custo;
            
            // Acumula na categoria correspondente (Ex: TROCA_OLEO, PNEUS...)
            TipoManutencao cat = manutencoes[i].tipo;
            if(cat >= 0 && cat < TOTAL_TIPOS_MANUTENCAO){
                resumo.gasto_por_categoria[cat] += manutencoes[i].custo;
            }

            // Descobre o mês da manutenção
            struct tm* info_tempo = localtime(&manutencoes[i].data_realizada);
            if(info_tempo != NULL){
                int mes = info_tempo->tm_mon;
                if(mes >= 0 && mes < 12){
                    resumo.gasto_por_mes[mes] += manutencoes[i].custo;
                }
            }
        }
    }

    //Calcula o Total Geral
    resumo.total_geral = resumo.total_abastecimentos + resumo.total_manutencoes;

    return resumo;
}