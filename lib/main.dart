import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'data/abastecimento_dao.dart';
import 'data/app_database.dart';
import 'data/db_init.dart';
import 'data/manutencao_dao.dart';
import 'data/veiculo_dao.dart';
import 'providers/abastecimento_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/manutencao_provider.dart';
import 'screens/home_shell.dart';
import 'services/autogest_service.dart';
import 'services/mock_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Seleciona o backend SQLite por plataforma (desktop/web via FFI;
  // Android/iOS seguem no plugin sqflite padrão).
  initDatabaseFactory();
  await initializeDateFormatting('pt_BR', null);
  runApp(const AutoGestApp());
}

class AutoGestApp extends StatelessWidget {
  const AutoGestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final db = AppDatabase.instance;

    return MultiProvider(
      providers: [
        // --- Persistência (DAOs sobre o SQLite) ---
        Provider<VeiculoDao>(create: (_) => VeiculoDao(db)),
        Provider<AbastecimentoDao>(create: (_) => AbastecimentoDao(db)),
        Provider<ManutencaoDao>(create: (_) => ManutencaoDao(db)),

        // --- Camada de cálculo: ÚNICO PONTO DE TROCA mock ↔ ffi ---
        // Quando o núcleo C compilar, troque por: const FfiService().
        Provider<AutogestService>(create: (_) => const MockService()),

        // --- Estado por tela (junta DAOs + serviço) ---
        ChangeNotifierProvider<DashboardProvider>(
          create: (c) => DashboardProvider(
            c.read<VeiculoDao>(),
            c.read<AbastecimentoDao>(),
            c.read<ManutencaoDao>(),
            c.read<AutogestService>(),
          ),
        ),
        ChangeNotifierProvider<AbastecimentoProvider>(
          create: (c) => AbastecimentoProvider(
            c.read<AbastecimentoDao>(),
            c.read<AutogestService>(),
          ),
        ),
        ChangeNotifierProvider<ManutencaoProvider>(
          create: (c) => ManutencaoProvider(
            c.read<ManutencaoDao>(),
            c.read<AbastecimentoDao>(),
            c.read<AutogestService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'AutoGest',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HomeShell(),
      ),
    );
  }
}
