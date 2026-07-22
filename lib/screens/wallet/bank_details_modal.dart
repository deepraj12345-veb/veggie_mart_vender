import 'package:flutter/material.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_text_styles.dart';
import '../../widgets/custom_button.dart';

class BankDetailsModal {
  static void show(BuildContext context) {
    // Hardcoded dummy values
    final nameController = TextEditingController(text: "Ramesh Gupta");
    final accountController = TextEditingController(text: "123456789012");
    final ifscController = TextEditingController(text: "HDFC0001234");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
              Text("Manage Bank Account", style: AppTextStyles.heading1),
              const SizedBox(height: 6),
              Text("This account will be used for all your payouts.", style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
              
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Account Holder Name"),
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: accountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Bank Account Number"),
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: ifscController,
                decoration: const InputDecoration(labelText: "IFSC Code"),
              ),
              const SizedBox(height: 24),
              
              CustomButton(
                label: "Save Bank Details",
                onPressed: () {
                  if (accountController.text.length < 8) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Invalid Account Number!"),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Bank details updated successfully!"),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: Icons.account_balance,
              ),
            ],
          ),
        );
      },
    );
  }
}
