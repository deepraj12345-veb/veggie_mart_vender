import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_text_styles.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/reusable_card.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: "Profile & Settings",
        showOpenCloseToggle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor Name, Phone Number & Store Details
            ReusableCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Text("🏪", style: TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.vendorName, style: AppTextStyles.heading1, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(profile.phoneNumber, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(4)),
                          child: Text(profile.storeName, style: AppTextStyles.badgeText.copyWith(color: AppColors.primaryDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Store Address Card
            ReusableCard(
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Store Address", style: AppTextStyles.bodySmall),
                        Text(profile.storeAddress, style: AppTextStyles.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: AppColors.textSecondary),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Edit store address modal coming soon!")),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Language Selector: English / Hindi
            Text("App Settings", style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            ReusableCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.language, color: AppColors.primary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Language / भाषा", style: AppTextStyles.heading3, maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text("Current: ${profile.language}", style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      _buildLangChip(ref, "English", profile.language == "English"),
                      const SizedBox(width: 6),
                      _buildLangChip(ref, "Hindi", profile.language == "Hindi"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Help & Support / Contact Admin
            ReusableCard(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Connecting to Veggie Mart Support Desk...")),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.help_outline, color: AppColors.info, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text("Help & Support / Contact Admin", style: AppTextStyles.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // "Logout" Button
            CustomButton(
              label: "Logout from Account",
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout from Veggie Mart Vendor app?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                );
              },
              backgroundColor: AppColors.errorLight,
              textColor: AppColors.error,
              icon: Icons.logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangChip(WidgetRef ref, String lang, bool isSelected) {
    return InkWell(
      onTap: () => ref.read(profileProvider.notifier).updateLanguage(lang),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          lang,
          style: AppTextStyles.badgeText.copyWith(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
