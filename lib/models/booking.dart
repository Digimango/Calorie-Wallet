import 'package:uuid/uuid.dart';

class Booking {
  final String id;
  final String name;
  final int kcal;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final String category; // Frühstück, Mittag, Abend, Snack
  final DateTime timestamp;
  final int weekNumber;
  final int year;

  Booking({
    String? id,
    required this.name,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.category,
    DateTime? timestamp,
    int? weekNumber,
    int? year,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now(),
        weekNumber = weekNumber ?? _isoWeekNumber(timestamp ?? DateTime.now()),
        year = year ?? (timestamp ?? DateTime.now()).year;

  static int _isoWeekNumber(DateTime date) {
    // ISO 8601 week number
    final thursday = date.add(Duration(days: 4 - date.weekday));
    final firstDay = DateTime(thursday.year, 1, 1);
    return ((thursday.difference(firstDay).inDays) / 7).floor() + 1;
  }

  String get dayName {
    const days = ['MO', 'DI', 'MI', 'DO', 'FR', 'SA', 'SO'];
    // DateTime.weekday: 1=Monday ... 7=Sunday
    return days[timestamp.weekday - 1];
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      name: json['name'] as String,
      kcal: json['kcal'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      category: json['category'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      weekNumber: json['weekNumber'] as int?,
      year: json['year'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'kcal': kcal,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
        'category': category,
        'timestamp': timestamp.toIso8601String(),
        'weekNumber': weekNumber,
        'year': year,
      };
}
