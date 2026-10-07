import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final storage = StorageService();
  await storage.init();

  final appState = AppState(storage);
  await appState.init();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const CalorieWalletApp(),
    ),
  );
}

class CalorieWalletApp extends StatelessWidget {
  const CalorieWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppState>().settings.isDarkMode;
    return MaterialApp(
      title: 'Calorie Wallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const HomeShell(),
    );
  }
}
