import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_text_styles.dart';
import '../../models/product_model.dart';
import '../../providers/inventory_provider.dart';
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

  void _showAddProductModal() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String selectedCategory = "Vegetables";
    String emoji = "🥬";

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
                          items: ["Vegetables", "Fruits", "Leafy", "Spices", "Dairy"]
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
                    label: "Save Item to Catalog",
                    onPressed: () {
                      if (nameController.text.trim().isNotEmpty && priceController.text.trim().isNotEmpty) {
                        final price = double.tryParse(priceController.text.trim()) ?? 40.0;
                        final newProduct = ProductModel(
                          id: "P-${DateTime.now().millisecondsSinceEpoch % 1000}",
                          name: nameController.text.trim(),
                          category: selectedCategory,
                          price: price,
                          unit: "Rs. ${price.toInt()} / Kg",
                          imageUrl: emoji,
                          inStock: true,
                        );
                        ref.read(inventoryProvider.notifier).addProduct(newProduct);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${newProduct.name} added to catalog!"),
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

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(filteredInventoryProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: "Catalog & Stock",
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
                hintText: "Search vegetable or fruit name...",
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
            child: products.isEmpty
                ? Center(
                    child: Text("No items match your search.", style: AppTextStyles.bodyMedium),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return InventoryItemCard(product: products[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductModal,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: Text("Add Item", style: AppTextStyles.buttonText),
      ),
    );
  }
}
