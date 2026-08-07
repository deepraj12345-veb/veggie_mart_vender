import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_text_styles.dart';
import '../../models/order_model.dart';
import '../../providers/orders_provider.dart';
import '../../providers/localization_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/order_card.dart';
import '../../widgets/assign_rider_modal.dart';
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
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showHandoverModal(OrderModel order) {
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
                Text("Are you sure you want to handover this order to the Delivery Boy (${order.deliveryBoyName ?? 'Uday Bharat'})?", style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await ref.read(ordersProvider.notifier).handoverOrder(order.id);
                if (!context.mounted) return;
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
                      content: Text("❌ Failed to handover order!"),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Handover"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationProvider);
    final newOrders = ref.watch(newOrdersProvider);
    final prepOrders = ref.watch(preparingOrdersProvider);
    final readyOrders = ref.watch(readyOrdersProvider);
    final completedOrders = ref.watch(completedOrdersProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: tr("Live Orders"),
        showOpenCloseToggle: true,
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
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: "${tr("New")} (${newOrders.length})"),
                Tab(text: "${tr("Preparing")} (${prepOrders.length})"),
                Tab(text: "${tr("Ready")} (${readyOrders.length})"),
                Tab(text: "${tr("Completed")} (${completedOrders.length})"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(newOrders, tr("No new incoming orders right now.")),
                _buildOrderList(prepOrders, tr("No orders currently being prepared.")),
                _buildOrderList(readyOrders, tr("No packed orders waiting for pickup.")),
                _buildOrderList(completedOrders, tr("No completed orders yet."), isCompleted: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, String emptyMsg, {bool isCompleted = false}) {
    Widget content;
    if (orders.isEmpty) {
      content = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textLight),
              const SizedBox(height: 12),
              Text(emptyMsg, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    } else {
      content = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return OrderCard(
            order: order,
            onViewDetails: () => OrderDetailsModal.show(context, order),
            onAccept: () async {
              if (isCompleted) return;
              await ref.read(ordersProvider.notifier).acceptOrder(order.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Order ${order.id} accepted! Moved to Preparing tab."),
                  backgroundColor: AppColors.primaryDark,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            onReject: () async {
              if (isCompleted) return;
              await ref.read(ordersProvider.notifier).rejectOrder(order.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Order ${order.id} rejected."),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            onAssignRider: () {
              if (isCompleted) return;
              AssignRiderModal.show(context, order, (rider) async {
                final success = await ref.read(ordersProvider.notifier).assignRiderToOrder(order.id, rider);
                if (!context.mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Rider ${rider.name} assigned to Order ${order.id}!"),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to assign rider"),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              });
            },
            onMarkReady: () async {
              if (isCompleted) return;
              await ref.read(ordersProvider.notifier).markAsReady(order.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Order ${order.id} marked as Ready! Delivery boy assigned."),
                  backgroundColor: AppColors.info,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            onHandover: () {
              if (isCompleted) return;
              _showHandoverModal(order);
            },
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(ordersProvider.notifier).refresh();
      },
      child: content,
    );
  }
}
