import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/cart_item.dart';
import '../../services/api_service.dart';
import '../../services/socket_service.dart';
import '../../utils/formatters.dart';

const _statusLabel = {
  'pending': 'Menunggu', 'processing': 'Diproses', 'shipped': 'Dikirim',
  'delivered': 'Selesai', 'cancelled': 'Dibatalkan',
};
const _statusColor = {
  'pending': AppColors.amber, 'processing': AppColors.mint, 'shipped': AppColors.brand,
  'delivered': AppColors.mint, 'cancelled': AppColors.plumLight,
};

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    // Dengarkan perubahan status pesanan secara realtime — saat admin
    // memperbarui status di dashboard, daftar di sini langsung ter-refresh.
    SocketService().socket.on('order:updated', _onOrderUpdated);
  }

  @override
  void dispose() {
    SocketService().socket.off('order:updated', _onOrderUpdated);
    super.dispose();
  }

  void _onOrderUpdated(dynamic _) {
    if (mounted) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.get('/orders');
      _orders = (data as List).map((e) => Order.fromJson(e)).toList();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: RefreshIndicator(
        color: AppColors.brand,
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.brand))
            : _orders.isEmpty
                ? ListView(children: const [
                    SizedBox(height: 120),
                    Center(child: Text('Belum ada pesanan', style: TextStyle(color: AppColors.plumLight))),
                  ])
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final o = _orders[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('#${o.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: (_statusColor[o.status] ?? AppColors.plumLight).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                                  child: Text(_statusLabel[o.status] ?? o.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor[o.status] ?? AppColors.plumLight)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('${o.items.length} produk • ${formatRupiah(o.total)}', style: const TextStyle(fontSize: 13, color: AppColors.plumLight)),
                            const SizedBox(height: 4),
                            Text('${o.createdAt.day}/${o.createdAt.month}/${o.createdAt.year}', style: const TextStyle(fontSize: 11.5, color: AppColors.plumLight)),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
