import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class InventoryNotifier extends AsyncNotifier<List<ProductModel>> {
  @override
  Future<List<ProductModel>> build() async {
    return _fetchProducts();
  }

  Future<List<ProductModel>> _fetchProducts() async {
    try {
      final products = await ApiService.fetchProducts();
      return products;
    } catch (e) {
      print('Error fetching products from API: $e');
      return [];
    }
  }

  // Refresh products from server
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchProducts());
  }

  // Toggle item in-stock / out-of-stock locally and via API
  Future<void> toggleStock(String productId) async {
    if (state.value == null) return;

    final product = state.value!.firstWhere((p) => p.id == productId);
    final newInStock = !product.inStock;

    // Optimistic UI update
    state = AsyncValue.data([
      for (final p in state.value!)
        if (p.id == productId) p.copyWith(inStock: newInStock) else p,
    ]);

    try {
      await ApiService.updateProduct(productId, {
        'stock_status': newInStock ? 1 : 0,
        'inStock': newInStock,
      });
    } catch (e) {
      print('API stock update warning: $e');
    }
  }

  // Update item price locally and via API
  Future<void> updatePrice(String productId, double newPrice) async {
    if (state.value == null) return;

    final product = state.value!.firstWhere((p) => p.id == productId);
    final oldPrice = product.price;

    state = AsyncValue.data([
      for (final p in state.value!)
        if (p.id == productId)
          p.copyWith(price: newPrice, unit: "Rs. ${newPrice.toInt()} / Kg")
        else
          p,
    ]);

    try {
      await ApiService.updateProduct(productId, {'selling_price': newPrice});
    } catch (e) {
      print('Error updating price: $e');
      // Revert
      if (state.value != null) {
        state = AsyncValue.data([
          for (final p in state.value!)
            if (p.id == productId)
              p.copyWith(price: oldPrice, unit: "Rs. ${oldPrice.toInt()} / Kg")
            else
              p,
        ]);
      }
    }
  }

  // Update item details locally and via API
  Future<void> updateProductDetails(
    String productId,
    String newName,
    String newCategory,
    String newImageUrl,
  ) async {
    if (state.value == null) return;

    final product = state.value!.firstWhere((p) => p.id == productId);
    final oldProduct = product;

    state = AsyncValue.data([
      for (final p in state.value!)
        if (p.id == productId)
          p.copyWith(
            name: newName,
            category: newCategory,
            imageUrl: newImageUrl,
          )
        else
          p,
    ]);

    try {
      await ApiService.updateProduct(productId, {
        'product_name': newName,
        'category': newCategory,
        'product_images': newImageUrl,
      });
    } catch (e) {
      print('Error updating product details: $e');
      // Revert
      if (state.value != null) {
        state = AsyncValue.data([
          for (final p in state.value!)
            if (p.id == productId) oldProduct else p,
        ]);
      }
    }
  }

  // Add new grocery product via API
  Future<void> addProduct(ProductModel newProduct) async {
    try {
      final addedProduct = await ApiService.createProduct(newProduct);
      if (state.value != null) {
        state = AsyncValue.data([addedProduct, ...state.value!]);
      }
    } catch (e) {
      print('Error adding product: $e');
      // Fallback to local state update
      if (state.value != null) {
        state = AsyncValue.data([newProduct, ...state.value!]);
      }
    }
  }

  // Remove grocery product locally and via API
  Future<void> removeProduct(String productId) async {
    if (state.value == null) return;

    final productToRemove = state.value!.firstWhere((p) => p.id == productId);

    state = AsyncValue.data(
      state.value!.where((p) => p.id != productId).toList(),
    );

    try {
      await ApiService.deleteProduct(productId);
    } catch (e) {
      print('Error deleting product: $e');
      // Revert
      if (state.value != null) {
        state = AsyncValue.data([...state.value!, productToRemove]);
      }
    }
  }
}

final inventoryProvider =
    AsyncNotifierProvider<InventoryNotifier, List<ProductModel>>(
      InventoryNotifier.new,
    );

// Search query Notifier for instant filtering
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => "";

  void setQuery(String query) => state = query;
}

final inventorySearchProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final filteredInventoryProvider = Provider<AsyncValue<List<ProductModel>>>((
  ref,
) {
  final productsAsync = ref.watch(inventoryProvider);
  final query = ref.watch(inventorySearchProvider).toLowerCase().trim();

  return productsAsync.whenData((products) {
    if (query.isEmpty) return products;
    return products
        .where(
          (p) =>
              p.name.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query),
        )
        .toList();
  });
});

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  try {
    return await ApiService.fetchCategories();
  } catch (e) {
    print('Error fetching categories: $e');
    return []; // Return empty list instead of static dummy categories
  }
});
