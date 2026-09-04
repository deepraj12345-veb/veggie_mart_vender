import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';

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
  WalletState build() {
    _loadAndSync();
    return WalletState(
      todayEarnings: 0.0,
      availableBalance: ApiService.walletBalance,
      transactions: _initialTransactions,
    );
  }

  Future<void> _loadAndSync() async {
    try {
      await ApiService.loadFromPrefs();
      double balance = ApiService.walletBalance;
      if (balance == 0.0) {
        final vendorData = await ApiService.fetchVendorProfile();
        if (vendorData.isNotEmpty) {
          balance = ApiService.walletBalance;
        }
      }
      state = state.copyWith(availableBalance: balance);
    } catch (_) {}
  }

  void syncBalance(double balance) {
    state = state.copyWith(availableBalance: balance);
  }

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

const List<TransactionModel> _initialTransactions = [];
