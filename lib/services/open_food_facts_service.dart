import 'package:openfoodfacts/openfoodfacts.dart';
import '../models/food_item.dart';

class OpenFoodFactsService {
  OpenFoodFactsService() {
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'CalorieWallet',
      version: '1.0.0',
      system: 'Flutter',
      url: 'https://github.com/calorie-wallet',
      comment: 'Personal calorie budget app – no commercial use',
    );
    OpenFoodAPIConfiguration.globalLanguages = [OpenFoodFactsLanguage.GERMAN];
    OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.GERMANY;
  }

  /// Suche nach Produkten (Text)
  Future<List<FoodItem>> searchProducts(String query) async {
    if (query.trim().length < 2) return mockFoods;

    try {
      final configuration = ProductSearchQueryConfiguration(
        parametersList: [
          SearchTerms(terms: [query]),
          PageSize(size: 12),
        ],
        language: OpenFoodFactsLanguage.GERMAN,
        fields: [
          ProductField.BARCODE,
          ProductField.NAME,
          ProductField.NAME_IN_LANGUAGES,
          ProductField.NUTRIMENTS,
          ProductField.QUANTITY,
        ],
        version: ProductQueryVersion.v3,
      );

      final result = await OpenFoodAPIClient.searchProducts(
        null, // anonymous
        configuration,
      );

      if (result.products == null || result.products!.isEmpty) {
        return _filterMock(query);
      }

      final mapped = result.products!
          .where((p) => p.productName != null && p.nutriments != null)
          .map((p) {
            final nut = p.nutriments!;
            final kcal = nut.getValue(Nutrient.energyKCal, per: PerSize.oneHundredGrams) ?? 0;
            return FoodItem(
              id: p.barcode ?? 'off_${DateTime.now().millisecondsSinceEpoch}',
              name: p.productNameInLanguages?[OpenFoodFactsLanguage.GERMAN] ??
                  p.productName ??
                  'Unbekanntes Produkt',
              kcal: kcal,
              protein: nut.getValue(Nutrient.proteins, per: PerSize.oneHundredGrams) ?? 0,
              carbs: nut.getValue(Nutrient.carbohydrates, per: PerSize.oneHundredGrams) ?? 0,
              fat: nut.getValue(Nutrient.fat, per: PerSize.oneHundredGrams) ?? 0,
              fiber: nut.getValue(Nutrient.fiber, per: PerSize.oneHundredGrams) ?? 0,
              defaultPortion: 100,
            );
          })
          .where((f) => f.kcal > 0)
          .toList();

      if (mapped.isEmpty) return _filterMock(query);
      return mapped;
    } catch (e) {
      // Offline / API-Fehler → Mock
      return _filterMock(query);
    }
  }

  /// Produkt per Barcode laden
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

      if (result.status != ProductResultV3.statusSuccess || result.product == null) {
        return null;
      }

      final p = result.product!;
      final nut = p.nutriments;
      if (nut == null) return null;

      final kcal = nut.getValue(Nutrient.energyKCal, per: PerSize.oneHundredGrams) ?? 0;
      if (kcal <= 0) return null;

      return FoodItem(
        id: p.barcode ?? barcode,
        name: p.productNameInLanguages?[OpenFoodFactsLanguage.GERMAN] ??
            p.productName ??
            'Unbekanntes Produkt',
        kcal: kcal,
        protein: nut.getValue(Nutrient.proteins, per: PerSize.oneHundredGrams) ?? 0,
        carbs: nut.getValue(Nutrient.carbohydrates, per: PerSize.oneHundredGrams) ?? 0,
        fat: nut.getValue(Nutrient.fat, per: PerSize.oneHundredGrams) ?? 0,
        fiber: nut.getValue(Nutrient.fiber, per: PerSize.oneHundredGrams) ?? 0,
        defaultPortion: 100,
      );
    } catch (_) {
      return null;
    }
  }

  List<FoodItem> _filterMock(String query) {
    final q = query.toLowerCase();
    return mockFoods.where((f) => f.name.toLowerCase().contains(q)).toList();
  }
}
