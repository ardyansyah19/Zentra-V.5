import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/theme.dart';

/// Skeleton loader ala shimmer untuk kartu produk — dipakai saat data
/// produk sedang dimuat pertama kali, menggantikan spinner polos agar
/// terasa lebih premium dan modern (mengikuti pola loading skeleton
/// yang umum dipakai aplikasi e-commerce).
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.navy700 : Colors.white;
    final highlight = isDark ? AppColors.navy800 : const Color(0xFFF3F0EC);

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.navy800 : const Color(0xFFEDEAE5),
      highlightColor: highlight,
      child: Container(
        decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(18)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 90, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 50, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 14, width: 70, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid berisi beberapa [ProductCardSkeleton], dipakai saat produk
/// sedang dimuat agar tata letak tidak "melompat" ketika data datang.
class ProductGridSkeleton extends StatelessWidget {
  final int count;
  const ProductGridSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.66,
      ),
      itemCount: count,
      itemBuilder: (_, __) => const ProductCardSkeleton(),
    );
  }
}
