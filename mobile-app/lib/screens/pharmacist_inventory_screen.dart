import 'package:flutter/material.dart';
import 'package:dighri_customer/constants/app_colors.dart';
import 'package:dighri_customer/services/inventory_service.dart';
import 'package:dighri_customer/widgets/shimmer_loading.dart';
import 'package:dighri_customer/widgets/empty_state.dart';
import 'package:dighri_customer/widgets/error_state.dart';

class PharmacistInventoryScreen extends StatefulWidget {
  const PharmacistInventoryScreen({super.key});

  @override
  State<PharmacistInventoryScreen> createState() => _PharmacistInventoryScreenState();
}

class _PharmacistInventoryScreenState extends State<PharmacistInventoryScreen> {
  List<dynamic> _inventory = [];
  bool _isLoading = true;
  dynamic _error;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await InventoryService().getMyStock();
      setState(() {
        _inventory = data;
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
        title: const Text('مخزني (الصيدلية)', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: _isLoading
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(5, (_) => const ShimmerDrugCard()),
              ),
            )
          : _error != null
              ? ErrorStateWidget(error: _error, onRetry: _fetchInventory)
              : _inventory.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.inventory_2_outlined,
                      title: 'لا توجد أدوية في مخزنك حالياً',
                      subtitle: 'ستظهر هنا الأدوية المُباعة عبر نقطة البيع بعد إتمام عمليات البيع',
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchInventory,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _inventory.length,
                        itemBuilder: (context, index) {
                          final item = _inventory[index];
                          final drug = item['drug'];
                          final qty = item['quantity'] ?? 0;
                          final threshold = item['threshold'] ?? 10;
                          final isLow = qty < threshold;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isLow ? Colors.orange.withValues(alpha: 0.5) : AppColors.grey.withValues(alpha: 0.5),
                              ),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isLow ? Colors.orange.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.medication,
                                    color: isLow ? Colors.orange : AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(drug['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                      if (drug['genericName'] != null)
                                        Text(drug['genericName'], style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                                      if (isLow)
                                        Container(
                                          margin: const EdgeInsets.only(top: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text('⚠️ كمية منخفضة', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w900)),
                                        ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('$qty', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: isLow ? Colors.orange : AppColors.text)),
                                    const Text('قطعة', style: TextStyle(fontSize: 10, color: AppColors.textLight, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
