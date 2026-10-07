class AppSettings {
  final String goal; // 'abnehmen' | 'halten' | 'aufbau'
  final int weeklyTarget; // kcal
  final int dailyTarget; // empfohlen
  final int proteinTarget;
  final int carbsTarget;
  final int fatTarget;
  final int fiberTarget;
  final int rollover; // übertragene kcal aus Vorwoche
  final bool isDarkMode;
  final int lastRolloverWeek;
  final int lastRolloverYear;

  const AppSettings({
    this.goal = 'halten',
    this.weeklyTarget = 14000,
    this.dailyTarget = 2000,
    this.proteinTarget = 160,
    this.carbsTarget = 220,
    this.fatTarget = 70,
    this.fiberTarget = 30,
    this.rollover = 0,
    this.isDarkMode = false,
    this.lastRolloverWeek = 0,
    this.lastRolloverYear = 0,
  });

  AppSettings copyWith({
    String? goal,
    int? weeklyTarget,
    int? dailyTarget,
    int? proteinTarget,
    int? carbsTarget,
    int? fatTarget,
    int? fiberTarget,
    int? rollover,
    bool? isDarkMode,
    int? lastRolloverWeek,
    int? lastRolloverYear,
  }) {
    return AppSettings(
      goal: goal ?? this.goal,
      weeklyTarget: weeklyTarget ?? this.weeklyTarget,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      proteinTarget: proteinTarget ?? this.proteinTarget,
      carbsTarget: carbsTarget ?? this.carbsTarget,
      fatTarget: fatTarget ?? this.fatTarget,
      fiberTarget: fiberTarget ?? this.fiberTarget,
      rollover: rollover ?? this.rollover,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      lastRolloverWeek: lastRolloverWeek ?? this.lastRolloverWeek,
      lastRolloverYear: lastRolloverYear ?? this.lastRolloverYear,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      goal: json['goal'] as String? ?? 'halten',
      weeklyTarget: json['weeklyTarget'] as int? ?? 14000,
      dailyTarget: json['dailyTarget'] as int? ?? 2000,
      proteinTarget: json['proteinTarget'] as int? ?? 160,
      carbsTarget: json['carbsTarget'] as int? ?? 220,
      fatTarget: json['fatTarget'] as int? ?? 70,
      fiberTarget: json['fiberTarget'] as int? ?? 30,
      rollover: json['rollover'] as int? ?? 0,
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      lastRolloverWeek: json['lastRolloverWeek'] as int? ?? 0,
      lastRolloverYear: json['lastRolloverYear'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'goal': goal,
        'weeklyTarget': weeklyTarget,
        'dailyTarget': dailyTarget,
        'proteinTarget': proteinTarget,
        'carbsTarget': carbsTarget,
        'fatTarget': fatTarget,
        'fiberTarget': fiberTarget,
        'rollover': rollover,
        'isDarkMode': isDarkMode,
        'lastRolloverWeek': lastRolloverWeek,
        'lastRolloverYear': lastRolloverYear,
      };
}
