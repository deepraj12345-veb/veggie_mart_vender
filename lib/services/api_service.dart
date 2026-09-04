import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/rider_model.dart';

class ApiService {
  static String? authToken;
  static String? sessionCookie;
  static String? currentVendorId;
  static String? currentVendorEmail;
  static String? vendorName;
  static String? vendorPhone;
  static String? storeName;
  static String? storeAddress;
  static String city = '';
  static String stateName = '';
  static double walletBalance = 0.0;
  static bool isVerified = true;
  static String createdAt = '';

  static String get rootUrl => ApiClient.rootUrl;
  static String get baseUrl => '$rootUrl/api/v1';
  static String get vendorBaseUrl => '$rootUrl/api/vendor';

  static Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (authToken != null && authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    if (sessionCookie != null && sessionCookie!.isNotEmpty) {
      headers['Cookie'] = sessionCookie!;
    }
    return headers;
  }

  static Future<void> clearAllVendorData() async {
    authToken = null;
    sessionCookie = null;
    currentVendorId = null;
    currentVendorEmail = null;
    vendorName = null;
    vendorPhone = null;
    storeName = null;
    storeAddress = null;
    city = '';
    stateName = '';
    walletBalance = 0.0;
    isVerified = true;
    createdAt = '';

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
  }

  static void parseAndSaveVendorData(Map<String, dynamic> vendorObj) {
    if (vendorObj.containsKey('_id') || vendorObj.containsKey('id')) {
      currentVendorId = (vendorObj['id'] ?? vendorObj['_id']).toString();
    }

    final fn = vendorObj['full_name']?.toString() ?? vendorObj['proprietor_name']?.toString() ?? vendorObj['name']?.toString();
    if (fn != null && fn.isNotEmpty) {
      vendorName = fn;
    } else if (vendorObj['shop_name'] != null && vendorObj['shop_name'].toString().isNotEmpty) {
      vendorName = vendorObj['shop_name'].toString();
    }

    if (vendorObj['email'] != null && vendorObj['email'].toString().isNotEmpty) {
      currentVendorEmail = vendorObj['email'].toString();
    }

    final ph = vendorObj['mobile_number']?.toString() ?? vendorObj['mobile_no']?.toString() ?? vendorObj['phone']?.toString();
    if (ph != null && ph.isNotEmpty) {
      vendorPhone = ph;
    }

    final sn = vendorObj['shop_name']?.toString() ?? vendorObj['store_name']?.toString();
    if (sn != null && sn.isNotEmpty) {
      storeName = sn;
    }

    city = vendorObj['city']?.toString() ?? '';
    stateName = vendorObj['state']?.toString() ?? '';

    final addr = vendorObj['address']?.toString() ?? '';
    if (addr.isNotEmpty) {
      storeAddress = addr;
    } else if (city.isNotEmpty || stateName.isNotEmpty) {
      storeAddress = [city, stateName].where((s) => s.isNotEmpty).join(', ');
    }

    if (vendorObj['wallet_balance'] != null) {
      walletBalance = double.tryParse(vendorObj['wallet_balance'].toString()) ?? 0.0;
    }

    if (vendorObj['is_verified'] != null) {
      isVerified = vendorObj['is_verified'].toString() == '1' || vendorObj['is_verified'] == true;
    }

    if (vendorObj['created_at'] != null || vendorObj['createdAt'] != null) {
      createdAt = (vendorObj['created_at'] ?? vendorObj['createdAt']).toString();
    }
  }

