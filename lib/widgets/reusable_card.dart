import 'package:flutter/material.dart';
import '../consts/app_colors.dart';

class ReusableCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;

  const ReusableCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12), // Standard compact padding (12px)
    this.margin = const EdgeInsets.only(bottom: 10),
    this.onTap,
    this.backgroundColor = AppColors.surface,
    this.borderColor = AppColors.border,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor ?? AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
