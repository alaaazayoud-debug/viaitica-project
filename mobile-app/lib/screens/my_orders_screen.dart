import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:dighri_customer/constants/app_colors.dart';
import 'package:dighri_customer/services/api_service.dart';
import 'package:dighri_customer/widgets/shimmer_loading.dart';
import 'package:dighri_customer/widgets/empty_state.dart';
import 'package:dighri_customer/widgets/error_state.dart';
import 'package:dighri_customer/widgets/status_badge.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  dynamic _error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final orders = await ApiService().getOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('سجل الطلبات', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
      ),
      body: _isLoading
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: List.generate(4, (_) => const ShimmerOrderCard()),
              ),
            )
          : _error != null
              ? ErrorStateWidget(error: _error, onRetry: _fetchOrders)
              : _orders.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.shopping_basket_outlined,
                      title: 'لا توجد طلبات سابقة حتى الآن',
                      subtitle: 'ابدأ بطلب أدويتك من الكتالوج الآن',
                      actionLabel: 'تصفح الأدوية',
                      onAction: () => context.push('/catalog'),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchOrders,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          final date = DateTime.parse(order['createdAt']);
                          final formattedDate = DateFormat('yyyy/MM/dd | hh:mm a').format(date);
                          final status = order['status'];
                          final itemsCount = (order['drugs'] as List).length;
                          
                          double total = 0;
                          for (var item in order['drugs']) {
                            total += (item['price'] * item['quantity']);
                          }

                          return _buildEliteOrderCard(order, formattedDate, status, itemsCount, total);
                        },
                      ),
                    ),
    );
  }

  Widget _buildEliteOrderCard(dynamic order, String date, String status, int count, double total) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/orders/${order['_id']}'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طلب #${order['_id'].toString().substring(order['_id'].toString().length - 6).toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  StatusBadge(status: status),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$count أصناف دوائية',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                        Text(
                          'تواصل مع المستودع للمتابعة',
                          style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('الإجمالي', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                      Text(
                        '${total.toStringAsFixed(0)} ل.س',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.emerald),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
