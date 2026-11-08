import 'package:flutter/material.dart';
import 'package:dighri_customer/constants/app_colors.dart';

/// شارة حالة الطلب الموحدة — تُستخدم في my_orders_screen و order_details_screen.
class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor(status);
    final text = getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: fontSize),
          ),
        ],
      ),
    );
  }

  /// يعيد اللون المناسب لحالة الطلب
  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'assigned':
        return Colors.indigo;
      case 'out_for_delivery':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// يعيد النص العربي لحالة الطلب
  static String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'تم التأكيد';
      case 'assigned':
        return 'تم تعيين سائق';
      case 'out_for_delivery':
        return 'جاري التوصيل';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  /// يعيد أيقونة مناسبة لحالة الطلب
  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.timer_outlined;
      case 'confirmed':
        return Icons.verified_outlined;
      case 'assigned':
        return Icons.person_pin_circle_outlined;
      case 'out_for_delivery':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }
}
