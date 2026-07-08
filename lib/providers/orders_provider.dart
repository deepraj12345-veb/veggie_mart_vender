import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import 'wallet_provider.dart';

class OrdersNotifier extends Notifier<List<OrderModel>> {
  @override
  List<OrderModel> build() => _initialOrders;

  // Accept incoming new order -> move to preparing
  void acceptOrder(String orderId) {
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(status: OrderStatus.preparing)
        else
          order
    ];
  }

  // Reject incoming new order
  void rejectOrder(String orderId) {
    state = state.where((order) => order.id != orderId).toList();
  }

  // Mark preparing order as ready for pickup
  void markAsReady(String orderId) {
    state = [
      for (final order in state)
        if (order.id == orderId)
          order.copyWith(
            status: OrderStatus.ready,
            deliveryBoyName: "Uday Bharat (Delivery)",
            deliveryBoyPhone: "+91 9811223344",
          )
        else
          order
    ];
  }

  // Handover order to delivery boy via OTP verification
  bool handoverOrder(String orderId, String enteredOtp) {
    final order = state.firstWhere((o) => o.id == orderId, orElse: () => _initialOrders.first);
    if (order.otp == enteredOtp) {
      state = [
        for (final o in state)
          if (o.id == orderId)
            o.copyWith(status: OrderStatus.completed)
          else
            o
      ];
      // Add earning to wallet using Riverpod 3 ref
      ref.read(walletProvider.notifier).addTransaction(order.id, order.totalAmount);
      return true;
    }
    return false;
  }

  // Simulate receiving a new order with loud notification alert
  void simulateNewOrder() {
    final newOrder = OrderModel(
      id: "#ORD-${1000 + state.length + 1}",
      customerName: "Priya Verma",
      customerPhone: "+91 9898989898",
      dateTime: "Just now",
      items: const [
        OrderItem(name: "Fresh Tamatar (Tomato)", quantity: "2 Kg", price: 80.0),
        OrderItem(name: "Lal Pyaz (Red Onion)", quantity: "1 Kg", price: 35.0),
        OrderItem(name: "Hara Dhania", quantity: "1 Bunch", price: 20.0),
      ],
      totalAmount: 135.0,
      status: OrderStatus.newOrder,
      otp: "8821",
    );
    state = [newOrder, ...state];
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, List<OrderModel>>(OrdersNotifier.new);

// Helper derived providers for the 3 Tabs
final newOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(ordersProvider);
  return orders.where((o) => o.status == OrderStatus.newOrder).toList();
});

final preparingOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(ordersProvider);
  return orders.where((o) => o.status == OrderStatus.preparing).toList();
});

final readyOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(ordersProvider);
  return orders.where((o) => o.status == OrderStatus.ready).toList();
});

final completedOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(ordersProvider);
  return orders.where((o) => o.status == OrderStatus.completed).toList();
});

final List<OrderModel> _initialOrders = [
  const OrderModel(
    id: "#ORD-1042",
    customerName: "Rahul Sharma",
    customerPhone: "+91 9876543210",
    dateTime: "Today, 10:30 AM",
    items: [
      OrderItem(name: "Fresh Tamatar (Tomato)", quantity: "2 Kg", price: 80.0),
      OrderItem(name: "Pahadi Aloo (Potato)", quantity: "3 Kg", price: 90.0),
      OrderItem(name: "Hari Mirch (Green Chilli)", quantity: "250g", price: 20.0),
    ],
    totalAmount: 190.0,
    status: OrderStatus.newOrder,
    otp: "4512",
  ),
  const OrderModel(
    id: "#ORD-1043",
    customerName: "Anjali Gupta",
    customerPhone: "+91 9812345678",
    dateTime: "Today, 10:35 AM",
    items: [
      OrderItem(name: "Lal Pyaz (Red Onion)", quantity: "2 Kg", price: 70.0),
      OrderItem(name: "Robusta Banana (Kela)", quantity: "1 Dozen", price: 50.0),
    ],
    totalAmount: 120.0,
    status: OrderStatus.newOrder,
    otp: "9021",
  ),
  const OrderModel(
    id: "#ORD-1040",
    customerName: "Vikram Singh",
    customerPhone: "+91 9988776655",
    dateTime: "Today, 10:15 AM",
    items: [
      OrderItem(name: "Amul Masti Curd", quantity: "2 Pouch", price: 70.0),
      OrderItem(name: "Fresh Tamatar (Tomato)", quantity: "1 Kg", price: 40.0),
    ],
    totalAmount: 110.0,
    status: OrderStatus.preparing,
    otp: "1234",
  ),
  const OrderModel(
    id: "#ORD-1039",
    customerName: "Suresh Kumar",
    customerPhone: "+91 9765432109",
    dateTime: "Today, 09:50 AM",
    items: [
      OrderItem(name: "Pahadi Aloo (Potato)", quantity: "5 Kg", price: 150.0),
    ],
    totalAmount: 150.0,
    status: OrderStatus.ready,
    deliveryBoyName: "Uday Bharat",
    deliveryBoyPhone: "+91 9811223344",
    otp: "5678",
  ),
];
