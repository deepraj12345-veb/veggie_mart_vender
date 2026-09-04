import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../consts/app_colors.dart';
import '../providers/localization_provider.dart';
import 'dashboard/orders_dashboard_screen.dart';
import 'inventory/inventory_screen.dart';
import 'wallet/wallet_screen.dart';
import 'profile/profile_screen.dart';

import '../models/order_model.dart';
import '../providers/orders_provider.dart';
import '../widgets/new_order_alert_modal.dart';

class MainNavScreen extends ConsumerStatefulWidget {
  const MainNavScreen({super.key});

  @override
  ConsumerState<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends ConsumerState<MainNavScreen> {
  int _currentIndex = 0;
  final Set<String> _alertedOrderIds = {};
  bool _isModalShowing = false;

  final List<Widget> _screens = const [
    OrdersDashboardScreen(),
    InventoryScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  void _checkAndShowNewOrderAlert(List<OrderModel> newOrders) {
    if (newOrders.isEmpty || _isModalShowing) return;

    final unalerted = newOrders.where((o) => !_alertedOrderIds.contains(o.id)).toList();
    if (unalerted.isEmpty) return;

    final targetOrder = unalerted.first;
    _alertedOrderIds.add(targetOrder.id);
    _isModalShowing = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      NewOrderAlertModal.show(
        context,
        order: targetOrder,
        onAccept: () async {
          _isModalShowing = false;
          await ref.read(ordersProvider.notifier).acceptOrder(targetOrder.id);
        },
        onReject: () async {
          _isModalShowing = false;
          await ref.read(ordersProvider.notifier).rejectOrder(targetOrder.id);
        },
      ).then((_) {
        _isModalShowing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationProvider);
    final newOrders = ref.watch(newOrdersProvider);

    // Trigger ringtone popup modal automatically for new incoming orders
    ref.listen<List<OrderModel>>(newOrdersProvider, (previous, next) {
      _checkAndShowNewOrderAlert(next);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowNewOrderAlert(newOrders);
    });

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.list_alt_outlined),
              activeIcon: const Icon(Icons.list_alt),
              label: tr("Orders"),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.inventory_2_outlined),
              activeIcon: const Icon(Icons.inventory_2),
              label: tr("Inventory"),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              activeIcon: const Icon(Icons.account_balance_wallet),
              label: tr("Wallet"),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: tr("Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
