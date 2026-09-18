import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../utils/formatters.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: Text('Keranjang (${cart.itemCount})')),
      body: cart.lines.isEmpty
          ? _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    itemCount: cart.lines.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final line = cart.lines[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: line.product.image, width: 68, height: 68, fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(line.product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                  if (line.variant != null) ...[
                                    const SizedBox(height: 2),
                                    Text('Ukuran: ${line.variant}', style: const TextStyle(fontSize: 12, color: AppColors.plumLight)),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(formatRupiah(line.product.displayPrice),
                                      style: const TextStyle(color: AppColors.brand, fontWeight: FontWeight.w800, fontSize: 15)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => cart.remove(line.product, line.variant),
                                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.plumLight),
                                ),
                                const SizedBox(height: 8),
                                _QtyStepper(
                                  quantity: line.quantity,
                                  onChanged: (q) => cart.updateQuantity(line.product, line.variant, q),
                                  max: line.product.stock,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                _CartSummary(cart: cart),
              ],
            ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int quantity;
  final int max;
  final ValueChanged<int> onChanged;
  const _QtyStepper({required this.quantity, required this.onChanged, required this.max});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.plumLight.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove_rounded, () => onChanged(quantity - 1)),
          SizedBox(width: 24, child: Text('$quantity', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
          _btn(Icons.add_rounded, quantity < max ? () => onChanged(quantity + 1) : null),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback? onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 15, color: onTap == null ? AppColors.plumLight.withValues(alpha: 0.4) : AppColors.plum)),
      );
}

class _CartSummary extends StatelessWidget {
  final CartProvider cart;
  const _CartSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _row('Subtotal', formatRupiah(cart.subtotal)),
            const SizedBox(height: 6),
            _row('Ongkos Kirim', formatRupiah(cart.shippingFee)),
            const Divider(height: 22),
            _row('Total', formatRupiah(cart.total), bold: true),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                child: const Text('Checkout Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: bold ? null : AppColors.plumLight, fontSize: bold ? 15 : 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: bold ? 18 : 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: bold ? AppColors.brand : null)),
        ],
      );
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.plumLight.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('Keranjangmu masih kosong', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          const Text('Yuk mulai belanja produk favoritmu', style: TextStyle(color: AppColors.plumLight, fontSize: 13)),
        ],
      ),
    );
  }
}
