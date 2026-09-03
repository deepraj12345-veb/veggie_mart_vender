enum OrderStatus { newOrder, preparing, ready, completed }

class OrderItem {
  final String name;
  final String quantity; // maps to 'qty' in backend
  final double price;

  const OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  OrderItem copyWith({String? name, String? quantity, double? price}) {
    return OrderItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['product_name'] ?? json['name'] ?? 'Unknown',
      quantity: json['qty']?.toString() ?? '1',
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'product_name': name, 'qty': quantity, 'price': price};
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

  static String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final DateTime dt = DateTime.parse(dateStr.toString()).toLocal();
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sept',
        'Oct',
        'Nov',
        'Dec'
      ];
      final String month = months[dt.month - 1];
      final String hour = dt.hour > 12
          ? (dt.hour - 12).toString()
          : (dt.hour == 0 ? '12' : dt.hour.toString());
      final String minute = dt.minute.toString().padLeft(2, '0');
      final String ampm = dt.hour >= 12 ? 'pm' : 'am';
      return '${dt.day} $month ${dt.year} at $hour:$minute $ampm';
    } catch (_) {
      return dateStr.toString();
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    int statusInt = json['status'] ?? -1;
    String statusStr = json['orderStatus'] ?? '';

    OrderStatus mappedStatus;
    if (statusInt != -1 && statusInt < OrderStatus.values.length) {
      mappedStatus = OrderStatus.values[statusInt];
    } else {
      switch (statusStr.toLowerCase()) {
        case 'packing':
        case 'order confirmed':
        case 'preparing':
        case 'accepted':
          mappedStatus = OrderStatus.preparing;
          break;
        case 'ready':
          mappedStatus = OrderStatus.ready;
          break;
        case 'delivered':
        case 'completed':
        case 'out for delivery':
          mappedStatus = OrderStatus.completed;
          break;
        case 'order placed':
        case 'pending':
        default:
          mappedStatus = OrderStatus.newOrder;
      }
    }

    List<OrderItem> parsedItems = [];
    if (json['populatedItems'] != null) {
      parsedItems = (json['populatedItems'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList();
    } else if (json['items'] != null && json['items'] is List) {
      try {
        parsedItems = (json['items'] as List)
            .map(
              (item) => item is Map
                  ? OrderItem.fromJson(item as Map<String, dynamic>)
                  : const OrderItem(name: "Unknown", quantity: "1", price: 0),
            )
            .toList();
      } catch (_) {}
    }

    final shippingAddress = json['shippingAddress'] is Map ? json['shippingAddress'] : {};
    final user = json['user_id'] is Map ? json['user_id'] : {};

    final String mobile = (user['mobile_no'] ??
            shippingAddress['mobile'] ??
            shippingAddress['phone'] ??
            json['customerPhone'] ??
            '')
        .toString();
    final String rawName = (user['name'] ??
            shippingAddress['fullName'] ??
            json['customerName'] ??
            '')
        .toString()
        .trim();
    final String name = rawName.isNotEmpty
        ? rawName
        : (mobile.isNotEmpty ? 'Customer ($mobile)' : 'Customer');

    final deliveryBoy = json['delivery_boy_id'] is Map ? json['delivery_boy_id'] : {};

    return OrderModel(
      id: json['order_number'] ?? json['_id'] ?? json['id'] ?? '',
      customerName: name,
      customerPhone: mobile,
      dateTime: _formatDate(json['createdAt'] ?? json['dateTime']),
      items: parsedItems,
      totalAmount: (json['total_amount'] ?? json['totalAmount'] ?? 0.0)
          .toDouble(),
      status: mappedStatus,
      deliveryBoyName: deliveryBoy['name'] ?? json['deliveryBoyName'],
      deliveryBoyPhone: deliveryBoy['mobile'] ?? json['deliveryBoyPhone'],
      otp: json['otp']?.toString() ?? '1234',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'status': status.index,
      'total_amount': totalAmount,
      'deliveryBoyName': deliveryBoyName,
      'deliveryBoyPhone': deliveryBoyPhone,
      'otp': otp,
    };
  }
}
