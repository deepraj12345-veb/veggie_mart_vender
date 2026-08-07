import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../consts/app_colors.dart';
import '../consts/app_text_styles.dart';
import '../providers/store_provider.dart';
import '../providers/localization_provider.dart';
import '../screens/dashboard/notifications_screen.dart';

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
    final tr = ref.watch(translationProvider);

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
            child: const Icon(
              Icons.storefront,
              color: AppColors.primary,
              size: 20,
            ),
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
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isStoreOpen
                  ? AppColors.successLight
                  : AppColors.errorLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isStoreOpen
                    ? AppColors.success.withOpacity(0.4)
                    : AppColors.error.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                Text(
                  isStoreOpen ? tr("Online") : tr("Offline"),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isStoreOpen
                        ? AppColors.primaryDark
                        : AppColors.error,
                  ),
                ),
                const SizedBox(width: 2),
                SizedBox(
                  width: 38,
                  height: 24,
                  child: Transform.scale(
                    scale: 0.65,
                    child: Switch(
                      value: isStoreOpen,
                      activeThumbColor: AppColors.success,
                      inactiveThumbColor: AppColors.error,
                      inactiveTrackColor: AppColors.error.withOpacity(0.3),
                      onChanged: (val) {
                        ref.read(storeStatusProvider.notifier).toggleStatus();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              val
                                  ? tr("🟢 Store is now ONLINE for new orders!")
                                  : tr("🔴 Store is OFFLINE. No new orders will arrive."),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            backgroundColor: val
                                ? AppColors.primaryDark
                                : AppColors.error,
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

        // Notifications Icon
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),

        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
