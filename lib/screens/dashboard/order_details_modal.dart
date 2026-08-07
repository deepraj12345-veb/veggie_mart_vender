import 'package:flutter/material.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_text_styles.dart';
import '../../models/order_model.dart';
import '../../widgets/custom_button.dart';

class OrderDetailsModal {
  static void show(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header: Order ID, Date & Time, Customer Name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.id,
                      style: AppTextStyles.heading1.copyWith(color: AppColors.primaryDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Customer: ${order.customerName}",
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "Order Date: ${order.dateTime}",
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 10),

              // Item List: Sabzi/Phal name, Quantity, Price
              Text("Ordered Items (${order.totalItemsCount})", style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: order.items.length,
                  separatorBuilder: (context, index) => const Divider(color: AppColors.divider, height: 16),
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${item.name} x ${item.quantity}",
                            style: AppTextStyles.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "₹${item.price.toInt()}",
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 10),

              // Footer: Total Bill Amount & Call Delivery Boy
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Bill Amount", style: AppTextStyles.heading2),
                  Text(
                    "₹${order.totalAmount.toInt()}",
                    style: AppTextStyles.amountText.copyWith(fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: "Call Delivery Boy",
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Calling Delivery Boy (${order.deliveryBoyName ?? 'Uday Bharat'})..."),
                            backgroundColor: AppColors.primaryDark,
                          ),
                        );
                      },
                      backgroundColor: AppColors.primary,
                      icon: Icons.delivery_dining,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
