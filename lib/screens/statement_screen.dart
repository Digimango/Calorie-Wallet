import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/booking.dart';

class StatementScreen extends StatelessWidget {
  const StatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.settings.isDarkMode;
    final fmt = NumberFormat('#,###', 'de_DE');
    final dayTotals = state.weekDayTotals;
    final investment = state.investmentDaysReached;

    final ref = Booking(
      name: '',
      kcal: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      fiber: 0,
      category: '',
    );
    final kw = ref.weekNumber;

    final alreadyHandled = state.settings.lastRolloverWeek == kw &&
        state.settings.lastRolloverYear == DateTime.now().year;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              'Auszug',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'KW $kw',
              style: TextStyle(
                fontSize: 13,
                letterSpacing: 1.5,
                color: Colors.grey.shade500,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, height: 32),

        // Summary
        _SummaryRow(label: 'Anfangsbestand', value: fmt.format(state.settings.weeklyTarget + state.settings.rollover)),
        _SummaryRow(label: 'Buchungen', value: '−${fmt.format(state.totalSpentWeek)}'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'ENDSALDO',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.8,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              fmt.format(state.totalAvailable),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        Divider(color: isDark ? Colors.white : Colors.black, height: 40, thickness: 1.5),

        // Buchungen pro Tag
        Text(
          'BUCHUNGEN PRO TAG',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.8,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        ...['MO', 'DI', 'MI', 'DO', 'FR', 'SA', 'SO'].map((day) {
          final kcal = dayTotals[day] ?? 0;
          final pct = (kcal / 2500).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(isDark ? Colors.white : Colors.black),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 48,
                  child: Text(
                    fmt.format(kcal),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 28),

        // Investment erreicht
        Text(
          'INVESTMENT ERREICHT',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.8,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _InvestmentRow(label: 'Protein', days: investment['protein'] ?? 0),
        _InvestmentRow(label: 'Kohlenhydrate', days: investment['carbs'] ?? 0),
        _InvestmentRow(label: 'Fett', days: investment['fat'] ?? 0),
        _InvestmentRow(label: 'Ballaststoffe', days: investment['fiber'] ?? 0),
        const SizedBox(height: 32),

        // Übertrag Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? Colors.white : Colors.black,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ÜBERTRAG',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.8,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${fmt.format(state.totalAvailable)} kcal',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (alreadyHandled)
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.settings.rollover > 0
                            ? '${fmt.format(state.settings.rollover)} kcal in nächste Woche mitgenommen.'
                            : 'Saldo zurückgesetzt.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => state.applyRollover(keep: true),
                        child: const Text('MITNEHMEN'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => state.applyRollover(keep: false),
                        child: const Text('VERWERFEN'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _InvestmentRow extends StatelessWidget {
  final String label;
  final int days;
  const _InvestmentRow({required this.label, required this.days});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            '$days / 7 Tage',
            style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
