class FoodItem {
  final String id;
  final String name;
  final double kcal; // per 100g
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final String unit;
  final double defaultPortion;

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
      };
}

/// Offline-Fallback + Schnellzugriff
const List<FoodItem> mockFoods = [
  FoodItem(id: '1', name: 'Haferflocken', kcal: 370, protein: 13.5, carbs: 58.7, fat: 7.0, fiber: 10.0, defaultPortion: 80),
  FoodItem(id: '2', name: 'Magerquark', kcal: 67, protein: 12.0, carbs: 4.0, fat: 0.2, fiber: 0, defaultPortion: 250),
  FoodItem(id: '3', name: 'Vollkornbrot', kcal: 210, protein: 7.0, carbs: 38.0, fat: 1.5, fiber: 7.0, defaultPortion: 100),
  FoodItem(id: '4', name: 'Banane (mittel)', kcal: 89, protein: 1.1, carbs: 22.8, fat: 0.3, fiber: 2.6, defaultPortion: 120),
  FoodItem(id: '5', name: 'Hähnchenbrustfilet', kcal: 110, protein: 23.0, carbs: 0, fat: 1.2, fiber: 0, defaultPortion: 150),
  FoodItem(id: '6', name: 'Avocado', kcal: 160, protein: 2.0, carbs: 8.5, fat: 14.7, fiber: 6.7, defaultPortion: 100),
  FoodItem(id: '7', name: 'Mandeln', kcal: 579, protein: 21.0, carbs: 22.0, fat: 49.0, fiber: 12.0, defaultPortion: 30),
  FoodItem(id: '8', name: 'Protein Shake (Schoko)', kcal: 120, protein: 24.0, carbs: 3.0, fat: 1.5, fiber: 1.0, defaultPortion: 30),
  FoodItem(id: '9', name: 'Pizza Margherita', kcal: 260, protein: 10.0, carbs: 33.0, fat: 9.5, fiber: 2.2, defaultPortion: 350),
  FoodItem(id: '10', name: 'Lachsfilet', kcal: 208, protein: 20.0, carbs: 0, fat: 13.0, fiber: 0, defaultPortion: 150),
];
