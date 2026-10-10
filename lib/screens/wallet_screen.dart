import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/booking.dart';

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
                  icon: Icon(
                    isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
                    size: 18,
                  ),
                  onPressed: () => state.toggleDarkMode(),
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
              // Wochen-Progress mit 7 Tagesmarken
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return SizedBox(
                    height: 12,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Hintergrund
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 4,
                          child: Container(
                            height: 4,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        // Fortschritt
                        Positioned(
                          left: 0,
                          top: 4,
                          child: Container(
                            width: width * spentPct,
                            height: 4,
                            color: Colors.white70,
                          ),
                        ),
                        // 7 Tagesstriche (1/7 … 7/7)
                        for (int i = 1; i <= 7; i++)
                          Positioned(
                            left: (width * i / 7) - 0.75,
                            top: 0,
                            child: Container(
                              width: 1.5,
                              height: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Investments heute
        Text(
          'INVESTMENTS HEUTE',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.8,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _MacroRow(
          label: 'Protein',
          current: state.todayMacros['protein']!,
          target: state.settings.proteinTarget.toDouble(),
          isDark: isDark,
        ),
        _MacroRow(
          label: 'Kohlenhydrate',
          current: state.todayMacros['carbs']!,
          target: state.settings.carbsTarget.toDouble(),
          isDark: isDark,
        ),
        _MacroRow(
          label: 'Fett',
          current: state.todayMacros['fat']!,
          target: state.settings.fatTarget.toDouble(),
          isDark: isDark,
        ),
        _MacroRow(
          label: 'Ballaststoffe',
          current: state.todayMacros['fiber']!,
          target: state.settings.fiberTarget.toDouble(),
          isDark: isDark,
        ),
        const SizedBox(height: 32),

        // Tagesbuchungen
        Text(
          'TAGESBUCHUNGEN',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (state.todayBookings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Noch keine Ausgaben heute verbucht.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...state.todayBookings
              .map((b) => _BookingTile(booking: b, isDark: isDark)),
      ],
    );
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final bool isDark;

  const _MacroRow({
    required this.label,
    required this.current,
    required this.target,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (current / target).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                '${current.round()} / ${target.round()} g',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: pct,
            backgroundColor:
                isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            valueColor:
                AlwaysStoppedAnimation(isDark ? Colors.white : Colors.black),
            minHeight: 5,
          ),
        ],
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final Booking booking;
  final bool isDark;

  const _BookingTile({required this.booking, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        color: isDark
            ? Colors.grey.shade900.withValues(alpha: 0.5)
            : Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${booking.category} · P: ${booking.protein}g | K: ${booking.carbs}g | F: ${booking.fat}g',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            '−${booking.kcal} kcal',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 18, color: Colors.grey.shade500),
            onPressed: () => state.deleteBooking(booking.id),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}