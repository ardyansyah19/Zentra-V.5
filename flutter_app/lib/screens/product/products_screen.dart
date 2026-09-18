import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/product_card_skeleton.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String? initialCategory;
  const ProductsScreen({super.key, this.initialCategory});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _selectedCategory = 'Semua';
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'Semua';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductProvider>();
      if (p.products.isEmpty) p.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final cart = context.read<CartProvider>();

    var list = productProvider.byCategory(_selectedCategory == 'Semua' ? null : _selectedCategory);
    if (_query.isNotEmpty) {
      list = list.where((p) => p.name.toLowerCase().contains(_query.toLowerCase())).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Produk')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: Icon(Icons.search_rounded, size: 20),
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                CategoryChip(label: 'Semua', selected: _selectedCategory == 'Semua', onTap: () => setState(() => _selectedCategory = 'Semua')),
                ...productProvider.categories.map((c) => CategoryChip(
                      label: c.name,
                      selected: _selectedCategory == c.name,
                      onTap: () => setState(() => _selectedCategory = c.name),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: productProvider.loading && productProvider.products.isEmpty
                ? const ProductGridSkeleton(count: 6)
                : list.isEmpty
                ? const Center(child: Text('Tidak ada produk ditemukan', style: TextStyle(color: AppColors.plumLight)))
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.66,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final p = list[i];
                      return ProductCard(
                        product: p,
                        isFavorite: favorites.isFavorite(p.id),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: p.id))),
                        onToggleFavorite: () => favorites.toggle(p),
                        onAddToCart: () => cart.add(p),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
