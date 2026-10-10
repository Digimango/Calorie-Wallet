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
    ];
    OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.GERMANY;
  }

  Future<List<FoodItem>> searchProducts(String query) async {
    final q = query.trim();
    if (q.length < 2) return [];

    try {
      final configuration = ProductSearchQueryConfiguration(
        parametersList: [
          SearchTerms(terms: [q]),
          PageSize(size: 20),
        ],
        language: OpenFoodFactsLanguage.GERMAN,
        country: OpenFoodFactsCountry.GERMANY,
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
        final nut = p.nutriments;
        if (nut == null) continue;

        final kcal =
            nut.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ?? 0;
        if (kcal <= 0) continue;

        final name =
            p.productNameInLanguages?[OpenFoodFactsLanguage.GERMAN] ??
                p.productName;
        if (name == null || name.isEmpty) continue;

        mapped.add(FoodItem(
          id: p.barcode ?? 'off_${name.hashCode}',
          name: name,
          kcal: kcal,
          protein:
              nut.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ?? 0,
          carbs: nut.getValue(
                  Nutrient.carbohydrates, PerSize.oneHundredGrams) ??
              0,
          fat: nut.getValue(Nutrient.fat, PerSize.oneHundredGrams) ?? 0,
          fiber: nut.getValue(Nutrient.fiber, PerSize.oneHundredGrams) ?? 0,
          defaultPortion: 100,
        ));
      }
      return mapped;
    } catch (e) {
      // Kein Mock mehr – leere Liste, damit man den Fehler sieht
      return [];
    }
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

      final p = result.product!;
      final nut = p.nutriments;
      if (nut == null) return null;

      final kcal =
          nut.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ?? 0;
      if (kcal <= 0) return null;

      return FoodItem(
        id: p.barcode ?? barcode,
        name: p.productNameInLanguages?[OpenFoodFactsLanguage.GERMAN] ??
            p.productName ??
            'Unbekanntes Produkt',
        kcal: kcal,
        protein: nut.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ?? 0,
        carbs:
            nut.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ?? 0,
        fat: nut.getValue(Nutrient.fat, PerSize.oneHundredGrams) ?? 0,
        fiber: nut.getValue(Nutrient.fiber, PerSize.oneHundredGrams) ?? 0,
        defaultPortion: 100,
      );
    } catch (_) {
      return null;
    }
  }
}