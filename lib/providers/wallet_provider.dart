import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';

class WalletState {
  final double todayEarnings;
  final double availableBalance;
  final List<TransactionModel> transactions;

  const WalletState({
    required this.todayEarnings,
    required this.availableBalance,
    required this.transactions,
  });

  WalletState copyWith({
    double? todayEarnings,
    double? availableBalance,
    List<TransactionModel>? transactions,
  }) {
    return WalletState(
      todayEarnings: todayEarnings ?? this.todayEarnings,
      availableBalance: availableBalance ?? this.availableBalance,
      transactions: transactions ?? this.transactions,
    );
  }
}

class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() => const WalletState(
        todayEarnings: 1450.0,
        availableBalance: 8420.0,
        transactions: _initialTransactions,
      );

  void addTransaction(String orderId, double amount) {
    final newTxn = TransactionModel(
      id: "TXN-${8000 + state.transactions.length + 1}",
      orderId: orderId,
      date: "Today, Just now",
      amount: amount,
    );
    state = state.copyWith(
      todayEarnings: state.todayEarnings + amount,
      availableBalance: state.availableBalance + amount,
      transactions: [newTxn, ...state.transactions],
    );
  }

  bool withdrawToBank(double amount) {
    if (amount <= 0 || amount > state.availableBalance) {
      return false;
    }
    state = state.copyWith(
      availableBalance: state.availableBalance - amount,
    );
    return true;
  }
}

final walletProvider = NotifierProvider<WalletNotifier, WalletState>(WalletNotifier.new);

const List<TransactionModel> _initialTransactions = [
  TransactionModel(
    id: "TXN-8820",
    orderId: "#ORD-1038",
    date: "Today, 09:15 AM",
    amount: 320.0,
  ),
  TransactionModel(
    id: "TXN-8819",
    orderId: "#ORD-1035",
    date: "Today, 08:40 AM",
    amount: 450.0,
  ),
  TransactionModel(
    id: "TXN-8818",
    orderId: "#ORD-1031",
    date: "Yesterday, 07:20 PM",
    amount: 680.0,
  ),
  TransactionModel(
    id: "TXN-8817",
    orderId: "#ORD-1029",
    date: "Yesterday, 05:10 PM",
    amount: 210.0,
  ),
];
