import 'package:flutter/material.dart';
import 'package:dighri_customer/constants/app_colors.dart';
import 'package:dighri_customer/services/api_service.dart';
import 'package:dighri_customer/widgets/shimmer_loading.dart';
import 'package:dighri_customer/widgets/empty_state.dart';
import 'package:dighri_customer/widgets/error_state.dart';
import 'package:go_router/go_router.dart';

class WarehousesListScreen extends StatefulWidget {
  const WarehousesListScreen({super.key});

  @override
  State<WarehousesListScreen> createState() => _WarehousesListScreenState();
}

class _WarehousesListScreenState extends State<WarehousesListScreen> {
  List<dynamic> _warehouses = [];
  bool _isLoading = true;
  dynamic _error;

  @override
  void initState() {
    super.initState();
    _fetchWarehouses();
  }

  Future<void> _fetchWarehouses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await ApiService().dio.get('/users/public/warehouses');
      if (mounted) {
        setState(() {
          _warehouses = response.data['data']['warehouses'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('المستودعات المعتمدة', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
        automaticallyImplyLeading: false, // Since it's a bottom tab
      ),
      body: _isLoading 
        ? SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: List.generate(4, (_) => const ShimmerWarehouseCard()),
            ),
          )
        : _error != null
          ? ErrorStateWidget(error: _error, onRetry: _fetchWarehouses)
          : _warehouses.isEmpty
            ? const EmptyStateWidget(
                icon: Icons.store_outlined,
                title: 'لا توجد مستودعات متاحة حالياً',
                subtitle: 'ستظهر هنا المستودعات المعتمدة بمجرد تسجيلها في النظام',
              )
            : RefreshIndicator(
                onRefresh: _fetchWarehouses,
                color: AppColors.primary,
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _warehouses.length,
                  itemBuilder: (context, index) {
                    final wh = _warehouses[index];
                    return InkWell(
                      onTap: () => context.push('/catalog?warehouseId=${wh['_id']}'),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.grey.withValues(alpha: 0.5)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: (wh['logo'] != null && wh['logo'].toString().isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(wh['logo'], fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.storefront, color: AppColors.primary, size: 30)),
                                  )
                                : const Icon(Icons.storefront, color: AppColors.primary, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(wh['pharmacyName'] ?? wh['name'] ?? 'مستودع أدوية', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textLight),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text(wh['addressText'] ?? 'العنوان غير متوفر', style: const TextStyle(color: AppColors.textLight, fontSize: 11, fontWeight: FontWeight.w500), maxLines: 1)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textLight.withValues(alpha: 0.5)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
