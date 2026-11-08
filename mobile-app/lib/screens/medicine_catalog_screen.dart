import 'package:flutter/material.dart';
import 'package:dighri_customer/constants/app_colors.dart';
import 'package:dighri_customer/services/api_service.dart';
import 'package:dighri_customer/services/cart_service.dart';
import 'package:dighri_customer/widgets/shimmer_loading.dart';
import 'package:dighri_customer/widgets/empty_state.dart';
import 'package:dighri_customer/widgets/error_state.dart';
import 'package:dighri_customer/widgets/qty_selector.dart';
import 'package:dighri_customer/widgets/animated_cart_badge.dart';
import 'package:go_router/go_router.dart';

import 'dart:async'; // For Timer

class MedicineCatalogScreen extends StatefulWidget {
  final String? initialCategory;
  final String? warehouseId;
  const MedicineCatalogScreen({super.key, this.initialCategory, this.warehouseId});

  @override
  State<MedicineCatalogScreen> createState() => _MedicineCatalogScreenState();
}

class _MedicineCatalogScreenState extends State<MedicineCatalogScreen> {
  List<dynamic> _drugs = [];
  bool _isLoading = true;
  dynamic _error;
  
  // Search & Filter State
  final TextEditingController _searchController = TextEditingController();
  late String _selectedCategory;
  Timer? _debounce;

  final List<String> _categories = [
    'All',
    'analgesic',
    'antibiotic',
    'antihistamine',
    'antidepressant',
    'other'
  ];

  // Helper to translate category for display
  String _getCategoryDisplay(String cat) {
    switch (cat) {
      case 'All': return 'الكل';
      case 'analgesic': return 'مسكنات';
      case 'antibiotic': return 'مضادات حيوية';
      case 'antihistamine': return 'مضادات حساسية';
      case 'antidepressant': return 'مضادات اكتئاب';
      case 'other': return 'أخرى';
      default: return cat;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
    _fetchDrugs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchDrugs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final drugs = await ApiService().getDrugs(
        search: _searchController.text,
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        warehouseId: widget.warehouseId,
      );
      setState(() {
        _drugs = drugs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchDrugs();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _fetchDrugs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('المواد الطبية', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
        actions: const [
          AnimatedCartBadge(),
        ],
      ),
      body: Column(
        children: [
          // 🔎 Professional Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'ابحث عن اسم الدواء أو الشركة المصنعة...',
                prefixIcon: Icon(Icons.search, size: 20, color: AppColors.primary),
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),

          // 🏷️ Category Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: InkWell(
                    onTap: () => _onCategorySelected(cat),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.grey,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))
                        ] : null,
                      ),
                      child: Text(
                        _getCategoryDisplay(cat),
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textLight,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 12),

          // 💊 The Elite Drug List
          Expanded(
            child: _isLoading
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: List.generate(5, (_) => const ShimmerDrugCard()),
                    ),
                  )
                : _error != null
                    ? ErrorStateWidget(error: _error, onRetry: _fetchDrugs)
                    : _drugs.isEmpty
                        ? EmptyStateWidget(
                            icon: Icons.inventory_2_outlined,
                            title: 'لا توجد نتائج مطابقة',
                            subtitle: 'جرّب تغيير كلمة البحث أو اختيار صنف آخر',
                            actionLabel: 'عرض الكل',
                            onAction: () {
                              _searchController.clear();
                              _selectedCategory = 'All';
                              _fetchDrugs();
                            },
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchDrugs,
                            color: AppColors.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _drugs.length,
                              itemBuilder: (context, index) {
                                final med = _drugs[index];
                                return _buildEliteDrugCard(med);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildEliteDrugCard(dynamic med) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Medicine Art
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Hero(
                  tag: 'drug_${med['_id']}',
                  child: Icon(Icons.science_outlined, color: AppColors.primary.withValues(alpha: 0.4), size: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Core Info
            Expanded(
              child: InkWell(
                onTap: () => context.push('/drug-detail', extra: med),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      med['genericName'] ?? 'لا يوجد اسم علمي',
                      style: const TextStyle(fontSize: 12, color: AppColors.textLight, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildBadge(med['manufacturer'] ?? 'شركة مجهولة', AppColors.textLight),
                        if (med['dosage'] != null)
                           _buildBadge(med['dosage'], AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Price & Integrated Action
            ListenableBuilder(
              listenable: CartService(),
              builder: (context, _) {
                final cartItem = CartService().items.where((i) => i.drugId == med['_id']).firstOrNull;
                final currentQty = cartItem?.quantity ?? 0;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${med['price']} ل.س',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.emerald, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    
                    if (currentQty == 0)
                      InkWell(
                        onTap: () {
                          try {
                            CartService().addItem(med);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('تم الإضافة بنجاح'), 
                              duration: Duration(seconds: 1), 
                              backgroundColor: AppColors.emerald,
                            ));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(e.toString().replaceAll('Exception: ', '')), 
                              backgroundColor: AppColors.danger,
                            ));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
                        ),
                      )
                    else
                      QtySelector(
                        quantity: currentQty,
                        compact: true,
                        onChanged: (newQty) {
                          CartService().updateQuantity(med['_id'], newQty);
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900),
      ),
    );
  }
}
