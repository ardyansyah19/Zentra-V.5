import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};
  List<Product> _favoriteProducts = [];

  Set<String> get favoriteIds => _favoriteIds;
  List<Product> get favoriteProducts => _favoriteProducts;

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  Future<void> load() async {
    try {
      final data = await ApiService.get('/favorites');
      _favoriteProducts = (data as List).map((e) => Product.fromJson(e)).toList();
      _favoriteIds
        ..clear()
        ..addAll(_favoriteProducts.map((p) => p.id));
      notifyListeners();
    } catch (_) {
      // Belum login atau gagal memuat — abaikan secara halus
    }
  }

  Future<void> toggle(Product product) async {
    if (_favoriteIds.contains(product.id)) {
      _favoriteIds.remove(product.id);
      _favoriteProducts.removeWhere((p) => p.id == product.id);
      notifyListeners();
      await ApiService.delete('/favorites/${product.id}');
    } else {
      _favoriteIds.add(product.id);
      _favoriteProducts.add(product);
      notifyListeners();
      await ApiService.post('/favorites/${product.id}', {});
    }
  }
}
