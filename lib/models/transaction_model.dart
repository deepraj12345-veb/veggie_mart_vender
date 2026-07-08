class TransactionModel {
  final String id;
  final String orderId;
  final String date;
  final double amount;
  final bool isSettled;

  const TransactionModel({
    required this.id,
    required this.orderId,
    required this.date,
    required this.amount,
    this.isSettled = true,
  });

  TransactionModel copyWith({
    String? id,
    String? orderId,
    String? date,
    double? amount,
    bool? isSettled,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      isSettled: isSettled ?? this.isSettled,
    );
  }
}
