import '../models/rider_model.dart';
import 'api_client.dart';

class RiderService {
  static final ApiClient _apiClient = ApiClient();

  /// Fetch list of riders (delivery boys)
  static Future<List<RiderModel>> fetchRiders({
    int page = 1,
    int limit = 50,
    String search = '',
  }) async {
    try {
      final response = await _apiClient.get(
        '/delivery-boys',
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
        return items.map((e) => RiderModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load riders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Add a new rider
  static Future<RiderModel> addRider(RiderModel rider, String password) async {
    try {
      final response = await _apiClient.post(
        '/delivery-boys',
        data: {...rider.toJson(), 'password': password},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = response.data is Map<String, dynamic>
            ? response.data
            : {};
        return RiderModel.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to add rider. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Update rider active status
  static Future<void> updateRiderStatus(String riderId, String isActive) async {
    try {
      final response = await _apiClient.patch(
        '/delivery-boys/$riderId',
        data: {'is_active': isActive},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update rider status');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Delete a rider
  static Future<void> deleteRider(String riderId) async {
    try {
      final response = await _apiClient.delete('/delivery-boys/$riderId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete rider');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Update rider location (used by rider app)
  static Future<void> riderUpdateLocation(
    String token,
    String lat,
    String long,
  ) async {
    final response = await _apiClient.patch(
      '/rider/profile/location',
      data: {'current_lat': lat, 'current_long': long},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update location');
    }
  }
}
