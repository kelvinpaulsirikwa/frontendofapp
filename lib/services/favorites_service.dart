import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:bnbfrontendflutter/models/bnbmodel.dart';

class FavoritesService {
  FavoritesService._();

  static const String _boxName = 'favorite_motels';

  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<dynamic>(_boxName);
    }
  }

  static Box<dynamic> _box() => Hive.box<dynamic>(_boxName);

  static ValueListenable<Box<dynamic>> listenable() => _box().listenable();

  static List<SimpleMotel> getFavorites() {
    return _box().values
        .map((raw) {
          if (raw is Map) {
            return SimpleMotel.fromJson(Map<String, dynamic>.from(raw));
          }
          return null;
        })
        .whereType<SimpleMotel>()
        .toList();
  }

  static bool isFavorite(int motelId) => _box().containsKey(motelId);

  static Future<bool> toggleFavorite(SimpleMotel motel) async {
    final box = _box();
    final key = motel.id;

    if (box.containsKey(key)) {
      await box.delete(key);
      return false;
    } else {
      await box.put(key, motel.toJson());
      return true;
    }
  }

  static Future<void> clearFavorites() async {
    await _box().clear();
  }
}
