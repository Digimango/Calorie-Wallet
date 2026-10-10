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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.settings.isDarkMode;
    final fmt = NumberFormat('#,###', 'de_DE');
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Wochenlohn & Einstellungen',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                if (canPop)
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
            const SizedBox(height: 4),
            Text(
              'Konfiguriere deinen persönlichen Kalorienlohn.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            Divider(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              height: 32,
            ),

            // MODUS Hell / Dunkel
            Text(
              'MODUS',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.8,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w700,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(state.settings.isDarkMode ? 'Dunkel' : 'Hell'),
              value: state.settings.isDarkMode,
              activeColor: isDark ? Colors.white : Colors.black,
              onChanged: (_) => state.toggleDarkMode(),
            ),
            const SizedBox(height: 12),

            // TAGESBUDGET An / Aus
            Text(
              'TAGESBUDGET',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.8,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w700,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(state.settings.showDayMarkers ? 'An' : 'Aus'),
              subtitle: const Text(
                'Striche auf der Wochenleiste (1 Tagesbudget je Strich)',
                style: TextStyle(fontSize: 12),
              ),
              value: state.settings.showDayMarkers,
              activeColor: isDark ? Colors.white : Colors.black,
              onChanged: (v) {
                state.updateSettings(
                  state.settings.copyWith(showDayMarkers: v),
                );
              },
            ),
            const SizedBox(height: 20),

            // Ernährungsziel
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
                  sub: '12.600 kcal',
                  selected: state.settings.goal == 'abnehmen',
                  onTap: () => state.setGoal('abnehmen'),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _GoalChip(
                  label: 'Halten',
                  sub: '14.000 kcal',
                  selected: state.settings.goal == 'halten',
                  onTap: () => state.setGoal('halten'),
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _GoalChip(
                  label: 'Aufbau',
                  sub: '15.400 kcal',
                  selected: state.settings.goal == 'aufbau',
                  onTap: () => state.setGoal('aufbau'),
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Manueller Wochenlohn
            Text(
              'MANUELLER WOCHENLOHN (KCAL)',
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
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
              onSubmitted: (v) {
                final val = int.tryParse(v) ?? state.settings.weeklyTarget;
                state.updateSettings(state.settings.copyWith(
                  weeklyTarget: val,
                  dailyTarget: (val / 7).round(),
                ));
              },
            ),
            const SizedBox(height: 6),
            Text(
              'Empfohlene Tagesausgabe: ${fmt.format(state.settings.dailyTarget)} kcal',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 28),

            // Investment Ziele
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
                state.updateSettings(state.settings.copyWith(
                  proteinTarget: int.tryParse(_proteinCtrl.text) ?? 160,
                  carbsTarget: int.tryParse(_carbsCtrl.text) ?? 220,
                  fatTarget: int.tryParse(_fatCtrl.text) ?? 70,
                  fiberTarget: int.tryParse(_fiberCtrl.text) ?? 30,
                  weeklyTarget: int.tryParse(_weeklyCtrl.text) ?? 14000,
                  dailyTarget:
                      ((int.tryParse(_weeklyCtrl.text) ?? 14000) / 7).round(),
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

            // Philosophie
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
                    'Keine Moral. Kein Lebensmittel ist „gut“ oder „schlecht“. Du verwaltest dein Kalorienbudget flexibel über die Woche. Hohe Ausgaben an einem Tag werden einfach über den Rest der Woche ausgeglichen.',
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
        ),
      ),
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