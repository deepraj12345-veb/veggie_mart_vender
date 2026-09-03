import '../models/product_model.dart';
import 'api_client.dart';

class ProductService {
  static final ApiClient _apiClient = ApiClient();

  /// Fetch list of products with optional pagination and search query
  static Future<List<ProductModel>> fetchProducts({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    try {
      final response = await _apiClient.get(
        '/products',
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (search.isNotEmpty) 'search': search,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is Map<String, dynamic>
            ? response.data
            : {};
        final List<dynamic> items = data['data'] ?? [];
        return items.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Create a new product
  static Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final response = await _apiClient.post(
        '/products',
        data: product.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = response.data is Map<String, dynamic>
            ? response.data
            : {};
        return ProductModel.fromJson(data['data']);
      } else {
        throw Exception('Failed to create product. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Update an existing product
  static Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.patch(
        '/products/$productId',
        data: data,
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update product. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Delete a product by ID
  static Future<void> deleteProduct(String productId) async {
    try {
      final response = await _apiClient.delete('/products/$productId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch all product categories
  static Future<List<String>> fetchCategories() async {
    try {
      final response = await _apiClient.get('/categories');
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is Map<String, dynamic>
            ? response.data
            : {};
        final List<dynamic> items = data['data'] ?? [];
        return items.map((e) {
          if (e is Map) {
            return (e['category_name'] ?? e['name'] ?? e.toString()).toString();
          }
          return e.toString();
        }).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