  static Future<void> saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (vendorName != null) await prefs.setString('vendorName', vendorName!);
      if (vendorPhone != null) await prefs.setString('vendorPhone', vendorPhone!);
      if (storeName != null) await prefs.setString('storeName', storeName!);
      if (storeAddress != null) await prefs.setString('storeAddress', storeAddress!);
      if (currentVendorEmail != null) await prefs.setString('currentVendorEmail', currentVendorEmail!);
      if (currentVendorId != null) await prefs.setString('currentVendorId', currentVendorId!);
      if (city.isNotEmpty) await prefs.setString('vendorCity', city);
      if (stateName.isNotEmpty) await prefs.setString('vendorState', stateName);
      await prefs.setDouble('vendorWallet', walletBalance);
      await prefs.setBool('vendorIsVerified', isVerified);
      if (createdAt.isNotEmpty) await prefs.setString('vendorCreatedAt', createdAt);
    } catch (_) {}
  }

  static Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      vendorName = prefs.getString('vendorName') ?? vendorName;
      vendorPhone = prefs.getString('vendorPhone') ?? vendorPhone;
      storeName = prefs.getString('storeName') ?? storeName;
      storeAddress = prefs.getString('storeAddress') ?? storeAddress;
      currentVendorEmail = prefs.getString('currentVendorEmail') ?? currentVendorEmail;
      currentVendorId = prefs.getString('currentVendorId') ?? currentVendorId;
      city = prefs.getString('vendorCity') ?? city;
      stateName = prefs.getString('vendorState') ?? stateName;
      walletBalance = prefs.getDouble('vendorWallet') ?? walletBalance;
      isVerified = prefs.getBool('vendorIsVerified') ?? isVerified;
      createdAt = prefs.getString('vendorCreatedAt') ?? createdAt;
    } catch (_) {}
  }

  static Future<Map<String, dynamic>> fetchVendorProfile() async {
    await loadFromPrefs();
    final profileEndpoints = [
      if (currentVendorEmail != null && currentVendorEmail!.isNotEmpty) '$baseUrl/vendor?vendor_id=$currentVendorEmail',
      if (currentVendorId != null && currentVendorId!.isNotEmpty && !currentVendorId!.startsWith('VENDOR_')) '$baseUrl/vendor?vendor_id=$currentVendorId',
      '$baseUrl/vendor',
      '$rootUrl/api/vendor',
    ];

    for (final url in profileEndpoints) {
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: _buildHeaders(),
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final Map<String, dynamic> body = jsonDecode(response.body);
          final vendorObj = body['data'] ?? body['vendor'] ?? body;
          if (vendorObj is Map<String, dynamic> && vendorObj.isNotEmpty) {
            parseAndSaveVendorData(vendorObj);
            await saveToPrefs();
            print('SUCCESS: Real Vendor Profile fetched from $url -> Name: $vendorName, Shop: $storeName, Phone: $vendorPhone, Address: $storeAddress');
            return vendorObj;
          }
        }
      } catch (e) {
        print('fetchVendorProfile attempt to $url skipped: $e');
      }
    }
    return {};
  }

  // --------------------------------------------------------------
  // 1. VENDOR LOGIN (POST)
  // --------------------------------------------------------------
  static final Map<String, List<ProductModel>> _vendorProductsMap = {};

  static Future<void> vendorLogin(String email, String password) async {
    print('--- 1. VENDOR LOGIN CALL ---');
    final String rawEmail = email.trim().toLowerCase();
    
    // Clear old vendor data to ensure clean login for new account
    await clearAllVendorData();
    currentVendorEmail = rawEmail;

    final loginEndpoints = [
      '$baseUrl/auth/login',
      '$rootUrl/vendor/login',
      '$vendorBaseUrl/login',
      '$baseUrl/login',
    ];

    String? serverErrorMessage;

    for (final url in loginEndpoints) {
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode({
            'email': rawEmail,
            'password': password,
          }),
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final token = data['token'] ?? data['accessToken'] ?? data['data']?['token'] ?? data['sessionToken'];
          if (token != null) {
            authToken = token.toString();
            sessionCookie = 'authjs.session-token=$token';
            print('SUCCESS: Vendor Login Token received from $url');
          }
          final vendorObj = data['vendor'] ?? data['user'] ?? data['data'];
          if (vendorObj is Map<String, dynamic>) {
            parseAndSaveVendorData(vendorObj);
            await saveToPrefs();
          }
          await fetchVendorProfile();
          return;
        } else {
          try {
            final Map<String, dynamic> errData = jsonDecode(response.body);
            final msg = errData['error'] ?? errData['message'];
            if (msg != null && msg.toString().isNotEmpty) {
              serverErrorMessage = msg.toString();
            }
          } catch (_) {}
        }
      } catch (e) {
        print('Login attempt to $url skipped/CORS: $e');
      }
    }

    // STRICT: DO NOT ALLOW FAKE/DUMMY LOGIN FALLBACK!
    if (serverErrorMessage != null && serverErrorMessage.isNotEmpty) {
      throw Exception(serverErrorMessage);
    } else {
      throw Exception('Invalid email or password. Please check credentials.');
    }
  }

  // --------------------------------------------------------------
  // 2. VENDOR DASHBOARD (GET https://vegimart-backend.vercel.app/vendor/dashboard)
  // --------------------------------------------------------------
  static Future<Map<String, dynamic>> fetchVendorDashboard() async {
    await loadFromPrefs();
    final Map<String, String> queryParams = {};
    if (currentVendorEmail != null && currentVendorEmail!.isNotEmpty) {
      queryParams['vendor_id'] = currentVendorEmail!;
    } else if (currentVendorId != null && currentVendorId!.isNotEmpty) {
      queryParams['vendor_id'] = currentVendorId!;
    }

    final dashboardUrls = [
      Uri.parse('$baseUrl/vendor/dashboard').replace(queryParameters: queryParams).toString(),
      Uri.parse('$rootUrl/vendor/dashboard').replace(queryParameters: queryParams).toString(),
      Uri.parse('$vendorBaseUrl/dashboard').replace(queryParameters: queryParams).toString(),
    ];

    for (final url in dashboardUrls) {
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: _buildHeaders(),
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final Map<String, dynamic> innerData = data['data'] ?? data;
          if (innerData['vendor'] != null && innerData['vendor'] is Map<String, dynamic>) {
            parseAndSaveVendorData(innerData['vendor']);
            await saveToPrefs();
          }
          print('SUCCESS: Vendor Dashboard fetched from $url');
          return data;
        }
      } catch (e) {
        print('Vendor Dashboard attempt to $url skipped: $e');
      }
    }

    final vendorProds = await fetchProducts();
    final orders = await fetchOrders();
    return {
      'totalOrders': orders.length,
      'totalProducts': vendorProds.length,
      'revenue': walletBalance,
    };
  }

  // --------------------------------------------------------------
  // 3. VENDOR APIs (GET https://vegimart-backend.vercel.app/api/vendor)
  // --------------------------------------------------------------
  static Future<Map<String, dynamic>> fetchVendorApiData() async {
    try {
      final response = await http.get(
        Uri.parse(vendorBaseUrl),
        headers: _buildHeaders(),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('SUCCESS: Vendor API Data fetched from $vendorBaseUrl');
        return data;
      }
    } catch (e) {
      print('fetchVendorApiData skipped: $e');
    }
    return {};
  }

  // --------------------------------------------------------------
  // 4. CUSTOMER / MOBILE APP APIs (GET https://vegimart-backend.vercel.app/api/v1)
  // --------------------------------------------------------------
  static Future<List<ProductModel>> fetchProducts({String search = ''}) async {
    await loadFromPrefs();
    final Map<String, String> queryParams = {
      if (search.isNotEmpty) 'search': search,
      'limit': '100',
    };
    if (currentVendorEmail != null && currentVendorEmail!.isNotEmpty) {
      queryParams['vendor_id'] = currentVendorEmail!;
    } else if (currentVendorId != null && currentVendorId!.isNotEmpty) {
      queryParams['vendor_id'] = currentVendorId!;
    }

    final basePaths = [baseUrl, vendorBaseUrl];
    for (final basePath in basePaths) {
      try {
        final uri = Uri.parse('$basePath/products').replace(
          queryParameters: queryParams,
        );

        final response = await http.get(uri, headers: _buildHeaders()).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final List<dynamic> items = data['data'] ?? (data is List ? data : []);
          final allProducts = items.map((json) => ProductModel.fromJson(json)).toList();
          return allProducts;
        }
      } catch (e) {
        print('fetchProducts attempt to $basePath/products skipped: $e');
      }
    }

    return [];
  }

  static Future<ProductModel> createProduct(ProductModel product) async {
    final emailKey = currentVendorEmail ?? 'default';
    final productWithVendor = product.copyWith(
      id: product.id.isEmpty ? 'P-${DateTime.now().millisecondsSinceEpoch}' : product.id,
      vendorId: currentVendorId,
      vendorShopName: storeName ?? vendorName,
    );

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: _buildHeaders(),
        body: json.encode(productWithVendor.toJson()),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final created = ProductModel.fromJson(data['data'] ?? data);
        _vendorProductsMap.putIfAbsent(emailKey, () => []).add(created);
        return created;
      }
    } catch (e) {
      print('createProduct API error: $e');
    }

    _vendorProductsMap.putIfAbsent(emailKey, () => []).add(productWithVendor);
    return productWithVendor;
  }

  static Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      await http.patch(
        Uri.parse('$baseUrl/products/$productId'),
        headers: _buildHeaders(),
        body: json.encode(data),
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      print('updateProduct API error: $e');
    }
  }

  static Future<void> deleteProduct(String productId) async {
    try {
      await http.delete(
        Uri.parse('$baseUrl/products/$productId'),
        headers: _buildHeaders(),
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      print('deleteProduct API error: $e');
    }
  }

  static Future<List<String>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: _buildHeaders(),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['data'] ?? [];
        return items.map((e) => (e is Map ? (e['name'] ?? e['category_name']) : e).toString()).toList();
      }
    } catch (e) {
      print('fetchCategories API error: $e');
    }
    return ['Vegetables', 'Fruits', 'Exotic', 'Herbs & Seasoning'];
  }

  static Future<List<OrderModel>> fetchOrders({int page = 1, int limit = 50}) async {
    await loadFromPrefs();
    try {
      final Map<String, String> queryParams = {};
      if (currentVendorEmail != null && currentVendorEmail!.isNotEmpty) {
        queryParams['vendor_id'] = currentVendorEmail!;
      } else if (currentVendorId != null && currentVendorId!.isNotEmpty) {
        queryParams['vendor_id'] = currentVendorId!;
      }

      final uri = Uri.parse('$baseUrl/orders').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: _buildHeaders(),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['data'] ?? [];
        return items.map((e) => OrderModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('fetchOrders API error: $e');
    }
    return [];
  }

  static Future<void> updateOrderStatus(String orderId, int status) async {
    try {
      await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: _buildHeaders(),
        body: json.encode({'status': status}),
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      print('updateOrderStatus API error: $e');
    }
  }

  static Future<void> deleteOrder(String orderId) async {
    try {
      await http.delete(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: _buildHeaders(),
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      print('deleteOrder API error: $e');
    }
  }

  static Future<List<RiderModel>> fetchRiders({int page = 1, int limit = 50, String search = ''}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/delivery-boys'),
        headers: _buildHeaders(),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['data'] ?? [];
        return items.map((e) => RiderModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('fetchRiders API error: $e');
    }
    return _fallbackRiders;
  }

  static Future<RiderModel> addRider(RiderModel rider, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delivery-boys'),
        headers: _buildHeaders(),
        body: json.encode({...rider.toJson(), 'password': password}),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return RiderModel.fromJson(data['data'] ?? data);
      }
    } catch (e) {
      print('addRider API error: $e');
    }
    _fallbackRiders.add(rider);
    return rider;
  }

  static Future<void> updateRiderStatus(String riderId, String isActive) async {
    try {
      await http.patch(
        Uri.parse('$baseUrl/delivery-boys/$riderId'),
        headers: _buildHeaders(),
        body: json.encode({'is_active': isActive}),
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      print('updateRiderStatus API error: $e');
    }
  }

  static Future<void> deleteRider(String riderId) async {
    try {
      await http.delete(
        Uri.parse('$baseUrl/delivery-boys/$riderId'),
        headers: _buildHeaders(),
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      print('deleteRider API error: $e');
    }
  }

  static Future<void> assignRider(String orderId, String riderId) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/orders/$orderId/assign'),
        headers: _buildHeaders(),
        body: json.encode({'rider_id': riderId}),
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      print('assignRider API error: $e');
    }
  }

  static final List<ProductModel> _fallbackProducts = [
    const ProductModel(
      id: 'P-101',
      name: 'Fresh Tamatar (Tomato)',
      category: 'Vegetables',
      price: 40.0,
      unit: '1 Kg',
      imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400',
      inStock: true,
    ),
    const ProductModel(
      id: 'P-102',
      name: 'Desi Gajar (Carrot)',
      category: 'Vegetables',
      price: 50.0,
      unit: '1 Kg',
      imageUrl: 'https://images.unsplash.com/photo-1598170845058-12ef4a457939?w=400',
      inStock: true,
    ),
  ];

  static final List<OrderModel> _fallbackOrders = [
    const OrderModel(
      id: '#ORD-1001',
      customerName: 'Rahul Sharma',
      customerPhone: '+91 9876543210',
      dateTime: '10 mins ago',
      items: [
        OrderItem(name: 'Fresh Tamatar (Tomato)', quantity: '2 Kg', price: 80.0),
      ],
      totalAmount: 80.0,
      status: OrderStatus.newOrder,
      otp: '4219',
    ),
  ];

  static final List<RiderModel> _fallbackRiders = [
    RiderModel(
      id: 'R-1',
      name: 'Amit Kumar',
      mobileNumber: '+91 9812345678',
      vehicleType: 'Bike',
      vehicleNumber: 'DL 01 AB 1234',
      isActive: '1',
    ),
  ];
}
