import 'package:openfoodfacts/openfoodfacts.dart';
import '../models/food_item.dart';

class OpenFoodFactsService {
  OpenFoodFactsService() {
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'CalorieWallet',
      version: '1.0.0',
      system: 'Flutter',
      url: 'https://github.com/calorie-wallet',
      comment: 'Personal calorie budget app',
    );
    OpenFoodAPIConfiguration.globalLanguages = [
      OpenFoodFactsLanguage.GERMAN,
      OpenFoodFactsLanguage.ENGLISH,
    ];
    OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.GERMANY;
  }

  Future<List<FoodItem>> searchProducts(String query) async {
    final q = query.trim();
    if (q.length < 2) return [];

    try {
      // 1. Versuch: Deutschland
      var items = await _search(q, country: OpenFoodFactsCountry.GERMANY);

      // 2. Fallback: weltweit, falls zu wenig Treffer
      if (items.length < 5) {
        final world = await _search(q, country: null);
        final seen = items.map((e) => e.id).toSet();
        for (final w in world) {
          if (seen.add(w.id)) items.add(w);
        }
      }

      // Relevanz: Name beginnt mit Query → enthält Query → Rest
      final lower = q.toLowerCase();
      items.sort((a, b) {
        final an = a.name.toLowerCase();
        final bn = b.name.toLowerCase();
        final aStarts = an.startsWith(lower) ? 0 : (an.contains(lower) ? 1 : 2);
        final bStarts = bn.startsWith(lower) ? 0 : (bn.contains(lower) ? 1 : 2);
        if (aStarts != bStarts) return aStarts.compareTo(bStarts);
        return an.compareTo(bn);
      });

      return items.take(20).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<FoodItem>> _search(
    String q, {
    OpenFoodFactsCountry? country,
  }) async {
    final configuration = ProductSearchQueryConfiguration(
      parametersList: [
        SearchTerms(terms: [q]),
        PageSize(size: 30),
      ],
      language: OpenFoodFactsLanguage.GERMAN,
      country: country,
      fields: [
        ProductField.BARCODE,
        ProductField.NAME,
        ProductField.NAME_IN_LANGUAGES,
        ProductField.NUTRIMENTS,
      ],
      version: ProductQueryVersion.v3,
    );

    final result = await OpenFoodAPIClient.searchProducts(
      null,
      configuration,
    );

    if (result.products == null || result.products!.isEmpty) {
      return [];
    }

    final mapped = <FoodItem>[];
    for (final p in result.products!) {
      final item = _mapProduct(p);
      if (item != null) mapped.add(item);
    }
    return mapped;
  }

  FoodItem? _mapProduct(Product p) {
    final nut = p.nutriments;
    if (nut == null) return null;

    // kcal oder aus kJ umrechnen
    double? kcal =
        nut.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams);
    if (kcal == null || kcal <= 0) {
      final kj = nut.getValue(Nutrient.energyKJ, PerSize.oneHundredGrams);
      if (kj != null && kj > 0) {
        kcal = kj / 4.184;
      }
    }
    if (kcal == null || kcal <= 0) return null;

    final name = p.productNameInLanguages?[OpenFoodFactsLanguage.GERMAN] ??
        p.productNameInLanguages?[OpenFoodFactsLanguage.ENGLISH] ??
        p.productName;
    if (name == null || name.trim().isEmpty) return null;

    return FoodItem(
      id: p.barcode ?? 'off_${name.hashCode}',
      name: name.trim(),
      kcal: kcal,
      protein: nut.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ?? 0,
      carbs:
          nut.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ?? 0,
      fat: nut.getValue(Nutrient.fat, PerSize.oneHundredGrams) ?? 0,
      fiber: nut.getValue(Nutrient.fiber, PerSize.oneHundredGrams) ?? 0,
      defaultPortion: 100,
    );
  }

  Future<FoodItem?> getProductByBarcode(String barcode) async {
    try {
      final configuration = ProductQueryConfiguration(
        barcode,
        language: OpenFoodFactsLanguage.GERMAN,
        fields: [
          ProductField.BARCODE,
          ProductField.NAME,
          ProductField.NAME_IN_LANGUAGES,
          ProductField.NUTRIMENTS,
        ],
        version: ProductQueryVersion.v3,
      );

      final result = await OpenFoodAPIClient.getProductV3(configuration);
      if (result.status != ProductResultV3.statusSuccess ||
          result.product == null) {
        return null;
      }
      return _mapProduct(result.product!);
    } catch (_) {
      return null;
    }
  }
}