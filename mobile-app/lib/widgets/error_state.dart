import 'package:flutter/material.dart';
import 'package:dighri_customer/constants/app_colors.dart';
import 'package:dighri_customer/core/api_exceptions.dart';

/// ويدجت حالة خطأ موحدة مع أيقونة مناسبة حسب نوع الخطأ + زر إعادة محاولة.
class ErrorStateWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;
  final String? customMessage;

  const ErrorStateWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final errorInfo = _getErrorInfo();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة الخطأ مع خلفية ملونة
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: errorInfo.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                errorInfo.icon,
                size: 48,
                color: errorInfo.color,
              ),
            ),
            const SizedBox(height: 24),

            // عنوان الخطأ
            Text(
              errorInfo.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: AppColors.text,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),

            // وصف الخطأ
            Text(
              customMessage ?? errorInfo.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textLight.withValues(alpha: 0.7),
                fontSize: 13,
                height: 1.5,
              ),
            ),

            // زر إعادة المحاولة
            if (onRetry != null) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// يحدد الأيقونة واللون والرسالة بناءً على نوع الخطأ
  _ErrorInfo _getErrorInfo() {
    if (error is NetworkException) {
      return _ErrorInfo(
        icon: Icons.wifi_off_rounded,
        color: Colors.orange.shade700,
        title: 'لا يوجد اتصال',
        message: error.toString(),
      );
    }
    if (error is TimeoutException) {
      return _ErrorInfo(
        icon: Icons.timer_off_rounded,
        color: Colors.amber.shade700,
        title: 'انتهت المهلة',
        message: error.toString(),
      );
    }
    if (error is ServerException) {
      return _ErrorInfo(
        icon: Icons.cloud_off_rounded,
        color: AppColors.danger,
        title: 'خطأ في السيرفر',
        message: error.toString(),
      );
    }
    if (error is UnauthorizedException) {
      return _ErrorInfo(
        icon: Icons.lock_outline_rounded,
        color: Colors.red.shade600,
        title: 'انتهت الجلسة',
        message: error.toString(),
      );
    }
    if (error is NotFoundException) {
      return _ErrorInfo(
        icon: Icons.search_off_rounded,
        color: AppColors.textLight,
        title: 'غير موجود',
        message: error.toString(),
      );
    }
    if (error is ForbiddenException) {
      return _ErrorInfo(
        icon: Icons.block_rounded,
        color: Colors.red.shade400,
        title: 'غير مصرح',
        message: error.toString(),
      );
    }

    // خطأ عام
    return _ErrorInfo(
      icon: Icons.error_outline_rounded,
      color: AppColors.danger,
      title: 'حدث خطأ',
      message: error?.toString() ?? 'حدث خطأ غير متوقع. حاول مجدداً.',
    );
  }
}

/// معلومات الخطأ المعروضة
class _ErrorInfo {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  _ErrorInfo({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });
}
