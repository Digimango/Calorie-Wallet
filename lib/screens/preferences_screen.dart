import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.settings.isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Einstellung',
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
            Divider(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              height: 32,
            ),

            // MODUS
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
            const SizedBox(height: 16),

            // TAGESBUDGET
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
          ],
        ),
      ),
    );
  }
}