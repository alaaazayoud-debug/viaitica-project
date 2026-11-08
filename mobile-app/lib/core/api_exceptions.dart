/// فئات الأخطاء الموحدة لكل التطبيق.
/// تُستخدم في ApiService وتُعرض عبر ErrorStateWidget.

class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  AppException(this.message, {this.code, this.statusCode});

  @override
  String toString() => message;
}

/// خطأ في الشبكة (لا يوجد إنترنت)
class NetworkException extends AppException {
  NetworkException([String message = 'لا يوجد اتصال بالإنترنت. تحقق من الشبكة وحاول مجدداً.'])
      : super(message, code: 'NETWORK_ERROR');
}

/// انتهاء صلاحية التوكن أو عدم المصادقة
class UnauthorizedException extends AppException {
  UnauthorizedException([String message = 'انتهت جلستك. يرجى تسجيل الدخول مجدداً.'])
      : super(message, code: 'UNAUTHORIZED', statusCode: 401);
}

/// خطأ من السيرفر (500+)
class ServerException extends AppException {
  ServerException([String message = 'حدث خطأ في السيرفر. حاول لاحقاً.'])
      : super(message, code: 'SERVER_ERROR', statusCode: 500);
}

/// خطأ في الطلب (400)
class BadRequestException extends AppException {
  BadRequestException(String message)
      : super(message, code: 'BAD_REQUEST', statusCode: 400);
}

/// المورد غير موجود (404)
class NotFoundException extends AppException {
  NotFoundException([String message = 'المحتوى المطلوب غير موجود.'])
      : super(message, code: 'NOT_FOUND', statusCode: 404);
}

/// خطأ في التحقق (422)
class ValidationException extends AppException {
  final Map<String, dynamic>? errors;
  ValidationException(String message, {this.errors})
      : super(message, code: 'VALIDATION_ERROR', statusCode: 422);
}

/// انتهاء مهلة الاتصال
class TimeoutException extends AppException {
  TimeoutException([String message = 'انتهت مهلة الاتصال. تحقق من سرعة الإنترنت.'])
      : super(message, code: 'TIMEOUT');
}

/// محظور (403)
class ForbiddenException extends AppException {
  ForbiddenException([String message = 'ليس لديك صلاحية لهذا الإجراء.'])
      : super(message, code: 'FORBIDDEN', statusCode: 403);
}
