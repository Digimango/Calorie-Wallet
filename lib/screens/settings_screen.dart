import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _weeklyCtrl;
  late TextEditingController _proteinCtrl;
  late TextEditingController _carbsCtrl;
  late TextEditingController _fatCtrl;
  late TextEditingController _fiberCtrl;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>().settings;
    _weeklyCtrl = TextEditingController(text: s.weeklyTarget.toString());
    _proteinCtrl = TextEditingController(text: s.proteinTarget.toString());
    _carbsCtrl = TextEditingController(text: s.carbsTarget.toString());
    _fatCtrl = TextEditingController(text: s.fatTarget.toString());
    _fiberCtrl = TextEditingController(text: s.fiberTarget.toString());
  }

  @override
  void dispose() {
    _weeklyCtrl.dispose();
    _proteinCtrl.dispose();
    _carbsCtrl.dispose();
    _fatCtrl.dispose();
    _fiberCtrl.dispose();
    super.dispose();
  }

  void _syncControllersFromState() {
    final s = context.read<AppState>().settings;
    _weeklyCtrl.text = s.weeklyTarget.toString();
    _proteinCtrl.text = s.proteinTarget.toString();
    _carbsCtrl.text = s.carbsTarget.toString();
    _fatCtrl.text = s.fatTarget.toString();
  }

  void _applyCalculated({
    required int dailyKcal,
    required int protein,
    required int carbs,
    required int fat,
  }) {
    final weekly = dailyKcal * 7;
    setState(() {
      _weeklyCtrl.text = weekly.toString();
      _proteinCtrl.text = protein.toString();
      _carbsCtrl.text = carbs.toString();
      _fatCtrl.text = fat.toString();
    });
    final state = context.read<AppState>();
    state.updateSettings(state.settings.copyWith(
      goal: 'halten',
      weeklyTarget: weekly,
      dailyTarget: dailyKcal,
      proteinTarget: protein,
      carbsTarget: carbs,
      fatTarget: fat,
      maintenanceWeekly: weekly,
    ));
  }

  Future<void> _onGoalTap(String goal) async {
    final state = context.read<AppState>();
    await state.setGoal(goal);
    if (!mounted) return;
    setState(_syncControllersFromState);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.settings.isDarkMode;
    final fmt = NumberFormat('#,###', 'de_DE');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        const Text(
          'Wochenlohn',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Konfiguriere deinen persönlichen Kalorienlohn.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        Divider(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          height: 32,
        ),

        Text(
          'ERNÄHRUNGSZIEL',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.8,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _GoalChip(
              label: 'Abnehmen',
              sub: state.settings.goal == 'abnehmen'
                  ? '${fmt.format(state.settings.weeklyTarget)} kcal'
                  : 'Defizit',
              selected: state.settings.goal == 'abnehmen',
              onTap: () => _onGoalTap('abnehmen'),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _GoalChip(
              label: 'Halten',
              sub: state.settings.goal == 'halten'
                  ? '${fmt.format(state.settings.weeklyTarget)} kcal'
                  : 'Erhalt',
              selected: state.settings.goal == 'halten',
              onTap: () => _onGoalTap('halten'),
              isDark: isDark,
            ),
            const SizedBox(width: 8),
            _GoalChip(
              label: 'Aufbau',
              sub: state.settings.goal == 'aufbau'
                  ? '${fmt.format(state.settings.weeklyTarget)} kcal'
                  : 'Überschuss',
              selected: state.settings.goal == 'aufbau',
              onTap: () => _onGoalTap('aufbau'),
              isDark: isDark,
            ),
          ],
        ),
        const SizedBox(height: 28),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WOCHENLOHN (KCAL)',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.8,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _weeklyCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: () async {
                  final result =
                      await Navigator.of(context).push<Map<String, dynamic>>(
                    MaterialPageRoute(
                      builder: (_) => const CalorieCalculatorScreen(),
                    ),
                  );
                  if (result != null && mounted) {
                    _applyCalculated(
                      dailyKcal: result['daily'] as int,
                      protein: result['protein'] as int,
                      carbs: result['carbs'] as int,
                      fat: result['fat'] as int,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lohn & Makros übernommen (Halten)'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                  side: BorderSide(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(
                  'LOHN\nBERECHNEN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    height: 1.2,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Empfohlene Tagesausgabe: ${fmt.format(((int.tryParse(_weeklyCtrl.text) ?? state.settings.weeklyTarget) / 7).round())} kcal',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 28),

        Text(
          'INVESTMENT ZIELE (TÄGLICH IN GRAMM)',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.8,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MacroInput(
                label: 'Protein',
                controller: _proteinCtrl,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MacroInput(
                label: 'Kohlenhydrate',
                controller: _carbsCtrl,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MacroInput(
                label: 'Fett',
                controller: _fatCtrl,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MacroInput(
                label: 'Ballaststoffe',
                controller: _fiberCtrl,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            final weekly = int.tryParse(_weeklyCtrl.text) ?? 14000;
            state.updateSettings(state.settings.copyWith(
              proteinTarget: int.tryParse(_proteinCtrl.text) ?? 160,
              carbsTarget: int.tryParse(_carbsCtrl.text) ?? 220,
              fatTarget: int.tryParse(_fatCtrl.text) ?? 70,
              fiberTarget: int.tryParse(_fiberCtrl.text) ?? 30,
              weeklyTarget: weekly,
              dailyTarget: (weekly / 7).round(),
              // Manueller Wochenlohn = neue Basis, wenn Ziel Halten
              maintenanceWeekly: state.settings.goal == 'halten'
                  ? weekly
                  : state.settings.maintenanceWeekly,
            ));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Einstellungen gespeichert'),
                duration: Duration(seconds: 1),
              ),
            );
          },
          child: const Text('SPEICHERN'),
        ),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(16),
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 8),
                  Text(
                    'CALORIE WALLET PHILOSOPHIE',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Keine Moral. Kein Lebensmittel ist „gut“ oder „schlecht“. Du verwaltest dein Kalorienbudget flexibel über die Woche.\n\n„Lohn berechnen“ setzt immer den Erhalt (Halten). Abnehmen und Aufbau werden davon abgeleitet (−500 / +300 kcal pro Tag).',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Rechner berechnet immer nur den Erhalt (Halten / TDEE)
class CalorieCalculatorScreen extends StatefulWidget {
  const CalorieCalculatorScreen({super.key});

  @override
  State<CalorieCalculatorScreen> createState() =>
      _CalorieCalculatorScreenState();
}

class _CalorieCalculatorScreenState extends State<CalorieCalculatorScreen> {
  final _ageCtrl = TextEditingController(text: '30');
  final _weightCtrl = TextEditingController(text: '80');
  final _heightCtrl = TextEditingController(text: '180');
  bool _isMale = true;
  String _activity = 'moderat';

  static const _activityFactors = {
    'sitzend': 1.2,
    'leicht': 1.375,
    'moderat': 1.55,
    'aktiv': 1.725,
    'sehr aktiv': 1.9,
  };

  @override
  void dispose() {
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  int? _calculateDaily() {
    final age = int.tryParse(_ageCtrl.text);
    final weight = double.tryParse(_weightCtrl.text.replaceAll(',', '.'));
    final height = double.tryParse(_heightCtrl.text.replaceAll(',', '.'));
    if (age == null || weight == null || height == null) return null;
    if (age < 10 || age > 100 || weight < 30 || height < 100) return null;

    double bmr;
    if (_isMale) {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }
    final tdee = bmr * (_activityFactors[_activity] ?? 1.55);
    return tdee.round().clamp(1200, 6000);
  }

  Map<String, int> _macros(int daily) {
    // immer Halten-Verteilung
    const pct = [0.27, 0.50, 0.23];
    return {
      'protein': (daily * pct[0] / 4).round(),
      'carbs': (daily * pct[1] / 4).round(),
      'fat': (daily * pct[2] / 9).round(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppState>().settings.isDarkMode;
    final daily = _calculateDaily();
    final macros = daily != null ? _macros(daily) : null;
    final fmt = NumberFormat('#,###', 'de_DE');

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lohn berechnen',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'ABBRECHEN',
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
            Divider(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              height: 24,
            ),
            Text(
              'Berechnet immer den Erhalt (Halten). Abnehmen/Aufbau wählst du danach auf der Lohn-Seite.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            Text('GESCHLECHT',
                style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(
              children: [
                _CalcChip(
                  label: 'Männlich',
                  selected: _isMale,
                  onTap: () => setState(() => _isMale = true),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _CalcChip(
                  label: 'Weiblich',
                  selected: !_isMale,
                  onTap: () => setState(() => _isMale = false),
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _CalcField(
                    label: 'Alter',
                    controller: _ageCtrl,
                    isDark: isDark,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CalcField(
                    label: 'Gewicht (kg)',
                    controller: _weightCtrl,
                    isDark: isDark,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CalcField(
                    label: 'Größe (cm)',
                    controller: _heightCtrl,
                    isDark: isDark,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('AKTIVITÄT',
                style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _activityFactors.keys.map((a) {
                return _CalcChip(
                  label: a,
                  selected: _activity == a,
                  onTap: () => setState(() => _activity = a),
                  isDark: isDark,
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            if (daily != null && macros != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ERHALT (HALTEN)',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${fmt.format(daily)} kcal / Tag',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Wochenlohn: ${fmt.format(daily * 7)} kcal',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Protein ${macros['protein']} g  ·  '
                      'Kohlenhydrate ${macros['carbs']} g  ·  '
                      'Fett ${macros['fat']} g',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'daily': daily,
                      'protein': macros['protein'],
                      'carbs': macros['carbs'],
                      'fat': macros['fat'],
                    });
                  },
                  child: const Text('ÜBERNEHMEN'),
                ),
              ),
            ] else
              Text(
                'Bitte Alter, Gewicht und Größe ausfüllen.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
          ],
        ),
      ),
    );
  }
}

class _CalcChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _CalcChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? Colors.white : Colors.black)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? (isDark ? Colors.white : Colors.black)
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? (isDark ? Colors.black : Colors.white)
                : null,
          ),
        ),
      ),
    );
  }
}

class _CalcField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _CalcField({
    required this.label,
    required this.controller,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 15),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final String sub;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _GoalChip({
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? Colors.white : Colors.black)
                : Colors.transparent,
            border: Border.all(
              color: selected
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            ),
          ),
          child: Column(
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: selected
                      ? (isDark ? Colors.black : Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  color: selected
                      ? (isDark ? Colors.black54 : Colors.white70)
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isDark;

  const _MacroInput({
    required this.label,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 15),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            isDense: true,
          ),
        ),
      ],
    );
  }
}