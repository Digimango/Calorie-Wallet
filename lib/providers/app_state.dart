import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/booking.dart';
import '../models/settings.dart';
import '../models/food_item.dart';
import '../services/storage_service.dart';
import '../services/open_food_facts_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage;
  final OpenFoodFactsService _off = OpenFoodFactsService();

  AppSettings settings = const AppSettings();
  List<Booking> allBookings = [];
  List<Booking> todayBookings = [];
  List<Booking> weekBookings = [];

  bool isLoading = true;
  String? error;

  AppState(this._storage);

  Future<void> init() async {
    isLoading = true;
    notifyListeners();
    try {
      settings = _storage.loadSettings();
      allBookings = _storage.loadAllBookings();
      _recalculateLists();
      await _checkWeekRollover();
      await updateHomeWidget();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _recalculateLists() {
    final now = DateTime.now();
    todayBookings = allBookings.where((b) {
      return b.timestamp.year == now.year &&
          b.timestamp.month == now.month &&
          b.timestamp.day == now.day;
    }).toList();

    final ref = Booking(
      name: '',
      kcal: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      fiber: 0,
      category: '',
    );
    final currentWeek = ref.weekNumber;
    weekBookings = allBookings
        .where((b) => b.weekNumber == currentWeek && b.year == now.year)
        .toList();
  }

  /// Neue Woche → Rollover auf 0, Wochenbudget = Lohn-Einstellung
  Future<void> _checkWeekRollover() async {
    final ref = Booking(
      name: '',
      kcal: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      fiber: 0,
      category: '',
    );
    final currentWeek = ref.weekNumber;
    final currentYear = DateTime.now().year;

    if (settings.lastRolloverWeek != currentWeek ||
        settings.lastRolloverYear != currentYear) {
      await updateSettings(settings.copyWith(
        rollover: 0,
        lastRolloverWeek: currentWeek,
        lastRolloverYear: currentYear,
      ));
    }
  }

  // ---------- Berechnungen ----------
  int get totalSpentWeek {
    return weekBookings.fold(0, (sum, b) => sum + b.kcal);
  }

  /// Immer: Wochenlohn − Ausgaben der aktuellen Woche (kein Übertrag)
  int get totalAvailable {
    return settings.weeklyTarget - totalSpentWeek;
  }

  int get todaySpent {
    return todayBookings.fold(0, (sum, b) => sum + b.kcal);
  }

  Map<String, double> get todayMacros {
    return todayBookings.fold(
      {'protein': 0.0, 'carbs': 0.0, 'fat': 0.0, 'fiber': 0.0},
      (acc, b) {
        acc['protein'] = acc['protein']! + b.protein;
        acc['carbs'] = acc['carbs']! + b.carbs;
        acc['fat'] = acc['fat']! + b.fat;
        acc['fiber'] = acc['fiber']! + b.fiber;
        return acc;
      },
    );
  }

  Map<String, int> get weekDayTotals {
    const days = ['MO', 'DI', 'MI', 'DO', 'FR', 'SA', 'SO'];
    final map = {for (var d in days) d: 0};
    for (final b in weekBookings) {
      map[b.dayName] = (map[b.dayName] ?? 0) + b.kcal;
    }
    return map;
  }

  Map<String, int> get investmentDaysReached {
    final byDay = <String, Map<String, double>>{};
    for (final b in weekBookings) {
      byDay.putIfAbsent(
          b.dayName,
          () => {'protein': 0, 'carbs': 0, 'fat': 0, 'fiber': 0});
      byDay[b.dayName]!['protein'] =
          byDay[b.dayName]!['protein']! + b.protein;
      byDay[b.dayName]!['carbs'] = byDay[b.dayName]!['carbs']! + b.carbs;
      byDay[b.dayName]!['fat'] = byDay[b.dayName]!['fat']! + b.fat;
      byDay[b.dayName]!['fiber'] = byDay[b.dayName]!['fiber']! + b.fiber;
    }

    int proteinDays = 0, carbsDays = 0, fatDays = 0, fiberDays = 0;
    for (final day in byDay.values) {
      if (day['protein']! >= settings.proteinTarget) proteinDays++;
      if (day['carbs']! >= settings.carbsTarget) carbsDays++;
      if (day['fat']! >= settings.fatTarget) fatDays++;
      if (day['fiber']! >= settings.fiberTarget) fiberDays++;
    }
    return {
      'protein': proteinDays,
      'carbs': carbsDays,
      'fat': fatDays,
      'fiber': fiberDays,
    };
  }

  // ---------- Homescreen-Widget ----------
  String _fmt(int n) {
    final s = n.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return n < 0 ? '−$buf' : buf.toString();
  }

  Future<void> updateHomeWidget() async {
    try {
      final available = totalAvailable;
      final spent = totalSpentWeek;
      final target = settings.weeklyTarget;
      final pct = target > 0
          ? ((spent / target) * 100).clamp(0, 100).round()
          : 0;

      await HomeWidget.saveWidgetData<String>('available', _fmt(available));
      await HomeWidget.saveWidgetData<String>('spent', _fmt(spent));
      await HomeWidget.saveWidgetData<String>('target', _fmt(target));
      await HomeWidget.saveWidgetData<int>('progress', pct);
      await HomeWidget.updateWidget(
        name: 'CalorieWalletWidgetProvider',
        androidName: 'CalorieWalletWidgetProvider',
      );
    } catch (_) {
      // Widget optional – Fehler ignorieren
    }
  }

  // ---------- Actions ----------
  Future<void> addBooking({
    required FoodItem food,
    required double portionGrams,
    required String category,
  }) async {
    final ratio = portionGrams / 100.0;
    final booking = Booking(
      name: food.name,
      kcal: (food.kcal * ratio).round(),
      protein: double.parse((food.protein * ratio).toStringAsFixed(1)),
      carbs: double.parse((food.carbs * ratio).toStringAsFixed(1)),
      fat: double.parse((food.fat * ratio).toStringAsFixed(1)),
      fiber: double.parse((food.fiber * ratio).toStringAsFixed(1)),
      category: category,
    );
    await _storage.saveBooking(booking);
    allBookings.insert(0, booking);
    _recalculateLists();
    notifyListeners();
    await updateHomeWidget();
  }

  Future<void> deleteBooking(String id) async {
    await _storage.deleteBooking(id);
    allBookings.removeWhere((b) => b.id == id);
    _recalculateLists();
    notifyListeners();
    await updateHomeWidget();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    settings = newSettings;
    await _storage.saveSettings(settings);
    notifyListeners();
    await updateHomeWidget();
  }

  Future<void> setGoal(String goal) async {
    await updateSettings(settings.copyWith(goal: goal));
  }

  Future<void> toggleDarkMode() async {
    await updateSettings(settings.copyWith(isDarkMode: !settings.isDarkMode));
  }

  // ---------- Open Food Facts ----------
  Future<List<FoodItem>> searchFood(String query) => _off.searchProducts(query);

  Future<FoodItem?> getByBarcode(String barcode) =>
      _off.getProductByBarcode(barcode);
}