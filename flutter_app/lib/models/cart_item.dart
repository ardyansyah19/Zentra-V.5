import 'product.dart';

class CartItem {
  final String id; // id baris cart di server (kosong jika lokal)
  final Product product;
  int quantity;
  String? variant;

  CartItem({required this.id, required this.product, this.quantity = 1, this.variant});

  double get subtotal => product.displayPrice * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      product: Product.fromJson(json),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      variant: json['variant'] as String?,
    );
  }
}

class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String image;

  OrderItem({required this.productId, required this.name, required this.price, required this.quantity, required this.image});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      image: json['image'] ?? '',
    );
  }
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double subtotal;
  final double shippingFee;
  final double total;
  final String status;
  final String? address;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.status,
    this.address,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      items: (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      shippingFee: (json['shipping_fee'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num).toDouble(),
      status: json['status'] ?? 'pending',
      address: json['address'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
