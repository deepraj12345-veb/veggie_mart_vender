import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'consts/app_theme.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: VeggieMartVendorApp(),
    ),
  );
}

class VeggieMartVendorApp extends StatelessWidget {
  const VeggieMartVendorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veggie Mart Vendor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
