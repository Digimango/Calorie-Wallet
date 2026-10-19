import '../data/offline_foods.dart';
import '../models/food_item.dart';
import 'storage_service.dart';

class LocalFoodService {
  final StorageService _storage;
  List<FoodItem> _custom = [];

  LocalFoodService(this._storage);

  Future<void> init() async {
    _custom = await _storage.loadCustomFoods();
  }

  List<FoodItem> get all {
    final map = <String, FoodItem>{};
    for (final f in kOfflineFoods) {
      map[f.id] = f;
    }
    for (final f in _custom) {
      map[f.id] = f; // Custom überschreibt Seed bei gleicher ID
    }
    return map.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  List<FoodItem> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.length < 1) return [];
    final list = all.where((f) => f.name.toLowerCase().contains(q)).toList();
    list.sort((a, b) {
      final an = a.name.toLowerCase();
      final bn = b.name.toLowerCase();
      final aStarts = an.startsWith(q) ? 0 : 1;
      final bStarts = bn.startsWith(q) ? 0 : 1;
      if (aStarts != bStarts) return aStarts.compareTo(bStarts);
      return an.compareTo(bn);
    });
    return list.take(30).toList();
  }

  FoodItem? byBarcode(String barcode) {
    final code = barcode.trim();
    for (final f in all) {
      if (f.barcode == code) return f;
    }
    return null;
  }

  FoodItem? byId(String id) {
    try {
      return all.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCustom(FoodItem item) async {
    _custom.removeWhere((f) => f.id == item.id);
    _custom.add(item);
    await _storage.saveCustomFoods(_custom);
  }

  Future<void> deleteCustom(String id) async {
    _custom.removeWhere((f) => f.id == id);
    await _storage.saveCustomFoods(_custom);
  }
}
