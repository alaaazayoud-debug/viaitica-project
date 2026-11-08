import 'package:flutter/material.dart';
import 'package:dighri_customer/constants/app_colors.dart';
import 'package:dighri_customer/services/api_service.dart';
import 'package:dighri_customer/widgets/shimmer_loading.dart';
import 'package:dighri_customer/widgets/error_state.dart';
import 'package:dighri_customer/widgets/status_badge.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, dynamic>? _order;
  bool _isLoading = true;
  dynamic _error;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final order = await ApiService().getOrderById(widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsDelivered() async {
    setState(() => _isLoading = true);
    try {
      await ApiService().updateOrderStatus(widget.orderId, 'delivered');
      await _fetchOrderDetails(); // Refresh the order state
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تأكيد الاستلام بنجاح ✅'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل التحديث: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تفاصيل الفاتورة', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
      ),
      body: _isLoading
          ? SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ShimmerLoading(
                child: Column(
                  children: [
                    const ShimmerBox(width: double.infinity, height: 140, borderRadius: 32),
                    const SizedBox(height: 32),
                    const ShimmerBox(width: double.infinity, height: 24, borderRadius: 12),
                    const SizedBox(height: 32),
                    ...List.generate(3, (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: const ShimmerBox(width: double.infinity, height: 72, borderRadius: 20),
                    )),
                    const SizedBox(height: 32),
                    const ShimmerBox(width: double.infinity, height: 120, borderRadius: 32),
                  ],
                ),
              ),
            )
          : _error != null
              ? ErrorStateWidget(error: _error, onRetry: _fetchOrderDetails)
              : _order == null
                  ? const ErrorStateWidget(error: 'الطلب غير موجود')
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusHeader(),
                          const SizedBox(height: 32),
                          _buildTrackingTimeline(),
                          const SizedBox(height: 32),
                          const Text(
                            'الأصناف الدوائية',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 16),
                          _buildItemsList(),
                          const SizedBox(height: 32),
                          _buildOrderSummary(),
                          const SizedBox(height: 32),
                          if (_order!['status'] == 'confirmed' || _order!['status'] == 'out_for_delivery')
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton.icon(
                                onPressed: _markAsDelivered,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                                label: const Text(
                                  'تأكيد استلام الأدوية 📦', 
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                              ),
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildStatusHeader() {
    final status = _order!['status'];
    final color = StatusBadge.getStatusColor(status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 20, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(StatusBadge.getStatusIcon(status), color: color, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            StatusBadge.getStatusText(status),
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            'طلب #${_order!['_id'].toString().substring(_order!['_id'].toString().length - 6).toUpperCase()}',
            style: TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline() {
    final status = _order!['status'];
    final List<String> stages = ['pending', 'confirmed', 'out_for_delivery', 'delivered'];
    final currentIndex = stages.indexOf(status);

    return Row(
      children: List.generate(stages.length, (index) {
        final isCompleted = index <= currentIndex;
        final isLast = index == stages.length - 1;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.primary : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: isCompleted ? AppColors.primary : AppColors.grey),
                ),
                child: isCompleted 
                  ? const Icon(Icons.check, color: Colors.white, size: 14) 
                  : Center(child: Text('${index + 1}', style: TextStyle(fontSize: 10, color: AppColors.grey, fontWeight: FontWeight.bold))),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? AppColors.primary : AppColors.grey.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildItemsList() {
    return Column(
      children: (_order!['drugs'] as List).map((item) {
        final drug = item['drug'];
        final drugName = drug is Map ? drug['name'] : 'دواء غير معروف';
        final drugDosage = drug is Map ? (drug['dosage'] ?? '') : '';
        final quantity = item['quantity'];
        final price = item['price'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.medication_outlined, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(drugName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    if (drugDosage.isNotEmpty)
                      Text(drugDosage, style: TextStyle(color: AppColors.textLight, fontSize: 11)),
                    Text('$quantity وحدة × ${price.toStringAsFixed(0)} ل.س', style: TextStyle(color: AppColors.textLight, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text(
                '${(price * quantity).toStringAsFixed(0)} ل.س',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.text),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderSummary() {
    final total = _calculateTotal();
    final address = _order!['deliveryAddress'] ?? 'عنوان الصيدلية المسجل';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('تفاصيل الاستلام', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(address, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white24, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('المجموع الكلي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                '${total.toStringAsFixed(0)} ل.س',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    if (_order == null) return 0;
    double total = 0;
    for (var item in _order!['drugs']) {
      total += (item['price'] * item['quantity']);
    }
    return total;
  }
}
