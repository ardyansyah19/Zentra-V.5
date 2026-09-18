import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final cart = context.read<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorit')),
      body: favorites.favoriteProducts.isEmpty
          ? const Center(child: Text('Belum ada produk favorit', style: TextStyle(color: AppColors.plumLight)))
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.66,
              ),
              itemCount: favorites.favoriteProducts.length,
              itemBuilder: (context, i) {
                final p = favorites.favoriteProducts[i];
                return ProductCard(
                  product: p,
                  isFavorite: true,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: p.id))),
                  onToggleFavorite: () => favorites.toggle(p),
                  onAddToCart: () => cart.add(p),
                );
              },
            ),
    );
  }
}
