enum OrderStatus { newOrder, preparing, ready, completed }

class OrderItem {
  final String name;
  final String quantity;
  final double price;

  const OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  OrderItem copyWith({
    String? name,
    String? quantity,
    double? price,
  }) {
    return OrderItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}

class OrderModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String dateTime;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final String? deliveryBoyName;
  final String? deliveryBoyPhone;
  final String otp;

  const OrderModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.dateTime,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.deliveryBoyName,
    this.deliveryBoyPhone,
    required this.otp,
  });

  int get totalItemsCount => items.length;

  OrderModel copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? dateTime,
    List<OrderItem>? items,
    double? totalAmount,
    OrderStatus? status,
    String? deliveryBoyName,
    String? deliveryBoyPhone,
    String? otp,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      dateTime: dateTime ?? this.dateTime,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      deliveryBoyName: deliveryBoyName ?? this.deliveryBoyName,
      deliveryBoyPhone: deliveryBoyPhone ?? this.deliveryBoyPhone,
      otp: otp ?? this.otp,
    );
  }
}
