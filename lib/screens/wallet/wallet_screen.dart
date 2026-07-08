import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_text_styles.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/stat_summary_card.dart';
import '../../widgets/reusable_card.dart';
import '../../widgets/custom_button.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  void _showWithdrawDialog(BuildContext context, WidgetRef ref, double availableBalance) {
    final amountController = TextEditingController(text: availableBalance.toInt().toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text("Withdraw to Bank", style: AppTextStyles.heading1),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Transfer instant earnings to your registered bank account.", style: AppTextStyles.bodyMedium),
                const SizedBox(height: 14),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount to Withdraw (₹)",
                    prefixText: "₹ ",
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Available: ₹${availableBalance.toInt()}",
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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
                final amount = double.tryParse(amountController.text.trim()) ?? 0;
                final success = ref.read(walletProvider.notifier).withdrawToBank(amount);
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("🎉 ₹${amount.toInt()} withdrawal request submitted! Money will reach your bank shortly."),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("❌ Invalid amount or insufficient balance."),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Confirm Transfer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: "Wallet & Earnings",
        showOpenCloseToggle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section (Summary Cards): Today's Earnings & Available Balance
            Row(
              children: [
                Expanded(
                  child: StatSummaryCard(
                    title: "Today's Earnings",
                    value: "₹${walletState.todayEarnings.toInt()}",
                    icon: Icons.trending_up,
                    iconColor: AppColors.success,
                    backgroundColor: AppColors.successLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatSummaryCard(
                    title: "Available Balance",
                    value: "₹${walletState.availableBalance.toInt()}",
                    icon: Icons.account_balance_wallet,
                    iconColor: AppColors.primary,
                    backgroundColor: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // "Withdraw to Bank" Button
            CustomButton(
              label: "Withdraw to Bank Account",
              onPressed: () => _showWithdrawDialog(context, ref, walletState.availableBalance),
              icon: Icons.account_balance,
              height: 48,
            ),
            const SizedBox(height: 24),

            // Bottom Section (Transaction History)
            Text("Completed Orders Earning History", style: AppTextStyles.heading1),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: walletState.transactions.length,
              itemBuilder: (context, index) {
                final txn = walletState.transactions[index];
                return ReusableCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Order ${txn.orderId}",
                                    style: AppTextStyles.heading3,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    txn.date,
                                    style: AppTextStyles.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "+ ₹${txn.amount.toInt()}",
                        style: AppTextStyles.amountText.copyWith(color: AppColors.success),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
