class FoodItem {
  final String id;
  final String name;
  final double kcal; // pro 100 g
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final String unit;
  final double defaultPortion;
  final String? barcode;

  const FoodItem({
    required this.id,
    required this.name,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    this.unit = 'g',
    this.defaultPortion = 100,
    this.barcode,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      kcal: (json['kcal'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'g',
      defaultPortion: (json['defaultPortion'] as num?)?.toDouble() ?? 100,
      barcode: json['barcode'] as String?,
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
        'unit': unit,
        'defaultPortion': defaultPortion,
        if (barcode != null) 'barcode': barcode,
      };

  FoodItem copyWith({
    String? id,
    String? name,
    double? kcal,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    String? unit,
    double? defaultPortion,
    String? barcode,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      unit: unit ?? this.unit,
      defaultPortion: defaultPortion ?? this.defaultPortion,
      barcode: barcode ?? this.barcode,
    );
  }
}