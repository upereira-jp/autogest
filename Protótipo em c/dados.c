#include <stdio.h>
#include "autogest.h"

Veiculo veiculo_atual;
int tem_veiculo = 0;

Abastecimento abastecimentos[MAX_ABASTECIMENTOS];
int total_abastecimentos = 0;
int proximo_id_abastecimento = 1;

Manutencao manutencoes[MAX_MANUTENCOES];
int total_manutencoes = 0;
int proximo_id_manutencao = 1;

const char *nomes_meses[12] = {
    "Janeiro", "Fevereiro", "Marco", "Abril",
    "Maio", "Junho", "Julho", "Agosto",
    "Setembro", "Outubro", "Novembro", "Dezembro"
};

const char *nomes_manutencao[TOTAL_TIPOS_MANUTENCAO] = {
    "Troca de oleo",
    "Filtro de ar",
    "Filtro de combustivel",
    "Filtro de cabine",
    "Pneus",
    "Correia dentada",
    "Alinhamento",
    "Balanceamento",
    "Pastilha de freio",
    "Outros"
};

void carregar_dados(void) {
    FILE *arquivo;
    Registro registro;

    arquivo = fopen(ARQUIVO_DADOS, "rb");
    if (arquivo == NULL) {
        return;
    }

    while (fread(&registro, sizeof(Registro), 1, arquivo) == 1) {
        if (registro.tipo_registro == REG_VEICULO) {
            veiculo_atual = registro.dados.veiculo;
            tem_veiculo = 1;
        } else if (registro.tipo_registro == REG_ABASTECIMENTO) {
            if (total_abastecimentos < MAX_ABASTECIMENTOS) {
                abastecimentos[total_abastecimentos] = registro.dados.abastecimento;
                if (registro.dados.abastecimento.id >= proximo_id_abastecimento) {
                    proximo_id_abastecimento = registro.dados.abastecimento.id + 1;
                }
                total_abastecimentos++;
            }
        } else if (registro.tipo_registro == REG_MANUTENCAO) {
            if (total_manutencoes < MAX_MANUTENCOES) {
                manutencoes[total_manutencoes] = registro.dados.manutencao;
                if (registro.dados.manutencao.id >= proximo_id_manutencao) {
                    proximo_id_manutencao = registro.dados.manutencao.id + 1;
                }
                total_manutencoes++;
            }
        }
    }

    fclose(arquivo);
}

int salvar_registro(Registro registro) {
    FILE *arquivo;

    arquivo = fopen(ARQUIVO_DADOS, "ab");
    if (arquivo == NULL) {
        printf("Erro ao abrir o arquivo de dados.\n");
        return 0;
    }

    fwrite(&registro, sizeof(Registro), 1, arquivo);
    fclose(arquivo);
    return 1;
}
