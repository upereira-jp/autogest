# AutoGest

AutoGest e um aplicativo de controle automotivo para registrar abastecimentos,
manutencoes e gastos do veiculo. O projeto tambem mantem um prototipo em C para
terminal, usado como base para regras de negocio e futuras integracoes nativas.

Foi desenvolvido para compor o projeto final da matéria "Introduçaõ à Programação", ministrado pelo professor Edmundo Spoto, do curso "Sistemas de Informação" do Instituto de Informática - Universidade Federal de Goiás
Desenvolvido por:
* Gustavo Pereira Herculano
* João Pedro Pereira de Carvalho
* Augusto Rodrigues Feitosa

## Principais recursos

- Cadastro e edicao dos dados do veiculo.
- Dashboard com quilometragem atual, consumo medio, gasto do mes, custo por km e
  resumo da proxima manutencao.
- Registro de abastecimentos com data, combustivel, litros, valor total e km.
- Registro de manutenções com tipo, descricao, data, custo e intervalo em dias.
- Listagem e edicao de abastecimentos e manutenções ja cadastrados.
- Persistencia local em SQLite no app Flutter.
- Aba de graficos de gastos com:
  - filtro por intervalo de datas;
  - filtro por tipo de gasto: tudo, abastecimentos ou manutencoes;
  - filtro por combustivel: gasolina, alcool ou diesel;
  - filtro por tipo de manutencao;
  - totais por abastecimento, manutencao, total geral e ticket medio;
  - grafico de barras por dia ou por mes;
  - quebras por combustivel e por tipo de manutencao;
  - lista dos ultimos gastos filtrados.
- Tema escuro automotivo com acento ambar e fonte monoespacada para numeros.
- Icone e nome Android configurados como AutoGest.
- Ponte FFI preparada para usar o nucleo C no Android.

## Estrutura do projeto

```text
lib/                  App Flutter
lib/data/             DAOs e banco SQLite
lib/models/           Modelos de dominio
lib/providers/        Estado das telas
lib/screens/          Telas do app
lib/services/         Camada de calculo/mock/FFI
native/               Biblioteca C usada pelo app via FFI
android/              Projeto Android
Protótipo em c/       Prototipo em C puro para terminal
instalador/           APK gerado para instalacao manual
```

## Requisitos para rodar o app Flutter

Instale e configure:

- Flutter SDK compativel com Dart 3.12 ou superior.
- Android Studio ou Android SDK.
- Android SDK Platform, Android SDK Build-Tools, CMake e NDK pelo SDK Manager.
- JDK 17.
- Git.

No Windows, confirme tambem que estas ferramentas estao no ambiente:

```powershell
flutter --version
flutter doctor
java -version
```

O projeto usa as dependencias listadas em `pubspec.yaml`, incluindo `provider`,
`sqflite`, `intl`, `ffi` e `flutter_localizations`.

## Como rodar o app em desenvolvimento

Na raiz do projeto:

```powershell
flutter pub get
flutter run
```

Para rodar em um dispositivo Android especifico:

```powershell
flutter devices
flutter run -d <id-do-dispositivo>
```

Para analisar o codigo:

```powershell
dart analyze lib test
```

Para rodar os testes:

```powershell
flutter test
```

## APK pronto para instalar

O APK ja gerado fica em:

```text
instalador/AutoGest.apk
```

Ele pode ser instalado manualmente no Android seguindo os passos da proxima
secao. Para gerar um novo APK release, use os comandos abaixo.

## Como gerar um novo APK

Na raiz do projeto:

```powershell
flutter pub get
flutter build apk --release
```

O Flutter gera o APK release em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Neste repositorio, o APK para instalacao manual deve ficar em:

```text
instalador/AutoGest.apk
```

Se gerar um novo APK, copie o arquivo:

```powershell
New-Item -ItemType Directory -Force instalador
Copy-Item build/app/outputs/flutter-apk/app-release.apk instalador/AutoGest.apk -Force
```

## Como instalar o APK no Android

Opcao 1: instalacao pelo celular

1. Copie `instalador/AutoGest.apk` para o celular.
2. Abra o APK pelo gerenciador de arquivos.
3. Se o Android pedir permissao, habilite "Instalar apps desconhecidos" para o
   app que esta abrindo o arquivo.
4. Confirme a instalacao.
5. Abra o app AutoGest pela gaveta de aplicativos.

Opcao 2: instalacao via ADB

Com o celular conectado por USB e depuracao USB ativa:

```powershell
adb install -r instalador/AutoGest.apk
```

## Como rodar somente o prototipo em C

O prototipo fica em `Protótipo em c/` e funciona no terminal, sem Flutter.

Entre na pasta:

```powershell
cd "Protótipo em c"
```

Se quiser usar o executavel ja existente no Windows:

```powershell
.\autogest.exe
```

Para recompilar com GCC no Windows, Linux ou macOS:

```bash
gcc main.c entrada.c datas.c dados.c veiculo.c abastecimento.c manutencao.c relatorios.c -o autogest
```

No Windows:

```powershell
.\autogest.exe
```

No Linux/macOS:

```bash
./autogest
```

O prototipo usa `dados.dat` para persistir os dados. Se esse arquivo for
apagado, o prototipo inicia vazio novamente.

## Observacoes tecnicas

- O app Flutter usa SQLite local para persistencia.
- A pasta `native/` compila uma biblioteca C compartilhada chamada
  `libautogest.so` no Android.
- A build Android usa CMake/NDK por causa da integracao nativa.
- O `applicationId` Android ainda e interno do projeto, mas o nome visivel do
  app e AutoGest.
