import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../utils/formatters.dart';
import '../home/main_nav_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressCtrl = TextEditingController();
  String _payment = 'cod';
  bool _loading = false;
  String? _error;

  final _paymentOptions = const [
    {'id': 'cod', 'label': 'Bayar di Tempat (COD)', 'icon': Icons.local_shipping_outlined},
    {'id': 'transfer', 'label': 'Transfer Bank', 'icon': Icons.account_balance_outlined},
    {'id': 'ewallet', 'label': 'E-Wallet', 'icon': Icons.account_balance_wallet_outlined},
  ];

  Future<void> _placeOrder() async {
    if (_addressCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Alamat pengiriman wajib diisi');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<CartProvider>().checkout(address: _addressCtrl.text.trim(), paymentMethod: _payment);
      if (!mounted) return;
      Fluttertoast.showToast(msg: 'Pesanan berhasil dibuat 🎉');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavScreen()), (route) => false,
      );
    } catch (e) {
      setState(() => _error = 'Gagal membuat pesanan: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.brand.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(_error!, style: const TextStyle(color: AppColors.brandDark, fontSize: 13)),
                ),
              const Text('Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 10),
              TextField(
                controller: _addressCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Nama jalan, nomor rumah, kota, kode pos...'),
              ),
              const SizedBox(height: 24),
              const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 10),
              ..._paymentOptions.map((opt) {
                final selected = _payment == opt['id'];
                return GestureDetector(
                  onTap: () => setState(() => _payment = opt['id'] as String),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.brand.withValues(alpha: 0.08) : Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: selected ? AppColors.brand : AppColors.plumLight.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        Icon(opt['icon'] as IconData, size: 20, color: selected ? AppColors.brand : AppColors.plumLight),
                        const SizedBox(width: 12),
                        Text(opt['label'] as String, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: selected ? AppColors.brand : null)),
                        const Spacer(),
                        Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, size: 18, color: selected ? AppColors.brand : AppColors.plumLight),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              const Text('Ringkasan Pesanan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    ...cart.lines.map((l) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(child: Text('${l.product.name} x${l.quantity}', style: const TextStyle(fontSize: 13))),
                              Text(formatRupiah(l.subtotal), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )),
                    const Divider(height: 18),
                    Row(
                      children: [
                        const Expanded(child: Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
                        Text(formatRupiah(cart.total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.brand)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _placeOrder,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Text('Buat Pesanan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
