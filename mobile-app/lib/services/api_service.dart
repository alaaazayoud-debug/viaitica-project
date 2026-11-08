import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';
import 'secure_storage_service.dart';
import 'package:dighri_customer/core/api_exceptions.dart';
import 'package:dighri_customer/core/navigator_key.dart';

class ApiService {
  final Logger _logger = Logger();
  static const String baseUrl = 'https://viatica-backend.onrender.com/api/v1';
  static const String _tokenKey = 'auth_token';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Dio get dio => _dio;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  ApiService._internal() {
    // ═══ Request Interceptor: إرفاق التوكن تلقائياً ═══
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },

      // ═══ Error Interceptor: معالجة 401 تلقائياً ═══
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          _logger.w('🔒 Token expired or invalid — logging out');
          await _handleTokenExpiry();
          // لا نمرر الخطأ — التطبيق سينتقل لشاشة الدخول
          return handler.reject(error);
        }
        return handler.next(error);
      },
    ));
  }

  /// معالجة انتهاء صلاحية التوكن: مسح البيانات + التوجيه للدخول
  Future<void> _handleTokenExpiry() async {
    await SecureStorageService.clearAll();
    
    // استخدام NavigatorKey للتوجيه من خارج الـ Widget tree
    final context = navigatorKey.currentContext;
    if (context != null) {
      GoRouter.of(context).go('/phone');
    }
  }

  // ═══════════════════════════════════════════════════
  // 🔐 Auth Endpoints
  // ═══════════════════════════════════════════════════

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final response = await _dio.post('/auth/send-otp', data: {'phone': phone});
      return response.data;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<String> verifyOtp(String phone, String otp, {String? name, double? lat, double? lng}) async {
    try {
      final Map<String, dynamic> data = {
         'phone': phone,
         'otp': otp,
      };
      if (name != null) data['name'] = name;
      if (lat != null) data['lat'] = lat;
      if (lng != null) data['lng'] = lng;

      final response = await _dio.post('/auth/verify-otp', data: data);
      final token = response.data['token'];
      await saveToken(token); // Auto save token
      return token;
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      return response.data['data']['user'];
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  // ═══════════════════════════════════════════════════
  // 💊 Drug Endpoints
  // ═══════════════════════════════════════════════════

  Future<List<dynamic>> getDrugs({String? search, String? category, String? warehouseId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category.isNotEmpty && category != 'All') queryParams['category'] = category;
      if (warehouseId != null && warehouseId.isNotEmpty) queryParams['warehouse'] = warehouseId;

      final response = await _dio.get('/drugs', queryParameters: queryParams);
      return response.data['data']['drugs'];
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  // ═══════════════════════════════════════════════════
  // 📦 Order Endpoints
  // ═══════════════════════════════════════════════════

  Future<List<dynamic>> getOrders() async {
    try {
      final response = await _dio.get('/orders');
      return response.data['data']['orders'];
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Map<String, dynamic>> getOrderById(String id) async {
    try {
      final response = await _dio.get('/orders/$id');
      return response.data['data']['order'];
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      await _dio.post('/orders', data: orderData);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _dio.patch('/orders/$orderId/status', data: {'status': status});
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  // ═══════════════════════════════════════════════════
  // 👤 Profile Endpoints
  // ═══════════════════════════════════════════════════

  Future<void> updateProfile({
    required String name,
    required String pharmacyName,
    required double lat,
    required double lng,
    dynamic licenseImage,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'pharmacyName': pharmacyName,
        'lat': lat,
        'lng': lng,
      };

      if (licenseImage != null && licenseImage is XFile) {
        if (kIsWeb) {
          final bytes = await licenseImage.readAsBytes();
          data['licenseImage'] = MultipartFile.fromBytes(
            bytes,
            filename: 'license.jpg',
          );
        } else {
          data['licenseImage'] = await MultipartFile.fromFile(
            licenseImage.path,
            filename: 'license.jpg',
          );
        }
      }

      await _dio.patch('/users/updateMe', data: FormData.fromMap(data));
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  // ═══════════════════════════════════════════════════
  // 🎁 Offer Endpoints
  // ═══════════════════════════════════════════════════

  Future<List<dynamic>> getOffers() async {
    try {
      final response = await _dio.get('/offers');
      return response.data['data']['offers'];
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  // ═══════════════════════════════════════════════════
  // 📰 Feed Endpoints
  // ═══════════════════════════════════════════════════

  Future<List<dynamic>> getFeeds() async {
    try {
      final response = await _dio.get('/feed');
      return response.data['data']['feeds'];
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  // ═══════════════════════════════════════════════════
  // 🔔 Notification Endpoints
  // ═══════════════════════════════════════════════════

  Future<List<dynamic>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      return response.data['data']['notifications'];
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<void> markNotificationRead(String id) async {
    try {
      await _dio.patch('/notifications/$id/read');
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _dio.patch('/notifications/mark-all-read');
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  // ═══════════════════════════════════════════════════
  // 🔑 Token Management
  // ═══════════════════════════════════════════════════

  Future<void> saveToken(String token) async {
    await SecureStorageService.saveToken(token);
  }

  Future<String?> getToken() async {
    return await SecureStorageService.getToken();
  }

  Future<void> logout() async {
    await SecureStorageService.clearAll();
  }

  // ═══════════════════════════════════════════════════
  // ❌ Unified Error Handler
  // ═══════════════════════════════════════════════════

  /// يحوّل DioException إلى AppException مقروءة ومترجمة.
  /// عامّة حتى تستخدمها الخدمات الفرعية (LedgerService, InventoryService).
  AppException handleError(DioException e) {
    _logger.e('API Error: ${e.type} — ${e.message}', error: e);

    // خطأ في الاتصال / لا يوجد إنترنت
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      return NetworkException();
    }

    // انتهاء مهلة الاتصال
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return TimeoutException();
    }

    // خطأ من السيرفر مع response
    if (e.response != null) {
      final statusCode = e.response!.statusCode ?? 0;
      final data = e.response!.data;

      // استخراج رسالة الخطأ من الباكند
      String serverMessage = 'حدث خطأ غير متوقع';
      if (data is Map && data.containsKey('message')) {
        serverMessage = data['message'];
      }

      switch (statusCode) {
        case 400:
          return BadRequestException(serverMessage);
        case 401:
          return UnauthorizedException(serverMessage);
        case 403:
          return ForbiddenException(serverMessage);
        case 404:
          return NotFoundException(serverMessage);
        case 422:
          return ValidationException(serverMessage);
        default:
          if (statusCode >= 500) {
            return ServerException(serverMessage);
          }
          return AppException(serverMessage, statusCode: statusCode);
      }
    }

    return AppException('حدث خطأ في الاتصال بالسيرفر');
  }
}
