import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:openfoodfacts/openfoodfacts.dart';
import '../models/food_item.dart';

class OpenFoodFactsService {
  static const _userAgent = 'CalorieWallet/1.0 (Flutter; personal use)';

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

    // 1. Direkte HTTP-Suche (zuverlässiger)
    var items = await _httpSearch(q, country: 'de');
    if (items.length < 5) {
      final world = await _httpSearch(q, country: null);
      final seen = items.map((e) => e.id).toSet();
      for (final w in world) {
        if (seen.add(w.id)) items.add(w);
      }
    }

    // 2. Fallback: Package-API
    if (items.isEmpty) {
      items = await _packageSearch(q);
    }

    final lower = q.toLowerCase();
    items.sort((a, b) {
      final an = a.name.toLowerCase();
      final bn = b.name.toLowerCase();
      int score(String n) {
        if (n == lower) return 0;
        if (n.startsWith(lower)) return 1;
        if (n.contains(lower)) return 2;
        return 3;
      }
      final c = score(an).compareTo(score(bn));
      if (c != 0) return c;
      return an.compareTo(bn);
    });

    return items.take(25).toList();
  }

  Future<List<FoodItem>> _httpSearch(String q, {String? country}) async {
    try {
      final params = <String, String>{
        'search_terms': q,
        'search_simple': '1',
        'action': 'process',
        'json': '1',
        'page_size': '30',
        'lc': 'de',
        'fields':
            'code,product_name,product_name_de,product_name_en,nutriments',
      };
      if (country != null) params['cc'] = country;

      final uri = Uri.https(
        'world.openfoodfacts.org',
        '/cgi/search.pl',
        params,
      );

      final response = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final products = data['products'] as List<dynamic>? ?? [];
      final mapped = <FoodItem>[];

      for (final raw in products) {
        if (raw is! Map<String, dynamic>) continue;
        final item = _mapJson(raw);
        if (item != null) mapped.add(item);
      }
      return mapped;
    } catch (_) {
      return [];
    }
  }

  FoodItem? _mapJson(Map<String, dynamic> p) {
    final nut = p['nutriments'];
    if (nut is! Map) return null;

    double? kcal = _toDouble(nut['energy-kcal_100g']) ??
        _toDouble(nut['energy-kcal']) ??
        _toDouble(nut['energy-kcal_value']);

    if (kcal == null || kcal <= 0) {
      final kj = _toDouble(nut['energy-kj_100g']) ??
          _toDouble(nut['energy_100g']) ??
          _toDouble(nut['energy']);
      if (kj != null && kj > 0) kcal = kj / 4.184;
    }
    if (kcal == null || kcal <= 0) return null;

    final name = (p['product_name_de'] as String?)?.trim().isNotEmpty == true
        ? (p['product_name_de'] as String).trim()
        : (p['product_name'] as String?)?.trim().isNotEmpty == true
            ? (p['product_name'] as String).trim()
            : (p['product_name_en'] as String?)?.trim();

    if (name == null || name.isEmpty) return null;

    final code = p['code']?.toString() ?? 'off_${name.hashCode}';

    return FoodItem(
      id: code,
      name: name,
      kcal: kcal,
      protein: _toDouble(nut['proteins_100g']) ?? 0,
      carbs: _toDouble(nut['carbohydrates_100g']) ?? 0,
      fat: _toDouble(nut['fat_100g']) ?? 0,
      fiber: _toDouble(nut['fiber_100g']) ?? 0,
      defaultPortion: 100,
    );
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().replaceAll(',', '.'));
  }

  Future<List<FoodItem>> _packageSearch(String q) async {
    try {
      final configuration = ProductSearchQueryConfiguration(
        parametersList: [
          SearchTerms(terms: [q]),
          PageSize(size: 25),
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
      if (result.products == null) return [];

      final list = <FoodItem>[];
      for (final p in result.products!) {
        final item = _mapProduct(p);
        if (item != null) list.add(item);
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  FoodItem? _mapProduct(Product p) {
    final nut = p.nutriments;
    if (nut == null) return null;

    double? kcal =
        nut.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams);
    if (kcal == null || kcal <= 0) {
      final kj = nut.getValue(Nutrient.energyKJ, PerSize.oneHundredGrams);
      if (kj != null && kj > 0) kcal = kj / 4.184;
    }
    if (kcal == null || kcal <= 0) return null;

    final name = p.productNameInLanguages?[OpenFoodFactsLanguage.GERMAN] ??
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
    // HTTP v2 API
    try {
      final uri = Uri.https(
        'world.openfoodfacts.org',
        '/api/v2/product/$barcode.json',
        {'fields': 'code,product_name,product_name_de,nutriments'},
      );
      final response = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 1 && data['product'] is Map<String, dynamic>) {
          final item = _mapJson(data['product'] as Map<String, dynamic>);
          if (item != null) return item;
        }
      }
    } catch (_) {}

    // Package-Fallback
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
      if (result.status == ProductResultV3.statusSuccess &&
          result.product != null) {
        return _mapProduct(result.product!);
      }
    } catch (_) {}
    return null;
  }
}