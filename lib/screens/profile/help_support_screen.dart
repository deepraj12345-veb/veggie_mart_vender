import 'package:flutter/material.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_text_styles.dart';
import '../../widgets/custom_button.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help & Support", style: AppTextStyles.heading1),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Frequently Asked Questions", style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            _buildFaqItem("How to update my store address?", "Go to Profile & Settings, tap the edit icon next to your store address and save the changes."),
            _buildFaqItem("How do I contact a delivery boy?", "Once an order is marked as Ready, the delivery boy's contact details will be visible in the Order Details modal."),
            _buildFaqItem("When do I get my payouts?", "Payouts are processed weekly on Mondays and credited directly to your connected bank account."),
            const SizedBox(height: 30),
            
            Text("Contact Veggie Mart Admin", style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Describe your issue or query here...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: "Submit Ticket",
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Support ticket submitted! We will contact you soon."),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pop(context);
              },
              icon: Icons.send,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Or call us directly at 1800-VEGGIE (Toll Free)",
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      iconColor: AppColors.primary,
      collapsedIconColor: AppColors.textSecondary,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Text(answer, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
