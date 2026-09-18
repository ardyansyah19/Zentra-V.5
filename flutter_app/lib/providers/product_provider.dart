import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

/// Menyimpan daftar produk & kategori di memori aplikasi, dan
/// mendengarkan event realtime dari server. Saat admin mengubah harga
/// atau stok lewat dashboard, provider ini otomatis memperbarui data
/// tanpa perlu pull-to-refresh — inilah inti sinkronisasi Admin ⇄ App.
class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _loading = false;
  String? _lastSyncMessage;

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  bool get loading => _loading;
  String? get lastSyncMessage => _lastSyncMessage;

  List<Product> get featured => _products.where((p) => p.isFeatured).toList();
  List<Product> get popular => _products.where((p) => p.isPopular).toList();

  ProductProvider() {
    _listenRealtime();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        ApiService.get('/products'),
        ApiService.get('/products/categories/all'),
      ]);
      _products = (results[0] as List).map((e) => Product.fromJson(e)).toList();
      _categories = (results[1] as List).map((e) => Category.fromJson(e)).toList();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<Product> byCategory(String? categoryName) {
    if (categoryName == null || categoryName == 'Semua') return _products;
    return _products.where((p) => p.category == categoryName).toList();
  }

  List<Product> search(String query) {
    if (query.trim().isEmpty) return _products;
    final q = query.toLowerCase();
    return _products.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  Product? byId(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void _listenRealtime() {
    final socket = SocketService().socket;
    SocketService().connect();

    socket.on('product:created', (data) {
      final p = Product.fromJson(Map<String, dynamic>.from(data));
      _products = [p, ..._products];
      _lastSyncMessage = '${p.name} baru saja ditambahkan';
      notifyListeners();
    });

    socket.on('product:updated', (data) {
      final updated = Product.fromJson(Map<String, dynamic>.from(data));
      final idx = _products.indexWhere((p) => p.id == updated.id);
      if (idx != -1) {
        _products[idx] = updated;
        _lastSyncMessage = 'Stok/harga ${updated.name} diperbarui';
        notifyListeners();
      }
    });

    socket.on('product:deleted', (data) {
      final id = data is Map ? data['id'] : null;
      if (id != null) {
        _products.removeWhere((p) => p.id == id);
        notifyListeners();
      }
    });
  }
}
