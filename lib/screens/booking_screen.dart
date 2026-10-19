import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/food_item.dart';
import '../models/booking.dart';
import 'add_food_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String _category = 'Frühstück';
  final _searchCtrl = TextEditingController();
  List<FoodItem> _results = [];
  FoodItem? _selected;
  double _portion = 100;
  bool _showScanner = false;
  bool _scanned = false;

  final _categories = ['Frühstück', 'Mittag', 'Abend', 'Snack'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<FoodItem> _recentFoods(AppState state) {
    final seen = <String>{};
    final result = <FoodItem>[];
    final all = List<Booking>.from(state.allBookings)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    for (final b in all) {
      if (seen.add(b.name)) {
        result.add(FoodItem(
          id: b.name,
          name: b.name,
          kcal: b.kcal.toDouble(),
          protein: b.protein,
          carbs: b.carbs,
          fat: b.fat,
          fiber: b.fiber,
          defaultPortion: 100,
        ));
        if (result.length >= 20) break;
      }
    }
    return result;
  }

  void _onSearchChanged(String q) {
    final trimmed = q.trim();
    if (trimmed.isEmpty) {
      setState(() => _results = []);
      return;
    }
    final results = context.read<AppState>().searchFood(trimmed);
    setState(() => _results = results);
  }

  Future<void> _openAddFood({String? barcode}) async {
    final created = await Navigator.of(context).push<FoodItem>(
      MaterialPageRoute(
        builder: (_) => AddFoodScreen(barcode: barcode),
      ),
    );
    if (created == null || !mounted) return;
    await context.read<AppState>().saveCustomFood(created);
    if (!mounted) return;
    _selectFood(created);
  }

  Future<void> _onBarcode(String barcode) async {
    if (_scanned) return;
    _scanned = true;
    final state = context.read<AppState>();
    final item = state.getByBarcode(barcode);
    if (!mounted) return;

    setState(() {
      _showScanner = false;
      _scanned = false;
    });

    if (item != null) {
      _selectFood(item);
    } else {
      await _openAddFood(barcode: barcode);
    }
  }

  void _selectFood(FoodItem item) {
    setState(() {
      _selected = item;
      _portion = item.defaultPortion;
      _searchCtrl.clear();
      _results = [];
    });
  }

  void _book() {
    if (_selected == null) return;
    context.read<AppState>().addBooking(
          food: _selected!,
          portionGrams: _portion,
          category: _category,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = state.settings.isDarkMode;
    final fmt = NumberFormat('#,###', 'de_DE');
    final recent = _recentFoods(state);

    return Scaffold(
      body: SafeArea(
        child: _showScanner
            ? _buildScanner()
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Buchung',
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
                    height: 24,
                  ),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((c) {
                        final selected = c == _category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _category = c),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              color: selected
                                  ? (isDark ? Colors.white : Colors.black)
                                  : (isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade100),
                              child: Text(
                                c.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: selected
                                      ? (isDark ? Colors.black : Colors.white)
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Offline suchen…',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(
                                  color: isDark ? Colors.white : Colors.black),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => setState(() {
                          _showScanner = true;
                          _scanned = false;
                        }),
                        icon: const Icon(Icons.qr_code_scanner),
                        style: IconButton.styleFrom(
                          side: BorderSide(
                              color: isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_results.isNotEmpty && _searchCtrl.text.trim().isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade100),
                        itemBuilder: (_, i) {
                          final item = _results[i];
                          return ListTile(
                            dense: true,
                            title: Text(item.name,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            trailing: Text(
                              '${item.kcal.round()} kcal/100g',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  color: Colors.grey.shade500),
                            ),
                            onTap: () => _selectFood(item),
                          );
                        },
                      ),
                    )
                  else if (_searchCtrl.text.trim().isNotEmpty &&
                      _results.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Nicht in der Offline-Liste – unten hinzufügen.',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ),

                  const SizedBox(height: 24),

                  if (_selected == null) ...[
                    const Center(
                      child: Text(
                        'Zuletzt gekauft',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (recent.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'Noch keine Buchungen.\nSuche offline oder füge ein Lebensmittel hinzu.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      )
                    else
                      ...recent.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => _selectFood(item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Text(
                                    '${item.kcal.round()} kcal',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _openAddFood(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                          side: BorderSide(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        child: Text(
                          'LEBENSMITTEL HINZUFÜGEN',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (_selected != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selected!.name,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _selected = null),
                          child: Text(
                            'ZURÜCK',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'PORTION',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.8,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_portion.round()} ${_selected!.unit}',
                            style: const TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                                fontSize: 18),
                          ),
                          Row(
                            children: [
                              _PortionBtn(
                                label: '−',
                                onTap: () => setState(() =>
                                    _portion = (_portion - 10).clamp(10, 2000)),
                                isDark: isDark,
                              ),
                              const SizedBox(width: 8),
                              _PortionBtn(
                                label: '+',
                                onTap: () => setState(() =>
                                    _portion = (_portion + 10).clamp(10, 2000)),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Builder(builder: (_) {
                      final ratio = _portion / 100.0;
                      final currentKcal = (_selected!.kcal * ratio).round();
                      final currentProtein = double.parse(
                          (_selected!.protein * ratio).toStringAsFixed(1));
                      final currentCarbs = double.parse(
                          (_selected!.carbs * ratio).toStringAsFixed(1));
                      final currentFat = double.parse(
                          (_selected!.fat * ratio).toStringAsFixed(1));
                      final currentFiber = double.parse(
                          (_selected!.fiber * ratio).toStringAsFixed(1));
                      final availableAfter =
                          state.totalAvailable - currentKcal;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PREIS',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.8,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$currentKcal kcal',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'EINZAHLUNG INS INVESTMENT',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.8,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _InvestRow(
                              label: 'Protein', value: '$currentProtein g'),
                          _InvestRow(
                              label: 'Kohlenhydrate',
                              value: '$currentCarbs g'),
                          _InvestRow(label: 'Fett', value: '$currentFat g'),
                          _InvestRow(
                              label: 'Ballaststoffe',
                              value: '$currentFiber g'),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'VERFÜGBAR NACH BUCHUNG',
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${fmt.format(availableAfter)} kcal',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _book,
                              child: const Text('BUCHEN'),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final barcodes = capture.barcodes;
            if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
              _onBarcode(barcodes.first.rawValue!);
            }
          },
        ),
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            onPressed: () => setState(() => _showScanner = false),
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            style: IconButton.styleFrom(backgroundColor: Colors.black54),
          ),
        ),
        Positioned(
          bottom: 48,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Colors.black87,
              child: const Text(
                'Barcode in den Rahmen halten',
                style: TextStyle(color: Colors.white, letterSpacing: 0.8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PortionBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  const _PortionBtn(
      {required this.label, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
        ),
        child: Text(label,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _InvestRow extends StatelessWidget {
  final String label;
  final String value;
  const _InvestRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'monospace', fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}