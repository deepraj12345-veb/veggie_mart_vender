import '../models/order_model.dart';
import 'api_client.dart';

class OrderService {
  static final ApiClient _apiClient = ApiClient();

  /// Fetch orders list with pagination
  static Future<List<OrderModel>> fetchOrders({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        '/orders',
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data is Map<String, dynamic>
            ? response.data
            : {};
        final List<dynamic> items = data['data'] ?? [];
        return items.map((e) => OrderModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Update order status
  static Future<void> updateOrderStatus(String orderId, int status) async {
    try {
      String orderStatusStr = "Order Placed";
      switch (status) {
        case 0:
          orderStatusStr = "Order Placed";
          break;
        case 1:
          orderStatusStr = "Order Confirmed";
          break;
        case 2:
          orderStatusStr = "Packing";
          break;
        case 3:
          orderStatusStr = "Delivered";
          break;
      }

      final response = await _apiClient.patch(
        '/orders/$orderId',
        data: {'status': status, 'orderStatus': orderStatusStr},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Assign rider to an order
  static Future<void> assignRider(String orderId, String deliveryBoyId) async {
    try {
      final response = await _apiClient.post(
        '/orders/$orderId/assign',
        data: {'delivery_boy_id': deliveryBoyId},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to assign rider');
      }
    } catch (e) {
      try {
        await _apiClient.patch(
          '/orders/$orderId',
          data: {'delivery_boy_id': deliveryBoyId},
        );
      } catch (_) {
        throw Exception('Failed to assign rider: $e');
      }
    }
  }

  /// Delete order
  static Future<void> deleteOrder(String orderId) async {
    try {
      final response = await _apiClient.delete('/orders/$orderId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete order');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
