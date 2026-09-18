import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = AppThemeProvider();
  await themeProvider.init();
  runApp(ZentraApp(themeProvider: themeProvider));
}

class ZentraApp extends StatelessWidget {
  final AppThemeProvider themeProvider;
  const ZentraApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: Consumer<AppThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Zentra Store',
            debugShowCheckedModeBanner: false,
            themeMode: theme.themeMode,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
