# AutoGest - Prototipo em C

Versao simples do AutoGest para terminal, feita em C puro.

## O que tem

- Cadastro/edicao do veiculo.
- Registro e listagem de abastecimentos.
- Registro e listagem de manutencoes.
- Dashboard com km atual, consumo medio, custo por km e gasto do mes.
- Resumo de gastos por mes e por tipo de manutencao.
- Alertas de manutencao vencida ou proxima.
- Persistencia em arquivo binario `dados.dat`.

## Arquivos

- `autogest.h`: constantes, structs, enums e prototipos das funcoes.
- `main.c`: menu principal.
- `entrada.c`: leitura de dados do teclado.
- `datas.c`: validacao e calculos com datas.
- `dados.c`: variaveis globais e persistencia em `dados.dat`.
- `veiculo.c`: cadastro do veiculo.
- `abastecimento.c`: cadastro e listagem de abastecimentos.
- `manutencao.c`: cadastro, listagem e alertas de manutencao.
- `relatorios.c`: dashboard, resumo e calculos.

## Como compilar

No terminal, entre nesta pasta e rode:

```bash
gcc main.c entrada.c datas.c dados.c veiculo.c abastecimento.c manutencao.c relatorios.c -o autogest
```

No Windows, para executar:

```bash
.\autogest.exe
```

No Linux/macOS, para executar:

```bash
./autogest
```

## Persistencia

O programa carrega os dados de `dados.dat` quando inicia.
Cada novo cadastro e salvo no mesmo arquivo usando append binario:

```c
FILE *arquivo = fopen("dados.dat", "ab");
```

Se apagar o `dados.dat`, o programa comeca vazio de novo.
