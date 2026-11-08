import 'package:flutter/material.dart';
import 'package:dighri_customer/constants/app_colors.dart';
import 'package:dighri_customer/services/api_service.dart';
import 'package:dighri_customer/widgets/shimmer_loading.dart';
import 'package:dighri_customer/widgets/empty_state.dart';
import 'package:dighri_customer/widgets/error_state.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  dynamic _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final notifications = await ApiService().getNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await ApiService().markNotificationRead(id);
      _fetchNotifications();
    } catch (e) {
      // Handle error quietly
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await ApiService().markAllNotificationsRead();
      _fetchNotifications();
    } catch (e) {
      // Handle error quietly
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الإشعارات', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
        actions: [
          if (_notifications.any((n) => n['read'] == false))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('تحديد الكل كمقروء', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
        ],
      ),
      body: _isLoading
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: List.generate(5, (_) => const ShimmerNotificationCard()),
              ),
            )
          : _error != null
              ? ErrorStateWidget(error: _error, onRetry: _fetchNotifications)
              : _notifications.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.notifications_none_outlined,
                      title: 'لا توجد إشعارات حالياً',
                      subtitle: 'ستصلك إشعارات فورية عند تحديث حالة طلباتك أو وصول عروض جديدة',
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchNotifications,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return _buildNotificationCard(notification);
                        },
                      ),
                    ),
    );
  }

  Widget _buildNotificationCard(dynamic n) {
    final bool isRead = n['read'] ?? false;
    final DateTime date = DateTime.parse(n['createdAt']);
    final String timeStr = DateFormat('hh:mm a').format(date);
    final String dateStr = DateFormat('yyyy/MM/dd').format(date);

    return InkWell(
      onTap: () {
        if (!isRead) _markAsRead(n['_id']);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white.withValues(alpha: 0.6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRead ? Colors.transparent : AppColors.primary.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isRead ? 0.01 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon based on type
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getIconColor(n['title']).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIcon(n['title']),
                color: _getIconColor(n['title']),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        n['title'] ?? 'تنبيه',
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.bold : FontWeight.w900,
                          fontSize: 14,
                          color: isRead ? AppColors.textLight : AppColors.text,
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n['message'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: isRead ? AppColors.textLight.withValues(alpha: 0.7) : AppColors.textLight,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$dateStr - $timeStr',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textLight.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String? title) {
    if (title == null) return Icons.notifications;
    final t = title.toLowerCase();
    if (t.contains('طلب')) return Icons.shopping_bag_outlined;
    if (t.contains('تم التوصيل')) return Icons.local_shipping_outlined;
    if (t.contains('حصري')) return Icons.star_outline;
    return Icons.notifications_outlined;
  }

  Color _getIconColor(String? title) {
    if (title == null) return AppColors.primary;
    final t = title.toLowerCase();
    if (t.contains('طلب')) return AppColors.primary;
    if (t.contains('تم التوصيل')) return AppColors.emerald;
    if (t.contains('حصري')) return AppColors.accent;
    return AppColors.primary;
  }
}
