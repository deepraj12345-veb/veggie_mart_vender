import 'package:flutter/material.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_text_styles.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy notifications for UI
    final List<Map<String, String>> notifications = [
      {
        "title": "New Order Received! 🛍️",
        "message": "Order #1234 has been placed. Please start preparing.",
        "time": "Just now",
        "type": "order"
      },
      {
        "title": "Stock Alert ⚠️",
        "message": "Hara Dhania is out of stock. Please update inventory.",
        "time": "2 hours ago",
        "type": "alert"
      },
      {
        "title": "Payout Processed 💰",
        "message": "Your weekly payout of ₹4,500 has been credited to your bank.",
        "time": "1 day ago",
        "type": "wallet"
      },
      {
        "title": "Order Handed Over ✅",
        "message": "Order #1220 successfully handed over to Uday Bharat.",
        "time": "Yesterday",
        "type": "success"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications", style: AppTextStyles.heading1),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(color: AppColors.divider, height: 24),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          IconData icon;
          Color iconColor;

          switch (notif["type"]) {
            case "order":
              icon = Icons.shopping_bag;
              iconColor = AppColors.primary;
              break;
            case "alert":
              icon = Icons.warning_rounded;
              iconColor = AppColors.warning;
              break;
            case "wallet":
              icon = Icons.account_balance_wallet;
              iconColor = AppColors.info;
              break;
            case "success":
              icon = Icons.check_circle;
              iconColor = AppColors.success;
              break;
            default:
              icon = Icons.notifications;
              iconColor = AppColors.textSecondary;
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif["title"]!,
                            style: AppTextStyles.heading3,
                          ),
                        ),
                        Text(
                          notif["time"]!,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif["message"]!,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
