import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'home_screen.dart';
import '../product/products_screen.dart';
import '../cart/cart_screen.dart';
import '../account/account_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    ProductsScreen(),
    CartScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          const BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Produk'),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              backgroundColor: const Color(0xFFFF6A3D),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            label: 'Keranjang',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Akun'),
        ],
      ),
    );
  }
}
