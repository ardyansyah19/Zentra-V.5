import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/product_card_skeleton.dart';
import '../product/product_detail_screen.dart';
import '../product/products_screen.dart';
import '../account/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _syncMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final productProvider = context.read<ProductProvider>();
      await productProvider.load();
      await context.read<FavoritesProvider>().load();
      productProvider.addListener(_onProductsChanged);
    });
  }

  void _onProductsChanged() {
    final msg = context.read<ProductProvider>().lastSyncMessage;
    if (msg != null && mounted) {
      setState(() => _syncMessage = msg);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _syncMessage = null);
      });
    }
  }

  @override
  void dispose() {
    context.read<ProductProvider>().removeListener(_onProductsChanged);
    super.dispose();
  }

  void _openDetail(Product p) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: p.id)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final cart = context.read<CartProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.brand,
          onRefresh: productProvider.load,
          child: productProvider.loading && productProvider.products.isEmpty
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: ProductGridSkeleton(count: 6),
                    ),
                  ],
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.brand.withValues(alpha: 0.1),
                              backgroundImage: (auth.user?.avatar != null && auth.user!.avatar!.isNotEmpty)
                                  ? NetworkImage(auth.user!.avatar!)
                                  : null,
                              child: (auth.user?.avatar == null || auth.user!.avatar!.isEmpty)
                                  ? Text(
                                      auth.user?.name.isNotEmpty == true ? auth.user!.name.substring(0, 1).toUpperCase() : '?',
                                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.brand),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Selamat datang 👋', style: TextStyle(fontSize: 12, color: AppColors.plumLight)),
                                  Text(auth.user?.name ?? 'Pengguna', style: Theme.of(context).textTheme.titleMedium),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                                child: const Icon(Icons.notifications_none_rounded, color: AppColors.brand, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_syncMessage != null)
                      SliverToBoxAdapter(child: SyncBanner(message: _syncMessage!)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductsScreen())),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.plumLight.withValues(alpha: 0.15)),
                            ),
                            child: const Row(children: [
                              Icon(Icons.search_rounded, color: AppColors.plumLight, size: 20),
                              SizedBox(width: 10),
                              Text('Cari produk favoritmu...', style: TextStyle(color: AppColors.plumLight, fontSize: 13.5)),
                            ]),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: _SaleBanner(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 0, 0),
                        child: SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ...productProvider.categories.map((c) => Padding(
                                    padding: const EdgeInsets.only(right: 0),
                                    child: CategoryChip(
                                      label: c.name, selected: false,
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => ProductsScreen(initialCategory: c.name)),
                                      ),
                                    ),
                                  )),
                              const SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (productProvider.featured.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionHeader(
                                title: 'Produk Unggulan',
                                onSeeAll: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductsScreen())),
                              ),
                              SizedBox(
                                height: 235,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: productProvider.featured.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                                  itemBuilder: (_, i) {
                                    final p = productProvider.featured[i];
                                    return SizedBox(
                                      width: 150,
                                      child: ProductCard(
                                        product: p,
                                        isFavorite: favorites.isFavorite(p.id),
                                        onTap: () => _openDetail(p),
                                        onToggleFavorite: () => favorites.toggle(p),
                                        onAddToCart: () => cart.add(p),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
                      sliver: SliverToBoxAdapter(
                        child: SectionHeader(
                          title: 'Paling Populer',
                          onSeeAll: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductsScreen())),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.66,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final list = productProvider.popular.isNotEmpty ? productProvider.popular : productProvider.products;
                            final p = list[i];
                            return ProductCard(
                              product: p,
                              isFavorite: favorites.isFavorite(p.id),
                              onTap: () => _openDetail(p),
                              onToggleFavorite: () => favorites.toggle(p),
                              onAddToCart: () => cart.add(p),
                            );
                          },
                          childCount: (productProvider.popular.isNotEmpty ? productProvider.popular : productProvider.products).length,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SaleBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.brand, Color(0xFFFF8A5C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('DISKON AKHIR TAHUN', style: TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                const Text('Diskon hingga 40%', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: const Text('Belanja Sekarang', style: TextStyle(color: AppColors.brand, fontSize: 11.5, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const Icon(Icons.shopping_bag_rounded, size: 62, color: Colors.white24),
        ],
      ),
    );
  }
}
