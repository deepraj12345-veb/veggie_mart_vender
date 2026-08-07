import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_text_styles.dart';
import '../../models/product_model.dart';
import '../../providers/inventory_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../providers/localization_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/inventory_item_card.dart';
import '../../widgets/custom_button.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddProductModal(List<String> categories) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String? imagePath;
    String selectedCategory = categories.isNotEmpty ? categories.first : "Vegetables";
    bool isSaving = false;
    final ImagePicker picker = ImagePicker();

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
                  Text("Add New Grocery Item", style: AppTextStyles.heading1),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Item Name (e.g. Fresh Palak)"),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Price (₹)", prefixText: "₹ "),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedCategory,
                          items: categories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) => setModalState(() => selectedCategory = val!),
                          decoration: const InputDecoration(labelText: "Category"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (imagePath != null)
                        Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(File(imagePath!)),
                              fit: BoxFit.cover,
                            ),
                          ),
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
                          label: const Text("Upload Image"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    label: isSaving ? "Saving..." : "Save Item to Catalog",
                    onPressed: isSaving ? null : () async {
                      if (nameController.text.trim().isNotEmpty && priceController.text.trim().isNotEmpty) {
                        setModalState(() => isSaving = true);
                        final price = double.tryParse(priceController.text.trim()) ?? 40.0;
                        final newProduct = ProductModel(
                          id: "P-${DateTime.now().millisecondsSinceEpoch % 1000}",
                          name: nameController.text.trim(),
                          category: selectedCategory,
                          price: price,
                          unit: "Rs. ${price.toInt()} / Kg",
                          imageUrl: imagePath ?? "🥬",
                          inStock: true,
                        );
                        try {
                          await ref.read(inventoryProvider.notifier).addProduct(newProduct);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${newProduct.name} added to catalog!"),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            setModalState(() => isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    icon: isSaving ? Icons.hourglass_empty : Icons.check,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationProvider);
    final productsAsync = ref.watch(filteredInventoryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.value ?? ["Vegetables", "Fruits", "Leafy", "Spices", "Dairy"];

    return Scaffold(
      appBar: CustomAppBar(
        title: tr("Catalog & Stock"),
        showOpenCloseToggle: false,
      ),
      body: Column(
        children: [
          // Header: Search Bar (Items jaldi find karne ke liye)
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => ref.read(inventorySearchProvider.notifier).setQuery(val),
              decoration: InputDecoration(
                hintText: tr("Search vegetable or fruit name..."),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(inventorySearchProvider.notifier).setQuery("");
                        },
                      )
                    : null,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // List Item (Har sabzi/phal ke liye)
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(inventoryProvider.notifier).refresh();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        alignment: Alignment.center,
                        child: Text(tr("No items match your search."), style: AppTextStyles.bodyMedium),
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(inventoryProvider.notifier).refresh();
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return InventoryItemCard(product: products[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text("Error loading products: $err", style: AppTextStyles.bodyMedium),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductModal(categories),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: Text(tr("Add Item"), style: AppTextStyles.buttonText),
      ),
    );
  }
}
