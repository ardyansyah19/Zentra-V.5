import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/formatters.dart';

class _Review {
  final String userName;
  final int rating;
  final String comment;
  _Review({required this.userName, required this.rating, required this.comment});
  factory _Review.fromJson(Map<String, dynamic> json) => _Review(
        userName: json['user_name'] ?? 'Pengguna',
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        comment: json['comment'] ?? '',
      );
}

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = 'M';
  final _sizes = const ['S', 'M', 'L', 'XL', 'XXL'];
  List<_Review> _reviews = [];
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _loadingReviews = true);
    try {
      final data = await ApiService.get('/products/${widget.productId}');
      final list = (data['reviews'] as List? ?? []).map((e) => _Review.fromJson(e)).toList();
      if (mounted) setState(() => _reviews = list);
    } catch (_) {
      // abaikan secara halus
    } finally {
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  void _openReviewDialog() {
    int rating = 5;
    final commentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => AlertDialog(
          title: const Text('Tulis Ulasan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    onPressed: () => setSheetState(() => rating = i + 1),
                    icon: Icon(
                      i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: AppColors.amber, size: 28,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Bagaimana pendapatmu tentang produk ini?'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await ApiService.post('/products/${widget.productId}/reviews', {
                    'rating': rating,
                    'comment': commentCtrl.text.trim(),
                  });
                  Fluttertoast.showToast(msg: 'Terima kasih atas ulasanmu!');
                  _loadReviews();
                } catch (_) {
                  Fluttertoast.showToast(msg: 'Gagal mengirim ulasan');
                }
              },
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final product = productProvider.byId(widget.productId);
    final favorites = context.watch<FavoritesProvider>();
    final cart = context.read<CartProvider>();

    if (product == null) {
      return const Scaffold(body: Center(child: Text('Produk tidak ditemukan')));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _roundIconButton(Icons.arrow_back_ios_new_rounded, () => Navigator.of(context).pop()),
                  const Text('Detail Produk', style: TextStyle(fontWeight: FontWeight.w700)),
                  _roundIconButton(Icons.home_outlined, () => Navigator.of(context).popUntil((r) => r.isFirst)),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.brand,
                onRefresh: _loadReviews,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: CachedNetworkImage(imageUrl: product.image, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(product.name, style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 21))),
                                IconButton(
                                  onPressed: () => favorites.toggle(product),
                                  icon: Icon(
                                    favorites.isFavorite(product.id) ? Icons.favorite : Icons.favorite_border,
                                    color: favorites.isFavorite(product.id) ? AppColors.brand : AppColors.plumLight,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                RatingStars(rating: product.rating, size: 16),
                                const SizedBox(width: 8),
                                Text('(${product.reviewCount})', style: const TextStyle(color: AppColors.plumLight, fontSize: 12.5)),
                                const Spacer(),
                                Text(
                                  product.inStock ? '${product.stock} stok tersedia' : 'Stok habis',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: product.isLowStock ? AppColors.amber : (product.inStock ? AppColors.mint : AppColors.brand),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const Text('Pilih Ukuran', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            const SizedBox(height: 10),
                            Row(
                              children: _sizes.map((s) {
                                final selected = s == _selectedSize;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedSize = s),
                                  child: Container(
                                    width: 40, height: 40,
                                    margin: const EdgeInsets.only(right: 10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: selected ? AppColors.brand : AppColors.plumLight.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(s, style: TextStyle(color: selected ? Colors.white : AppColors.plum, fontWeight: FontWeight.w700, fontSize: 12.5)),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                            const SizedBox(height: 8),
                            Text(product.description, style: const TextStyle(color: AppColors.plumLight, fontSize: 13.5, height: 1.5)),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Ulasan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                GestureDetector(
                                  onTap: _openReviewDialog,
                                  child: const Text('Tulis Ulasan', style: TextStyle(color: AppColors.brand, fontWeight: FontWeight.w700, fontSize: 12.5)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (_loadingReviews)
                              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: CircularProgressIndicator(color: AppColors.brand, strokeWidth: 2.5)))
                            else if (_reviews.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('Belum ada ulasan. Jadilah yang pertama!', style: TextStyle(color: AppColors.plumLight, fontSize: 12.5)),
                              )
                            else
                              ..._reviews.map((r) => Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(r.userName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                            const SizedBox(width: 8),
                                            RatingStars(rating: r.rating.toDouble(), size: 12),
                                          ],
                                        ),
                                        if (r.comment.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(r.comment, style: const TextStyle(fontSize: 12.5, color: AppColors.plumLight, height: 1.4)),
                                        ],
                                      ],
                                    ),
                                  )),
                            const SizedBox(height: 90),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.hasDiscount)
                    Text(formatRupiah(product.price),
                        style: const TextStyle(color: AppColors.plumLight, fontSize: 12.5, decoration: TextDecoration.lineThrough)),
                  Text(formatRupiah(product.displayPrice),
                      style: const TextStyle(color: AppColors.brand, fontSize: 20, fontWeight: FontWeight.w800)),
                ],
              ),
              const Spacer(),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: product.inStock
                      ? () {
                          cart.add(product, variant: _selectedSize);
                          Fluttertoast.showToast(msg: '${product.name} ditambahkan ke keranjang');
                        }
                      : null,
                  child: const Text('Tambah ke Keranjang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roundIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.plumLight.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
