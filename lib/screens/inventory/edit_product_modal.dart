import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_text_styles.dart';
import '../../models/product_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../providers/inventory_provider.dart';
import '../../widgets/custom_button.dart';

class EditProductModal {
  static void show(BuildContext context, WidgetRef ref, ProductModel product) {
    final nameController = TextEditingController(text: product.name);
    String? imagePath = product.imageUrl.length > 2 ? product.imageUrl : null;
    String selectedCategory = product.category;
    final ImagePicker picker = ImagePicker();

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
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setModalState(() => selectedCategory = val!),
                    decoration: const InputDecoration(labelText: "Category"),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (imagePath != null || (product.imageUrl.length <= 2 && product.imageUrl.isNotEmpty))
                        Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.primaryLight,
                          ),
                          alignment: Alignment.center,
                          child: imagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(imagePath!),
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                  ),
                                )
                              : Text(product.imageUrl, style: const TextStyle(fontSize: 24)),
                        ),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final source = await showDialog<ImageSource>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Select Image Source"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt),
                                      title: const Text("Camera"),
                                      onTap: () => Navigator.pop(context, ImageSource.camera),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text("Gallery"),
                                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            if (source != null) {
                              try {
                                final XFile? image = await picker.pickImage(source: source);
                                if (image != null) {
                                  setModalState(() {
                                    imagePath = image.path;
                                  });
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Error opening Camera/Gallery. Note: Camera is not supported on Windows desktop. Also try restarting the app."),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          icon: const Icon(Icons.image),
                          label: const Text("Update Image"),
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
                              imagePath ?? product.imageUrl,
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
