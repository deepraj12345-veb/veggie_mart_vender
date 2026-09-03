import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http_pkg;
import 'api_client.dart';

class AuthService {
  static final ApiClient _apiClient = ApiClient();

  /// Vendor Login using NextAuth CSRF and Callback flows
  static Future<void> vendorLogin(String email, String password) async {
    final String rootUrl = ApiClient.rootUrl;

    developer.log('--- VENDOR LOGIN CALLED ---', name: 'AuthService');
    developer.log('Attempting to login for email: $email', name: 'AuthService');

    // Step 1: GET CSRF Token
    developer.log('Step 1: Fetching CSRF token from $rootUrl/api/auth/csrf', name: 'AuthService');
    final csrfResponse = await _apiClient.dio.get('$rootUrl/api/auth/csrf');
    developer.log('CSRF Response Status: ${csrfResponse.statusCode}', name: 'AuthService');

    if (csrfResponse.statusCode != 200 || csrfResponse.data == null) {
      throw Exception('Failed to get CSRF token');
    }

    final Map<String, dynamic> csrfData = csrfResponse.data is String
        ? jsonDecode(csrfResponse.data)
        : csrfResponse.data;
    final String csrfToken = csrfData['csrfToken'];
    developer.log('Extracted CSRF Token: $csrfToken', name: 'AuthService');

    // Save cookies from CSRF response
    final List<String>? setCookieHeaders = csrfResponse.headers['set-cookie'];
    String? cleanedCsrfCookie;
    if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
      final rawCsrfCookie = setCookieHeaders.join('; ');
      final RegExp cookieRegExp = RegExp(r'([^=,\s]+)=([^;]+)');
      final Iterable<Match> matches = cookieRegExp.allMatches(rawCsrfCookie);
      final List<String> cookies = [];
      for (final match in matches) {
        final key = match.group(1)!;
        final value = match.group(2)!;
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

    // Step 2: POST Sign In via http_pkg for raw redirect response parsing
    developer.log('Step 2: Sending credentials to $rootUrl/api/auth/callback/vendor', name: 'AuthService');
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

    developer.log('Login Response Status: $loginResponseStatusCode', name: 'AuthService');

    // Handle NextAuth errors sent via redirect (302/301)
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
      RegExp regExp = RegExp(
        r'((?:__Secure-)?(?:next-auth|authjs)\.session-token)=([^;]+)',
      );
      var match = regExp.firstMatch(rawCookie);
      if (match != null) {
        String cookieName = match.group(1)!;
        String tokenVal = match.group(2)!;

        ApiClient.sessionCookie = '$cookieName=$tokenVal';
        ApiClient.authToken = tokenVal;
        return;
      }
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

  /// Rider Login
  static Future<Map<String, dynamic>> riderLogin(
    String mobileNumber,
    String password,
  ) async {
    final response = await _apiClient.post(
      '/rider/auth/login',
      data: {'mobile_number': mobileNumber, 'password': password},
    );
    if (response.statusCode == 200 && response.data != null) {
      return response.data is String ? jsonDecode(response.data) : response.data;
    }
    throw Exception('Rider login failed');
  }
}
