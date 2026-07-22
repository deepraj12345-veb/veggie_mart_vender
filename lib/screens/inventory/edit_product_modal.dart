import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_text_styles.dart';
import '../../models/product_model.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/custom_button.dart';

class EditProductModal {
  static void show(BuildContext context, WidgetRef ref, ProductModel product) {
    final nameController = TextEditingController(text: product.name);
    final emojiController = TextEditingController(text: product.imageUrl);
    String selectedCategory = product.category;

    // Default categories if product category is not in list
    final categories = ["Vegetables", "Fruits", "Leafy", "Spices", "Dairy"];
    if (!categories.contains(selectedCategory)) {
      categories.add(selectedCategory);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  Text("Edit Product Details", style: AppTextStyles.heading1),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Item Name"),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: emojiController,
                          maxLength: 2,
                          decoration: const InputDecoration(labelText: "Emoji", counterText: ""),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          items: categories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) => setModalState(() => selectedCategory = val!),
                          decoration: const InputDecoration(labelText: "Category"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: "Save Changes",
                    onPressed: () {
                      if (nameController.text.trim().isNotEmpty) {
                        ref.read(inventoryProvider.notifier).updateProductDetails(
                              product.id,
                              nameController.text.trim(),
                              selectedCategory,
                              emojiController.text.trim().isEmpty ? "🥦" : emojiController.text.trim(),
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${product.name} updated successfully!"),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    icon: Icons.check,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
