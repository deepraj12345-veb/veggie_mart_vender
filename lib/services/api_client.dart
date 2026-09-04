import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

enum ApiEnvironment { local, production }

/// Production-ready API Client built with Dio with Rich Colored Logger
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;

  static String get localBaseUrl => 'http://localhost:3000/api/v1';

  static const String prodBaseUrl = 'http://localhost:3000/api/v1';

  /// Easily switch between [ApiEnvironment.local] and [ApiEnvironment.production]
  static ApiEnvironment environment = ApiEnvironment.local;

  static String? _customBaseUrl;

  static String get baseUrl {
    if (_customBaseUrl != null) return _customBaseUrl!;
    return environment == ApiEnvironment.local ? localBaseUrl : prodBaseUrl;
  }

  static set baseUrl(String value) {
    _customBaseUrl = value;
  }

  static String? authToken;
  static String? sessionCookie;

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 100,
      colors: true,
      printEmojis: true,
    ),
  );

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  Dio get dio => _dio;

  static String get rootUrl {
    final Uri parsedUri = Uri.parse(baseUrl);
    return '${parsedUri.scheme}://${parsedUri.host}${parsedUri.hasPort ? ':${parsedUri.port}' : ''}';
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Dynamic Base URL check in case it changed
          if (options.baseUrl != baseUrl) {
            options.baseUrl = baseUrl;
          }

          if (authToken != null && authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $authToken';
          }
          if (sessionCookie != null && sessionCookie!.isNotEmpty) {
            options.headers['Cookie'] = sessionCookie;
          }

          developer.log(
            '🚀 [Dio Request] ${options.method} ${options.uri}',
            name: 'ApiClient',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log(
            '✅ [Dio Response] ${response.statusCode} (${response.requestOptions.uri})',
            name: 'ApiClient',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          final StringBuffer logBuffer = StringBuffer();
          logBuffer.writeln(
            '❌ ERROR [${e.response?.statusCode ?? 'NO RESPONSE'}] <= ${e.requestOptions.uri}',
          );
          logBuffer.writeln('Type: ${e.type}');
          logBuffer.writeln('Message: ${e.message}');
          if (e.response?.data != null) {
            logBuffer.writeln('Response Data: ${e.response?.data}');
          }

          _logger.e(logBuffer.toString());
          developer.log(
            '❌ [Dio Error] ${e.type}: ${e.message} (${e.requestOptions.uri})',
            name: 'ApiClient',
          );

          return handler.next(e);
        },
      ),
    );
  }

  static void setAuthToken(String token) {
    authToken = token;
  }

  static void setSessionCookie(String cookie) {
    sessionCookie = cookie;
  }

  static void clearTokens() {
    authToken = null;
    sessionCookie = null;
  }

  // GET Request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST Request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PUT Request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PATCH Request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // DELETE Request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Multipart File Upload
  Future<Response<T>> uploadFile<T>(
    String path, {
    required File file,
    String fileKey = 'file',
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        fileKey: await MultipartFile.fromFile(file.path, filename: fileName),
        ...?extraData,
      });

      return await _dio.post<T>(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Custom Error Handling
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'Connection timed out. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String message = 'Server error ($statusCode)';
        if (data is Map && data.containsKey('message')) {
          message = data['message'].toString();
        } else if (data is String && data.isNotEmpty) {
          message = data;
        }
        return Exception(message);
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection or server unreachable.');
      default:
        return Exception('An unexpected error occurred: ${error.message}');
    }
  }
}
