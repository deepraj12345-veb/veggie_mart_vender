import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/rider_model.dart';

class ApiService {
  static String? authToken; // Stores the logged-in vendor's token
  static String? sessionCookie; // Stores NextAuth session cookie for web API

  static String get baseUrl {
    // Make sure it ends with /api !
    return 'http://10.212.40.117:3000/api';
  }

  static Map<String, String> _buildHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    if (sessionCookie != null) {
      headers['Cookie'] = sessionCookie!;
    }
    return headers;
  }

  static Future<List<ProductModel>> fetchProducts({String search = ''}) async {
    try {
      final uri = Uri.parse('$baseUrl/vendor-add-products').replace(
        queryParameters: {
          if (search.isNotEmpty) 'search': search,
          'limit':
              '100', // Fetch 100 items by default to avoid pagination for now
        },
      );

      final response = await http
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['data'] ?? [];
        return items.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load products. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vendor-add-products'),
        headers: _buildHeaders(),
        body: json.encode(product.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ProductModel.fromJson(data['data']);
      } else {
        throw Exception(
          'Failed to create product. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/vendor-add-products/$productId'),
        headers: _buildHeaders(),
        body: json.encode(data),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update product');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> deleteProduct(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/vendor-add-products/$productId'),
        headers: _buildHeaders(),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<String>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vendor-categories'),
        headers: _buildHeaders(),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        // Assuming it returns { "data": ["Vegetables", "Fruits", ...] }
        final List<dynamic> items = data['data'] ?? [];
        return items.map((e) => e.toString()).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<OrderModel>> fetchOrders({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      print('--- FETCH ORDERS CALLED ---');
      final uri = Uri.parse('$baseUrl/orders').replace(
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );

      final headers = {'Content-Type': 'application/json'};
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }
      if (sessionCookie != null) {
        headers['Cookie'] = sessionCookie!;
      }

      print('Requesting Orders from: $uri');
      print('Headers being sent: $headers');

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      print('Orders API Response Status: ${response.statusCode}');
      print(
        'Orders API Response Body: ${response.body}',
      ); // Added this line to print the full JSON

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['data'] ?? [];
        print('Orders Fetched Successfully: ${items.length} items');
        return items.map((e) => OrderModel.fromJson(e)).toList();
      } else {
        print('Orders API Error Response: ${response.body}');
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchOrders: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<void> updateOrderStatus(String orderId, int status) async {
    try {
      String orderStatusStr = "Order Placed";
      switch (status) {
        case 0:
          orderStatusStr = "Order Placed";
          break;
        case 1:
          orderStatusStr = "Accepted";
          break;
        case 2:
          orderStatusStr = "Ready";
          break;
        case 3:
          orderStatusStr = "Completed";
          break;
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: _buildHeaders(),
        body: json.encode({'status': status, 'orderStatus': orderStatusStr}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update order status');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> assignRider(String orderId, String deliveryBoyId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: _buildHeaders(),
        body: json.encode({'delivery_boy_id': deliveryBoyId}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to assign rider');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> deleteOrder(String orderId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/orders/$orderId'));
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete order');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ==========================================
  // PART 0: Vendor Authentication
  // ==========================================

  static Future<void> vendorLogin(String email, String password) async {
    // Automatically get the root URL by removing '/api' from baseUrl
    final String rootUrl = baseUrl.replaceAll('/api', '');

    print('--- VENDOR LOGIN CALLED ---');
    print('Attempting to login for email: $email');

    // Step 1: GET CSRF Token
    print('Step 1: Fetching CSRF token from $rootUrl/api/auth/csrf');
    final csrfResponse = await http.get(Uri.parse('$rootUrl/api/auth/csrf'));
    print('CSRF Response Status: ${csrfResponse.statusCode}');

    if (csrfResponse.statusCode != 200) {
      print('CSRF Fetch Failed: ${csrfResponse.body}');
      throw Exception('Failed to get CSRF token');
    }

    final Map<String, dynamic> csrfData = jsonDecode(csrfResponse.body);
    final String csrfToken = csrfData['csrfToken'];
    print('Extracted CSRF Token: $csrfToken');

    // Save cookies from CSRF response (needed for csrf verification)
    String? csrfCookieHeader = csrfResponse.headers['set-cookie'];
    print('Extracted CSRF Set-Cookie: $csrfCookieHeader');

    // Step 2: POST Sign In
    print('Step 2: Sending credentials to $rootUrl/api/auth/callback/vendor');
    final loginResponse = await http.post(
      Uri.parse('$rootUrl/api/auth/callback/vendor'),
      headers: {
        'Content-Type': 'application/json',
        if (csrfCookieHeader != null) 'Cookie': csrfCookieHeader,
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'csrfToken': csrfToken,
        'json': true,
      }),
    );

    print('Login Response Status: ${loginResponse.statusCode}');
    print('Login Response Headers: ${loginResponse.headers}');

    // Step 3: Extract and save session token
    String? rawCookie = loginResponse.headers['set-cookie'];
    if (rawCookie != null) {
      // Look for either the __Secure- version (Vercel) or the normal version (Localhost)
      RegExp regExp = RegExp(
        r'((?:__Secure-)?next-auth\.session-token)=([^;]+)',
      );
      var match = regExp.firstMatch(rawCookie);
      if (match != null) {
        String cookieName = match.group(1)!;
        String tokenVal = match.group(2)!;

        sessionCookie = '$cookieName=$tokenVal';
        authToken =
            tokenVal; // Also store in authToken for shared_prefs compatibility

        print('SUCCESS: Session cookie captured and saved!');
        print('Session Cookie: $sessionCookie');
        return;
      } else {
        print(
          'ERROR: Set-Cookie found, but next-auth.session-token is missing.',
        );
      }
    } else {
      print('ERROR: No set-cookie header returned by backend.');
    }

    throw Exception(
      'Login failed: Invalid credentials or session token not found.',
    );
  }

  // ==========================================
  // PART 1: Admin APIs (Managing Delivery Boys)
  // ==========================================

  static Future<List<RiderModel>> fetchRiders({
    int page = 1,
    int limit = 50,
    String search = '',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/delivery-boys').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (search.isNotEmpty) 'search': search,
        },
      );
      final response = await http
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['data'] ?? [];
        return items.map((e) => RiderModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load riders');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<RiderModel> addRider(RiderModel rider, String password) async {
    try {
      print('Adding rider: ${rider.toJson()}');
      final response = await http.post(
        Uri.parse('$baseUrl/delivery-boys'),
        headers: _buildHeaders(),
        body: json.encode({...rider.toJson(), 'password': password}),
      );
      print('Add Rider API Status: ${response.statusCode}');
      print('Add Rider API Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return RiderModel.fromJson(data['data'] ?? data);
      } else {
        throw Exception(
          'Failed to add rider. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> updateRiderStatus(String riderId, String isActive) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/delivery-boys/$riderId'),
        headers: _buildHeaders(),
        body: json.encode({'is_active': isActive}),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update rider status');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<void> deleteRider(String riderId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delivery-boys/$riderId'),
        headers: _buildHeaders(),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete rider');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ==========================================
  // PART 2: Rider App APIs (For Mobile App)
  // ==========================================
  // (Adding these to keep API service centralized, even if used in a separate app)

  static Future<Map<String, dynamic>> riderLogin(
    String mobileNumber,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rider/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'mobile_number': mobileNumber, 'password': password}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Login failed');
  }

  static Future<void> riderUpdateLocation(
    String token,
    String lat,
    String long,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/rider/profile/location'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'current_lat': lat, 'current_long': long}),
    );
    if (response.statusCode != 200)
      throw Exception('Failed to update location');
  }
}
