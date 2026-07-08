import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_text_styles.dart';
import '../../models/order_model.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/order_card.dart';
import 'order_details_modal.dart';

class OrdersDashboardScreen extends ConsumerStatefulWidget {
  const OrdersDashboardScreen({super.key});

  @override
  ConsumerState<OrdersDashboardScreen> createState() => _OrdersDashboardScreenState();
}

class _OrdersDashboardScreenState extends ConsumerState<OrdersDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showHandoverModal(OrderModel order) {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text("Handover Order ${order.id}", style: AppTextStyles.heading1),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Ask Delivery Boy (${order.deliveryBoyName ?? 'Uday Bharat'}) for the 4-digit OTP code or scan QR.", style: AppTextStyles.bodyMedium),
                const SizedBox(height: 16),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading1.copyWith(letterSpacing: 6, fontSize: 20),
                  decoration: const InputDecoration(
                    hintText: "• • • •",
                    counterText: "",
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Hint: Order OTP is ${order.otp}",
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final success = ref.read(ordersProvider.notifier).handoverOrder(order.id, otpController.text.trim());
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("🎉 Order ${order.id} handed over successfully! Earning added to Wallet."),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("❌ Incorrect OTP! Please verify with Delivery Boy."),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Verify & Handover"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final newOrders = ref.watch(newOrdersProvider);
    final prepOrders = ref.watch(preparingOrdersProvider);
    final readyOrders = ref.watch(readyOrdersProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: "Live Orders",
        showOpenCloseToggle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert, color: AppColors.warning),
            tooltip: "Simulate New Order Alert",
            onPressed: () {
              ref.read(ordersProvider.notifier).simulateNewOrder();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.notifications_active, color: AppColors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "🔔 LOUD ALERT: New Order Received! Check New tab.",
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.warning,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 3 Tabs: New Orders, Preparing, Ready
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primaryDark,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTextStyles.heading3,
              tabs: [
                Tab(text: "New (${newOrders.length})"),
                Tab(text: "Preparing (${prepOrders.length})"),
                Tab(text: "Ready (${readyOrders.length})"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(newOrders, "No new incoming orders right now."),
                _buildOrderList(prepOrders, "No orders currently being prepared."),
                _buildOrderList(readyOrders, "No packed orders waiting for pickup."),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, String emptyMsg) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textLight),
            const SizedBox(height: 12),
            Text(emptyMsg, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          onViewDetails: () => OrderDetailsModal.show(context, order),
          onAccept: () {
            ref.read(ordersProvider.notifier).acceptOrder(order.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Order ${order.id} accepted! Moved to Preparing tab."),
                backgroundColor: AppColors.primaryDark,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          onReject: () {
            ref.read(ordersProvider.notifier).rejectOrder(order.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Order ${order.id} rejected."),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          onMarkReady: () {
            ref.read(ordersProvider.notifier).markAsReady(order.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Order ${order.id} marked as Ready! Delivery boy assigned."),
                backgroundColor: AppColors.info,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          onHandover: () => _showHandoverModal(order),
        );
      },
    );
  }
}
