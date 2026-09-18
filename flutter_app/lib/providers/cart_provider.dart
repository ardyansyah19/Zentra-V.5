import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class LocalCartLine {
  final Product product;
  int quantity;
  String? variant;
  LocalCartLine({required this.product, this.quantity = 1, this.variant});
  double get subtotal => product.displayPrice * quantity;
}

/// Keranjang dikelola secara lokal di memori untuk pengalaman instan,
/// lalu dikirim ke server sekaligus saat checkout — server yang akan
/// memvalidasi ulang stok terkini sebelum membuat pesanan.
class CartProvider extends ChangeNotifier {
  final List<LocalCartLine> _lines = [];

  List<LocalCartLine> get lines => _lines;
  int get itemCount => _lines.fold(0, (sum, l) => sum + l.quantity);
  double get subtotal => _lines.fold(0, (sum, l) => sum + l.subtotal);
  double get shippingFee => _lines.isEmpty ? 0 : 15000;
  double get total => subtotal + shippingFee;

  void add(Product product, {String? variant, int quantity = 1}) {
    final idx = _lines.indexWhere((l) => l.product.id == product.id && l.variant == variant);
    if (idx != -1) {
      _lines[idx].quantity += quantity;
    } else {
      _lines.add(LocalCartLine(product: product, quantity: quantity, variant: variant));
    }
    notifyListeners();
  }

  void updateQuantity(Product product, String? variant, int quantity) {
    final idx = _lines.indexWhere((l) => l.product.id == product.id && l.variant == variant);
    if (idx == -1) return;
    if (quantity <= 0) {
      _lines.removeAt(idx);
    } else {
      _lines[idx].quantity = quantity;
    }
    notifyListeners();
  }

  void remove(Product product, String? variant) {
    _lines.removeWhere((l) => l.product.id == product.id && l.variant == variant);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }

  bool isFavoriteQuantityValid() => _lines.every((l) => l.quantity <= l.product.stock);

  Future<Map<String, dynamic>> checkout({required String address, required String paymentMethod}) async {
    final items = _lines.map((l) => {'product_id': l.product.id, 'quantity': l.quantity}).toList();
    final data = await ApiService.post('/orders', {
      'items': items,
      'address': address,
      'payment_method': paymentMethod,
      'shipping_fee': shippingFee,
    });
    clear();
    return Map<String, dynamic>.from(data);
  }
}
