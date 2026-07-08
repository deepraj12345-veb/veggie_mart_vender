import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../consts/app_colors.dart';
import '../consts/app_text_styles.dart';
import '../providers/store_provider.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showOpenCloseToggle;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showOpenCloseToggle = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isStoreOpen = ref.watch(storeStatusProvider);

    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.storefront, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.heading1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        if (showOpenCloseToggle)
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isStoreOpen ? AppColors.successLight : AppColors.errorLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isStoreOpen ? AppColors.success : AppColors.error,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isStoreOpen ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isStoreOpen ? "Open" : "Closed",
                  style: AppTextStyles.badgeText.copyWith(
                    color: isStoreOpen ? AppColors.primaryDark : AppColors.error,
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  height: 24,
                  child: Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      value: isStoreOpen,
                      activeThumbColor: AppColors.success,
                      inactiveThumbColor: AppColors.error,
                      onChanged: (val) {
                        ref.read(storeStatusProvider.notifier).toggleStatus();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              val ? "🟢 Store is now OPEN for new orders!" : "🔴 Store is CLOSED. No new orders will arrive.",
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                            ),
                            backgroundColor: val ? AppColors.primaryDark : AppColors.error,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
