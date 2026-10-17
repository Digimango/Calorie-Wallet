import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:home_widget/home_widget.dart';
import 'providers/app_state.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_shell.dart';
import 'screens/booking_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

  // Widget-Tap (App läuft bereits)
  HomeWidget.widgetClicked.listen((uri) {
    if (uri != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const BookingScreen()),
      );
    }
  });

  // Widget-Tap (App war geschlossen)
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (uri != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const BookingScreen()),
      );
    }
  });
}

class CalorieWalletApp extends StatelessWidget {
  const CalorieWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppState>().settings.isDarkMode;
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Calorie Wallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const HomeShell(),
    );
  }
}