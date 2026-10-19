import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/booking.dart';
import '../models/settings.dart';
import '../models/food_item.dart';

class StorageService {
  static const String _bookingsBox = 'bookings';
  static const String _settingsBox = 'settings';
  static const String _foodsBox = 'custom_foods';
  static const String _settingsKey = 'app_settings';
  static const String _foodsKey = 'items';

  late Box _bookings;
  late Box _settings;
  late Box _foods;

  Future<void> init() async {
    await Hive.initFlutter();
    _bookings = await Hive.openBox(_bookingsBox);
    _settings = await Hive.openBox(_settingsBox);
    _foods = await Hive.openBox(_foodsBox);
  }

  // ---------- Settings ----------
  AppSettings loadSettings() {
    final raw = _settings.get(_settingsKey);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw as String)));
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settings.put(_settingsKey, jsonEncode(settings.toJson()));
  }

  // ---------- Custom foods (offline) ----------
  List<FoodItem> loadCustomFoods() {
    final raw = _foods.get(_foodsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw as String) as List<dynamic>;
      return list
          .map((e) =>
              FoodItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCustomFoods(List<FoodItem> items) async {
    final encoded =
        jsonEncode(items.map((e) => e.toJson()).toList());
    await _foods.put(_foodsKey, encoded);
  }

  // ---------- Bookings ----------
  List<Booking> loadAllBookings() {
    final list = <Booking>[];
    for (final key in _bookings.keys) {
      try {
        final raw = _bookings.get(key);
        if (raw != null) {
          list.add(Booking.fromJson(
              Map<String, dynamic>.from(jsonDecode(raw as String))));
        }
      } catch (_) {
        // skip corrupt entry
      }
    }
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> saveBooking(Booking booking) async {
    await _bookings.put(booking.id, jsonEncode(booking.toJson()));
  }

  Future<void> deleteBooking(String id) async {
    await _bookings.delete(id);
  }

  Future<void> clearAllBookings() async {
    await _bookings.clear();
  }

  List<Booking> loadCurrentWeekBookings() {
    final now = DateTime.now();
    final currentWeek = Booking(
      name: '',
      kcal: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      fiber: 0,
      category: '',
    ).weekNumber;
    final year = now.year;
    return loadAllBookings()
        .where((b) => b.weekNumber == currentWeek && b.year == year)
        .toList();
  }

  List<Booking> loadTodayBookings() {
    final now = DateTime.now();
    return loadAllBookings().where((b) {
      return b.timestamp.year == now.year &&
          b.timestamp.month == now.month &&
          b.timestamp.day == now.day;
    }).toList();
  }
}