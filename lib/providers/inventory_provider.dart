import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';

class InventoryNotifier extends Notifier<List<ProductModel>> {
  @override
  List<ProductModel> build() => _initialProducts;

  // Toggle item in-stock / out-of-stock
  void toggleStock(String productId) {
    state = [
      for (final product in state)
        if (product.id == productId)
          product.copyWith(inStock: !product.inStock)
        else
          product
    ];
  }

  // Update item price (editable price feature)
  void updatePrice(String productId, double newPrice) {
    state = [
      for (final product in state)
        if (product.id == productId)
          product.copyWith(price: newPrice, unit: "Rs. ${newPrice.toInt()} / Kg")
        else
          product
    ];
  }

  // Add new grocery product
  void addProduct(ProductModel newProduct) {
    state = [newProduct, ...state];
  }

  // Remove grocery product
  void removeProduct(String productId) {
    state = state.where((p) => p.id != productId).toList();
  }
}

final inventoryProvider = NotifierProvider<InventoryNotifier, List<ProductModel>>(InventoryNotifier.new);

// Search query Notifier for instant filtering in Screen 4
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => "";

  void setQuery(String query) => state = query;
}

final inventorySearchProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final filteredInventoryProvider = Provider<List<ProductModel>>((ref) {
  final products = ref.watch(inventoryProvider);
  final query = ref.watch(inventorySearchProvider).toLowerCase().trim();

  if (query.isEmpty) return products;

  return products.where((p) =>
    p.name.toLowerCase().contains(query) ||
    p.category.toLowerCase().contains(query)
  ).toList();
});

final List<ProductModel> _initialProducts = [
  const ProductModel(
    id: "P1",
    name: "Fresh Tamatar (Tomato)",
    category: "Vegetables",
    price: 40.0,
    unit: "Rs. 40 / Kg",
    imageUrl: "🍅",
    inStock: true,
  ),
  const ProductModel(
    id: "P2",
    name: "Lal Pyaz (Red Onion)",
    category: "Vegetables",
    price: 35.0,
    unit: "Rs. 35 / Kg",
    imageUrl: "🧅",
    inStock: true,
  ),
  const ProductModel(
    id: "P3",
    name: "Pahadi Aloo (Potato)",
    category: "Vegetables",
    price: 30.0,
    unit: "Rs. 30 / Kg",
    imageUrl: "🥔",
    inStock: true,
  ),
  const ProductModel(
    id: "P4",
    name: "Hari Mirch (Green Chilli)",
    category: "Spices",
    price: 80.0,
    unit: "Rs. 80 / Kg",
    imageUrl: "🌶️",
    inStock: true,
  ),
  const ProductModel(
    id: "P5",
    name: "Hara Dhania (Coriander)",
    category: "Leafy",
    price: 20.0,
    unit: "Rs. 20 / Bunch",
    imageUrl: "🌿",
    inStock: false,
  ),
  const ProductModel(
    id: "P6",
    name: "Robusta Banana (Kela)",
    category: "Fruits",
    price: 50.0,
    unit: "Rs. 50 / Dozen",
    imageUrl: "🍌",
    inStock: true,
  ),
  const ProductModel(
    id: "P7",
    name: "Amul Masti Curd",
    category: "Dairy",
    price: 35.0,
    unit: "Rs. 35 / Pouch",
    imageUrl: "🥛",
    inStock: true,
  ),
];
