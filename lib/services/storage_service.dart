import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/booking.dart';
import '../models/settings.dart';

class StorageService {
  static const String _bookingsBox = 'bookings';
  static const String _settingsBox = 'settings';
  static const String _settingsKey = 'app_settings';

  late Box _bookings;
  late Box _settings;

  Future<void> init() async {
    await Hive.initFlutter();
    _bookings = await Hive.openBox(_bookingsBox);
    _settings = await Hive.openBox(_settingsBox);
  }

  // ---------- Settings ----------
  AppSettings loadSettings() {
    final raw = _settings.get(_settingsKey);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(Map<String, dynamic>.from(jsonDecode(raw as String)));
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settings.put(_settingsKey, jsonEncode(settings.toJson()));
  }

  // ---------- Bookings ----------
  List<Booking> loadAllBookings() {
    final list = <Booking>[];
    for (final key in _bookings.keys) {
      try {
        final raw = _bookings.get(key);
        if (raw != null) {
          list.add(Booking.fromJson(Map<String, dynamic>.from(jsonDecode(raw as String))));
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

  /// Bookings der aktuellen ISO-Woche
  List<Booking> loadCurrentWeekBookings() {
    final now = DateTime.now();
    final currentWeek = Booking(name: '', kcal: 0, protein: 0, carbs: 0, fat: 0, fiber: 0, category: '').weekNumber;
    final year = now.year;
    return loadAllBookings()
        .where((b) => b.weekNumber == currentWeek && b.year == year)
        .toList();
  }

  /// Bookings eines bestimmten Tages (heute)
  List<Booking> loadTodayBookings() {
    final now = DateTime.now();
    return loadAllBookings().where((b) {
      return b.timestamp.year == now.year &&
          b.timestamp.month == now.month &&
          b.timestamp.day == now.day;
    }).toList();
  }
}
