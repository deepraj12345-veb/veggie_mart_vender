import 'package:flutter/material.dart';
import '../consts/app_colors.dart';
import '../consts/app_text_styles.dart';
import '../models/order_model.dart';
import 'reusable_card.dart';
import 'custom_button.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onMarkReady;
  final VoidCallback? onHandover;
  final VoidCallback? onViewDetails;

  const OrderCard({
    super.key,
    required this.order,
    this.onAccept,
    this.onReject,
    this.onMarkReady,
    this.onHandover,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableCard(
      onTap: onViewDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Order ID, Status Badge & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      order.id,
                      style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Flexible(child: _buildStatusBadge()),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                order.dateTime,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 8),

          // Body: Customer Info & Items Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: AppTextStyles.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${order.totalItemsCount} Items (${order.items.map((e) => e.name).join(', ')})",
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Total Bill", style: AppTextStyles.bodySmall),
                  Text(
                    "₹${order.totalAmount.toInt()}",
                    style: AppTextStyles.amountText,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Footer Actions based on Order Status
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bg = AppColors.primaryLight;
    Color text = AppColors.primaryDark;
    String label = "New";

    switch (order.status) {
      case OrderStatus.newOrder:
        bg = AppColors.warningLight;
        text = AppColors.warning;
        label = "🔥 New";
        break;
      case OrderStatus.preparing:
        bg = AppColors.infoLight;
        text = AppColors.info;
        label = "📦 Preparing";
        break;
      case OrderStatus.ready:
        bg = AppColors.successLight;
        text = AppColors.success;
        label = "✅ Ready";
        break;
      case OrderStatus.completed:
        bg = AppColors.divider;
        text = AppColors.textSecondary;
        label = "🏁 Completed";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: AppTextStyles.badgeText.copyWith(color: text, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildActionButtons() {
    if (order.status == OrderStatus.newOrder) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              label: "Reject",
              onPressed: onReject ?? () {},
              backgroundColor: AppColors.errorLight,
              textColor: AppColors.error,
              isDense: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: CustomButton(
              label: "Accept Order",
              onPressed: onAccept ?? () {},
              backgroundColor: AppColors.success,
              textColor: AppColors.white,
              isDense: true,
              icon: Icons.check_circle_outline,
            ),
          ),
        ],
      );
    } else if (order.status == OrderStatus.preparing) {
      return CustomButton(
        label: "Mark as Ready",
        onPressed: onMarkReady ?? () {},
        backgroundColor: AppColors.info,
        textColor: AppColors.white,
        isDense: true,
        icon: Icons.done_all,
      );
    } else if (order.status == OrderStatus.ready) {
      return CustomButton(
        label: "Handover to Delivery Boy (OTP)",
        onPressed: onHandover ?? () {},
        backgroundColor: AppColors.primaryDark,
        textColor: AppColors.white,
        isDense: true,
        icon: Icons.qr_code_scanner,
      );
    }
    return const SizedBox.shrink();
  }
}
