import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'consts/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: VegKingVendorApp(),
    ),
  );
}

class VegKingVendorApp extends StatelessWidget {
  const VegKingVendorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veg King Vendor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) => ExcludeSemantics(child: child!),
      home: const SplashScreen(),
    );
  }
}
