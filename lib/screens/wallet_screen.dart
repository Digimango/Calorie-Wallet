import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/booking.dart';
import 'settings_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  String _weekLabel() {
    final now = DateTime.now();
    final ref = Booking(
      name: '',
      kcal: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      fiber: 0,
      category: '',
    );
    const days = ['SO', 'MO', 'DI', 'MI', 'DO', 'FR', 'SA'];
    final dayName = days[now.weekday % 7];
    return 'WOCHE ${ref.weekNumber} · $dayName';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.settings.isDarkMode;
    final fmt = NumberFormat('#,###', 'de_DE');

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final spentPct = (state.totalSpentWeek / state.settings.weeklyTarget)
        .clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Calorie Wallet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Row(
              children: [
                Text(
                  _weekLabel(),
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: Colors.grey.shade500,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 20),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Banking Card – Wochenbudget
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WOCHENBUDGET VERFÜGBAR',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.8,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                fmt.format(state.totalAvailable),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'monospace',
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lohn ${fmt.format(state.settings.weeklyTarget)} kcal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade300,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'ausgegeben ${fmt.format(state.totalSpentWeek)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade300,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Wochen-Progress (+ optionale Tagesmarken)
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return SizedBox(
                    height: 12,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 4,
                          child: Container(
                            height: 4,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 4,
                          child: Container(
                            width: width * spentPct,
                            height: 4,
                            color: Colors.white70,
                          ),
                        ),
                        if (state.settings.showDayMarkers)
                          for (int i = 1; i <= 7; i++)
                            Positioned(
                              left: (width