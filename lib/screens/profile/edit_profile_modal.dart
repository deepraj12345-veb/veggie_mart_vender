import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_text_styles.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/custom_button.dart';

class EditProfileModal {
  static void show(BuildContext context, WidgetRef ref) {
    final profile = ref.read(profileProvider);

    final nameController = TextEditingController(text: profile.vendorName);
    final emailController = TextEditingController(text: profile.email);
    final phoneController = TextEditingController(text: profile.phoneNumber);
    final storeNameController = TextEditingController(text: profile.storeName);
    final storeAddressController = TextEditingController(text: profile.storeAddress);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
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
              Text("Edit Profile & Store Details", style: AppTextStyles.heading1),
              const SizedBox(height: 16),
              
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Vendor / Owner Name"),
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "Email Address"),
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone Number"),
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: storeNameController,
                decoration: const InputDecoration(labelText: "Store Name"),
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: storeAddressController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: "Store Address"),
              ),
              const SizedBox(height: 24),
              
              CustomButton(
                label: "Save Changes",
                onPressed: () {
                  ref.read(profileProvider.notifier).updateProfile(
                    vendorName: nameController.text.trim(),
                    email: emailController.text.trim(),
                    phoneNumber: phoneController.text.trim(),
                    storeName: storeNameController.text.trim(),
                    storeAddress: storeAddressController.text.trim(),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Profile details updated successfully!"),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: Icons.save,
              ),
            ],
          ),
        );
      },
    );
  }
}
