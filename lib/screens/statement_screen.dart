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
    final year = DateTime.now().year;

    final snapshot = _WeekSnapshot.fromBookings(
      bookings: state.weekBookings,
      weekNumber: kw,
      year: year,
      weeklyTarget: state.settings.weeklyTarget,
      proteinTarget: state.settings.proteinTarget,
      carbsTarget: state.settings.carbsTarget,
      fatTarget: state.settings.fatTarget,
      fiberTarget: state.settings.fiberTarget,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
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
        Divider(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          height: 32,
        ),
        _WeekStatementBody(snapshot: snapshot, isDark: isDark, fmt: fmt),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WeekOverviewScreen(
                    weeklyTarget: state.settings.weeklyTarget,
                    proteinTarget: state.settings.proteinTarget,
                    carbsTarget: state.settings.carbsTarget,
                    fatTarget: state.settings.fatTarget,
                    fiberTarget: state.settings.fiberTarget,
                  ),
                ),
              );
            },
            child: const Text('ÜBERSICHT'),
          ),
        ),
      ],
    );
  }
}

/// Wischbare Wochen-Historie
class WeekOverviewScreen extends StatelessWidget {
  final int weeklyTarget;
  final int proteinTarget;
  final int carbsTarget;
  final int fatTarget;
  final int fiberTarget;

  const WeekOverviewScreen({
    super.key,
    required this.weeklyTarget,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    required this.fiberTarget,
  });

  List<_WeekSnapshot> _buildWeeks(AppState state) {
    final map = <String, List<Booking>>{};
    for (final b in state.allBookings) {
      final key = '\( {b.year}- \){b.weekNumber}';
      map.putIfAbsent(key, () => []).add(b);
    }

    // Aktuelle Woche immer dabei
    final ref = Booking(
      name: '',
      kcal: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      fiber: 0,
      category: '',
    );
    final currentKey = '\( {DateTime.now().year}- \){ref.weekNumber}';
    map.putIfAbsent(currentKey, () => []);

    final keys = map.keys.toList()
      ..sort((a, b) {
        final pa = a.split('-');
        final pb = b.split('-');
        final ya = int.parse(pa[0]);
        final yb = int.parse(pb[0]);
        if (ya != yb) return yb.compareTo(ya);
        return int.parse(pb[1]).compareTo(int.parse(pa[1]));
      });

    return keys.map((key) {
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final week = int.parse(parts[1]);
      return _WeekSnapshot.fromBookings(
        bookings: map[key]!,
        weekNumber: week,
        year: year,
        weeklyTarget: weeklyTarget,
        proteinTarget: proteinTarget,
        carbsTarget: carbsTarget,
        fatTarget: fatTarget,
        fiberTarget: fiberTarget,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.settings.isDarkMode;
    final fmt = NumberFormat('#,###', 'de_DE');
    final weeks = _buildWeeks(state);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Übersicht',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'SCHLIESSEN',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Nach links wischen für ältere Wochen',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: PageView.builder(
                itemCount: weeks.length,
                itemBuilder: (context, index) {
                  final snap = weeks[index];
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'KW ${snap.weekNumber}',
                            style: TextStyle(
                              fontSize: 13,
                              letterSpacing: 1.5,
                              color: Colors.grey.shade500,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${snap.year}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        color:
                            isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                        height: 24,
                      ),
                      _WeekStatementBody(
                          snapshot: snap, isDark: isDark, fmt: fmt),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekSnapshot {
  final int weekNumber;
  final int year;
  final int weeklyTarget;
  final int spent;
  final Map<String, int> dayTotals;
  final Map<String, int> investmentDays;

  int get endBalance => weeklyTarget - spent;

  _WeekSnapshot({
    required this.weekNumber,
    required this.year,
    required this.weeklyTarget,
    required this.spent,
    required this.dayTotals,
    required this.investmentDays,
  });

  factory _WeekSnapshot.fromBookings({
    required List<Booking> bookings,
    required int weekNumber,
    required int year,
    required int weeklyTarget,
    required int proteinTarget,
    required int carbsTarget,
    required int fatTarget,
    required int fiberTarget,
  }) {
    const days = ['MO', 'DI', 'MI', 'DO', 'FR', 'SA', 'SO'];
    final dayTotals = {for (var d in days) d: 0};
    final byDay = <String, Map<String, double>>{};

    var spent = 0;
    for (final b in bookings) {
      spent += b.kcal;
      dayTotals[b.dayName] = (dayTotals[b.dayName] ?? 0) + b.kcal;
      byDay.putIfAbsent(
          b.dayName, () => {'protein': 0, 'carbs': 0, 'fat': 0, 'fiber': 0});
      byDay[b.dayName]!['protein'] =
          byDay[b.dayName]!['protein']! + b.protein;
      byDay[b.dayName]!['carbs'] = byDay[b.dayName]!['carbs']! + b.carbs;
      byDay[b.dayName]!['fat'] = byDay[b.dayName]!['fat']! + b.fat;
      byDay[b.dayName]!['fiber'] = byDay[b.dayName]!['fiber']! + b.fiber;
    }

    int proteinDays = 0, carbsDays = 0, fatDays = 0, fiberDays = 0;
    for (final day in byDay.values) {
      if (day['protein']! >= proteinTarget) proteinDays++;
      if (day['carbs']! >= carbsTarget) carbsDays++;
      if (day['fat']! >= fatTarget) fatDays++;
      if (day['fiber']! >= fiberTarget) fiberDays++;
    }

    return _WeekSnapshot(
      weekNumber: weekNumber,
      year: year,
      weeklyTarget: weeklyTarget,
      spent: spent,
      dayTotals: dayTotals,
      investmentDays: {
        'protein': proteinDays,
        'carbs': carbsDays,
        'fat': fatDays,
        'fiber': fiberDays,
      },
    );
  }
}

class _WeekStatementBody extends StatelessWidget {
  final _WeekSnapshot snapshot;
  final bool isDark;
  final NumberFormat fmt;

  const _WeekStatementBody({
    required this.snapshot,
    required this.isDark,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryRow(
            label: 'Anfangsbestand', value: fmt.format(snapshot.weeklyTarget)),
        _SummaryRow(
            label: 'Buchungen', value: '−${fmt.format(snapshot.spent)}'),
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
              fmt.format(snapshot.endBalance),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        Divider(
            color: isDark ? Colors.white : Colors.black,
            height: 40,
            thickness: 1.5),
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
          final kcal = snapshot.dayTotals[day] ?? 0;
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
                    backgroundColor:
                        isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                        isDark ? Colors.white : Colors.black),
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
        _InvestmentRow(
            label: 'Protein', days: snapshot.investmentDays['protein'] ?? 0),
        _InvestmentRow(
            label: 'Kohlenhydrate',
            days: snapshot.investmentDays['carbs'] ?? 0),
        _InvestmentRow(
            label: 'Fett', days: snapshot.investmentDays['fat'] ?? 0),
        _InvestmentRow(
            label: 'Ballaststoffe',
            days: snapshot.investmentDays['fiber'] ?? 0),
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
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'monospace', fontWeight: FontWeight.w600)),
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
            style: const TextStyle(
                fontFamily: 'monospace', fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}