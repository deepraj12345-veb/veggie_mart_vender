import 'package:flutter/material.dart';
import '../consts/app_colors.dart';
import '../consts/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;
  final IconData? icon;
  final double height;
  final bool isDense;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.white,
    this.isOutlined = false,
    this.icon,
    this.height = 40, // Standard compact height
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primary,
          minimumSize: Size(0, isDense ? 34 : height),
          padding: EdgeInsets.symmetric(horizontal: isDense ? 8 : 12),
          side: BorderSide(
            color: backgroundColor ?? AppColors.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _buildContent(),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? AppColors.white,
        minimumSize: Size(0, isDense ? 34 : height),
        padding: EdgeInsets.symmetric(horizontal: isDense ? 8 : 12),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: isOutlined
                ? (textColor ?? AppColors.primary)
                : (textColor ?? AppColors.white),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.buttonText.copyWith(
                color: isOutlined
                    ? (textColor ?? AppColors.primary)
                    : (textColor ?? AppColors.white),
                fontSize: isDense ? 12 : 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        style: AppTextStyles.buttonText.copyWith(
          color: isOutlined
              ? (textColor ?? AppColors.primary)
              : (textColor ?? AppColors.white),
          fontSize: isDense ? 12 : 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
