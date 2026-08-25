import 'dart:convert';
import 'package:http/http.dart' as http_pkg;
import 'package:pretty_http_logger/pretty_http_logger.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/rider_model.dart';

class ColorfulHttpLogger implements MiddlewareContract {
  @override
  void interceptRequest(RequestData data) {
    // Cyan color for Request
    print('\x1B[36m╔╣ Request ║ ${data.method.toString().split('.').last}');
    print('║  ${data.url}');
    final headers = ApiService._buildHeaders();
    if (headers.isNotEmpty) {
      print('║  Headers:');
      headers.forEach((key, value) {
        print('║    $key: $value');
      });
    }
    print(
      '╚══════════════════════════════════════════════════════════════════════════════════════════╝\x1B[0m',
    );
  }

  @override
  void interceptResponse(ResponseData data) {
    // Green for success, Red for error
    final bool isSuccess = data.statusCode >= 200 && data.statusCode < 300;
    final String color = isSuccess ? '\x1B[32m' : '\x1B[31m';

    print('$color╔╣ Response ║ Status: ${data.statusCode}');
    print('║  ${data.url}');
    print(
      '╚══════════════════════════════════════════════════════════════════════════════════════════╝',
    );
    print('╔ Body');
    try {
      final jsonBody = json.decode(data.body);
      final prettyString = const JsonEncoder.withIndent('  ').convert(jsonBody);
      final lines = prettyString.split('\n');
      for (var line in lines) {
        print('║ $line');
      }
    } catch (_) {
      print('║ ${data.body}');
    }
    print(
      '╚══════════════════════════════════════════════════════════════════════════════════════════╝\x1B[0m',
    );
  }

  @override
  void interceptError(dynamic err) {
    print('\x1B[31m╔╣ Error ║ $err');
    print(
      '╚══════════════════════════════════════════════════════════════════════════════════════════╝\x1B[0m',
    );
  }
}

class ApiService {
  static final httpClient = HttpWithMiddleware.build(
    middlewares: [ColorfulHttpLogger()],
  );

  static String? authToken; // Stores the logged-in vendor's token
  static String? sessionCookie; // Stores NextAuth session cookie for web API

  static String get baseUrl {
    return 'https://vegimart-backend.vercel.app/api/v1';
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

      final response = await httpClient
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
      final response = await httpClient.post(
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
      final response = await httpClient.patch(
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
      final response = await httpClient.delete(
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
      final response = await httpClient.get(
        Uri.parse('$baseUrl/vendor-categories'),
        headers: _buildHeaders(),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
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

      final response = await httpClient
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

      final response = await httpClient.patch(
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
      final response = await httpClient.patch(
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
      final response = await httpClient.delete(
        Uri.parse('$baseUrl/orders/$orderId'),
      );
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
    final csrfResponse = await httpClient.get(
      Uri.parse('$rootUrl/api/auth/csrf'),
    );
    print('CSRF Response Status: ${csrfResponse.statusCode}');

    if (csrfResponse.statusCode != 200) {
      print('CSRF Fetch Failed: ${csrfResponse.body}');
      throw Exception('Failed to get CSRF token');
    }

    final Map<String, dynamic> csrfData = jsonDecode(csrfResponse.body);
    final String csrfToken = csrfData['csrfToken'];
    print('Extracted CSRF Token: $csrfToken');

    // Save cookies from CSRF response (needed for csrf verification)
    String? rawCsrfCookie = csrfResponse.headers['set-cookie'];
    String? cleanedCsrfCookie;
    if (rawCsrfCookie != null) {
      final RegExp cookieRegExp = RegExp(r'([^=,\s]+)=([^;]+)');
      final Iterable<Match> matches = cookieRegExp.allMatches(rawCsrfCookie);
      final List<String> cookies = [];
      for (final match in matches) {
        final key = match.group(1)!;
        final value = match.group(2)!;
        // Ignore standard cookie attributes
        if (![
          'Path',
          'Expires',
          'Max-Age',
          'Domain',
          'SameSite',
          'HttpOnly',
          'Secure',
        ].contains(key)) {
          cookies.add('$key=$value');
        }
      }
      cleanedCsrfCookie = cookies.join('; ');
    }
    print('Cleaned CSRF Cookie: $cleanedCsrfCookie');

    // Step 2: POST Sign In
    print('Step 2: Sending credentials to $rootUrl/api/auth/callback/vendor');
    final client = http_pkg.Client();
    final request =
        http_pkg.Request('POST', Uri.parse('$rootUrl/api/auth/callback/vendor'))
          ..followRedirects = false
          ..headers['Content-Type'] = 'application/json';

    if (cleanedCsrfCookie != null) {
      request.headers['Cookie'] = cleanedCsrfCookie;
    }

    request.body = jsonEncode({
      'email': email,
      'password': password,
      'csrfToken': csrfToken,
      'json': true,
    });

    final streamResponse = await client.send(request);
    final responseBody = await streamResponse.stream.bytesToString();
    final loginResponseStatusCode = streamResponse.statusCode;
    final loginResponseHeaders = streamResponse.headers;
    client.close();

    print('Login Response Status: $loginResponseStatusCode');
    print('Login Response Headers: $loginResponseHeaders');
    print('Login Response Body: $responseBody');

    // Handle NextAuth errors sent via redirect (302)
    if (loginResponseStatusCode == 302 || loginResponseStatusCode == 301) {
      final location = loginResponseHeaders['location'];
      if (location != null && location.contains('error=')) {
        final uri = Uri.parse(location);
        final error = uri.queryParameters['error'];
        throw Exception('Backend Error: $error');
      }
    }

    // Step 3: Extract and save session token
    String? rawCookie = loginResponseHeaders['set-cookie'];
    if (rawCookie != null) {
      // Look for either next-auth.session-token or authjs.session-token
      RegExp regExp = RegExp(
        r'((?:__Secure-)?(?:next-auth|authjs)\.session-token)=([^;]+)',
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
        print('ERROR: Set-Cookie found, but session-token is missing.');
      }
    } else {
      print('ERROR: No set-cookie header returned by backend.');
    }

    String errorMsg = 'Invalid credentials or session token not found.';
    try {
      final loginData = jsonDecode(responseBody);
      if (loginData['error'] != null) {
        errorMsg = loginData['error'];
      }
    } catch (_) {}

    throw Exception('Login failed: $errorMsg');
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
      print('\x1B[33m--- FETCH RIDERS CALLED ---\x1B[0m');
      final uri = Uri.parse('$baseUrl/delivery-boys').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (search.isNotEmpty) 'search': search,
        },
      );
      print('Requesting Riders from: $uri');
      
      final response = await httpClient
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 15));
          
      print('Riders API Response Status: ${response.statusCode}');
      print('Riders API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['data'] ?? [];
        print('\x1B[32mRiders Fetched Successfully: ${items.length} items\x1B[0m');
        return items.map((e) => RiderModel.fromJson(e)).toList();
      } else {
        throw Exception(
          'Failed to load riders: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<RiderModel> addRider(RiderModel rider, String password) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/delivery-boys'),
        headers: _buildHeaders(),
        body: json.encode({...rider.toJson(), 'password': password}),
      );

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
      final response = await httpClient.patch(
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
      final response = await httpClient.delete(
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
    final response = await httpClient.post(
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
    final response = await httpClient.patch(
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
