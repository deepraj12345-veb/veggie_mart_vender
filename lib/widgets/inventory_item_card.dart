import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../consts/app_colors.dart';
import '../consts/app_text_styles.dart';
import '../models/product_model.dart';
import '../providers/inventory_provider.dart';
import '../screens/inventory/edit_product_modal.dart';
import 'reusable_card.dart';

class InventoryItemCard extends ConsumerStatefulWidget {
  final ProductModel product;

  const InventoryItemCard({super.key, required this.product});

  @override
  ConsumerState<InventoryItemCard> createState() => _InventoryItemCardState();
}

class _InventoryItemCardState extends ConsumerState<InventoryItemCard> {
  late TextEditingController _priceController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.product.price.toInt().toString());
  }

  @override
  void didUpdateWidget(covariant InventoryItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.product.price.isAtSameMomentAs(widget.product.price)) {
      _priceController.text = widget.product.price.toInt().toString();
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _savePrice() {
    final newPrice = double.tryParse(_priceController.text) ?? widget.product.price;
    ref.read(inventoryProvider.notifier).updatePrice(widget.product.id, newPrice);
    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Price updated to ₹${newPrice.toInt()}/Kg for ${widget.product.name}"),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return ReusableCard(
      backgroundColor: product.inStock ? AppColors.surface : AppColors.background,
      borderColor: product.inStock ? AppColors.border : AppColors.errorLight,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: product.inStock ? AppColors.primaryLight : AppColors.errorLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: product.imageUrl.startsWith('http://') || product.imageUrl.startsWith('https://')
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      width: 48,
                      height: 48,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_basket, color: AppColors.primary),
                    ),
                  )
                : product.imageUrl.length > 5
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(product.imageUrl),
                          fit: BoxFit.cover,
                          width: 48,
                          height: 48,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_basket, color: AppColors.primary),
                        ),
                      )
                    : Text(
                        product.imageUrl.isNotEmpty ? product.imageUrl : '🥦',
                        style: const TextStyle(fontSize: 24),
                      ),
          ),
          const SizedBox(width: 10),

          // Name, Category & Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.heading3.copyWith(
                    decoration: product.inStock ? null : TextDecoration.lineThrough,
                    color: product.inStock ? AppColors.textPrimary : AppColors.textLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(product.category, style: AppTextStyles.badgeText.copyWith(color: AppColors.textSecondary, fontSize: 10)),
                    ),
                    if (!product.inStock)
                      Text("Out of Stock", style: AppTextStyles.badgeText.copyWith(color: AppColors.error, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 10),
                
                // Editable Price Section
                if (_isEditing)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 32,
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            prefixText: "₹",
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: AppColors.success, size: 24),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _savePrice,
                      ),
                    ],
                  )
                else
                  InkWell(
                    onTap: () => setState(() => _isEditing = true),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "₹${product.price.toInt()}",
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit, size: 12, color: AppColors.primaryDark),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Actions Right Side
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // In-Stock / Out-of-Stock Toggle Switch
              SizedBox(
                height: 28,
                child: Transform.scale(
                  scale: 0.8,
                  alignment: Alignment.centerRight,
                  child: Switch(
                    value: product.inStock,
                    activeThumbColor: AppColors.success,
                    inactiveThumbColor: AppColors.error,
                    onChanged: (val) {
                      ref.read(inventoryProvider.notifier).toggleStock(product.id);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit Details Button
                  IconButton(
                    icon: const Icon(Icons.edit_note, color: AppColors.primary, size: 24),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      EditProductModal.show(context, ref, product);
                    },
                  ),
                  const SizedBox(width: 8),
                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Product"),
                          content: Text("Are you sure you want to remove ${product.name} from your catalog?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                              onPressed: () {
                                ref.read(inventoryProvider.notifier).removeProduct(product.id);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("${product.name} removed from catalog"), backgroundColor: AppColors.error),
                                );
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension on double {
  bool isAtSameMomentAs(double price) => this == price;
}
