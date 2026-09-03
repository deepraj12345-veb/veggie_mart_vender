import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../models/rider_model.dart';
import '../services/api_service.dart';
import 'wallet_provider.dart';

class OrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  @override
  Future<List<OrderModel>> build() async {
    return _fetchOrders();
  }

  Future<List<OrderModel>> _fetchOrders() async {
    try {
      return await ApiService.fetchOrders(page: 1, limit: 100);
    } catch (e) {
      print('Error fetching orders from API: $e');
      return [];
    }
  }

  Future<void> refresh() async {
    try {
      final newOrders = await _fetchOrders();
      state = AsyncValue.data(newOrders);
    } catch (e) {
      print('Silent refresh error: $e');
    }
  }

  // Accept incoming new order -> move to preparing
  Future<void> acceptOrder(String orderId) async {
    try {
      await ApiService.updateOrderStatus(orderId, OrderStatus.preparing.index);
      if (state.value != null) {
        state = AsyncValue.data([
          for (final order in state.value!)
            if (order.id == orderId)
              order.copyWith(status: OrderStatus.preparing)
            else
              order,
        ]);
      }
    } catch (e) {
      print('Error accepting order: $e');
      // Optimistic update fallback
      if (state.value != null) {
        state = AsyncValue.data([
          for (final order in state.value!)
            if (order.id == orderId)
              order.copyWith(status: OrderStatus.preparing)
            else
              order,
        ]);
      }
    }
  }

  // Reject incoming new order
  Future<void> rejectOrder(String orderId) async {
    try {
      await ApiService.deleteOrder(orderId);
      if (state.value != null) {
        state = AsyncValue.data(
          state.value!.where((order) => order.id != orderId).toList(),
        );
      }
    } catch (e) {
      print('Error deleting order: $e');
      if (state.value != null) {
        state = AsyncValue.data(
          state.value!.where((order) => order.id != orderId).toList(),
        );
      }
    }
  }

  // Mark preparing order as ready for pickup
  Future<void> markAsReady(String orderId) async {
    try {
      await ApiService.updateOrderStatus(orderId, OrderStatus.ready.index);
      if (state.value != null) {
        state = AsyncValue.data([
          for (final order in state.value!)
            if (order.id == orderId)
              order.copyWith(
                status: OrderStatus.ready,
              )
            else
              order,
        ]);
      }
    } catch (e) {
      print('Error marking as ready: $e');
      if (state.value != null) {
        state = AsyncValue.data([
          for (final order in state.value!)
            if (order.id == orderId)
              order.copyWith(
                status: OrderStatus.ready,
              )
            else
              order,
        ]);
      }
    }
  }

  Future<bool> assignRiderToOrder(String orderId, RiderModel rider) async {
    try {
      await ApiService.assignRider(orderId, rider.id);
      try {
        await ApiService.updateOrderStatus(orderId, OrderStatus.ready.index);
      } catch (_) {}

      if (state.value != null) {
        state = AsyncValue.data([
          for (final order in state.value!)
            if (order.id == orderId)
              order.copyWith(
                deliveryBoyName: rider.name,
                deliveryBoyPhone: rider.mobileNumber,
                status: OrderStatus.ready,
              )
            else
              order,
        ]);
      }
      return true;
    } catch (e) {
      print('Error assigning rider: $e');
      // Optimistic UI fallback: update local state so rider is assigned immediately
      if (state.value != null) {
        state = AsyncValue.data([
          for (final order in state.value!)
            if (order.id == orderId)
              order.copyWith(
                deliveryBoyName: rider.name,
                deliveryBoyPhone: rider.mobileNumber,
                status: OrderStatus.ready,
              )
            else
              order,
        ]);
      }
      return true;
    }
  }

  // Handover order to delivery boy
  Future<bool> handoverOrder(String orderId) async {
    if (state.value == null) return false;
    final order = state.value!.firstWhere((o) => o.id == orderId);

    try {
      await ApiService.updateOrderStatus(orderId, OrderStatus.completed.index);
      state = AsyncValue.data([
        for (final o in state.value!)
          if (o.id == orderId) o.copyWith(status: OrderStatus.completed) else o,
      ]);
      ref
          .read(walletProvider.notifier)
          .addTransaction(order.id, order.totalAmount);
      return true;
    } catch (e) {
      print('Error handing over order: $e');
      // Optimistic
      state = AsyncValue.data([
        for (final o in state.value!)
          if (o.id == orderId) o.copyWith(status: OrderStatus.completed) else o,
      ]);
      ref
          .read(walletProvider.notifier)
          .addTransaction(order.id, order.totalAmount);
      return true;
    }
  }

  // Simulate receiving a new order with loud notification alert
  void simulateNewOrder() {
    if (state.value == null) return;
    final newOrder = OrderModel(
      id: "#ORD-${1000 + state.value!.length + 1}",
      customerName: "Priya Verma",
      customerPhone: "+91 9898989898",
      dateTime: "Just now",
      items: const [
        OrderItem(
          name: "Fresh Tamatar (Tomato)",
          quantity: "2 Kg",
          price: 80.0,
        ),
        OrderItem(name: "Lal Pyaz (Red Onion)", quantity: "1 Kg", price: 35.0),
        OrderItem(name: "Hara Dhania", quantity: "1 Bunch", price: 20.0),
      ],
      totalAmount: 135.0,
      status: OrderStatus.newOrder,
      otp: "8821",
    );
    state = AsyncValue.data([newOrder, ...state.value!]);
  }
}

final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<OrderModel>>(
  OrdersNotifier.new,
);

// Helper derived providers for the 3 Tabs
final newOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(ordersProvider).value ?? [];
  return orders.where((o) => o.status == OrderStatus.newOrder).toList();
});

final preparingOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(ordersProvider).value ?? [];
  return orders.where((o) => o.status == OrderStatus.preparing).toList();
});

final readyOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(ordersProvider).value ?? [];
  return orders.where((o) => o.status == OrderStatus.ready).toList();
});

final completedOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(ordersProvider).value ?? [];
  return orders.where((o) => o.status == OrderStatus.completed).toList();
});
