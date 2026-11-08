import 'package:flutter/material.dart';
import 'package:dighri_customer/constants/app_colors.dart';
import 'package:dighri_customer/services/cart_service.dart';
import 'package:dighri_customer/widgets/qty_selector.dart';

class DrugDetailScreen extends StatelessWidget {
  final dynamic drug;

  const DrugDetailScreen({super.key, required this.drug});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ═══ SliverAppBar مع Hero Animation ═══
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // أيقونة الخلفية الكبيرة
                  Positioned(
                    left: -40,
                    bottom: -30,
                    child: Icon(Icons.medication_rounded, size: 220, color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  // Hero Icon
                  Center(
                    child: Hero(
                      tag: 'drug_${drug['_id']}',
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.science_outlined, color: Colors.white, size: 56),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -24, 0),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ═══ العنوان والسعر ═══
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                drug['name'] ?? '',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                drug['genericName'] ?? drug['manufacturer'] ?? 'شركة غير معروفة',
                                style: TextStyle(fontSize: 14, color: AppColors.textLight.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${drug['price']} ل.س',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.emerald),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ═══ Badges ═══
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (drug['category'] != null) _buildBadge(drug['category'], Colors.blue),
                        if (drug['dosageForm'] != null) _buildBadge(drug['dosageForm'], Colors.orange),
                        if (drug['dosage'] != null && drug['dosage'].toString().isNotEmpty)
                          _buildBadge(drug['dosage'], Colors.teal),
                        if (drug['manufacturer'] != null) _buildBadge(drug['manufacturer'], AppColors.textLight),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ═══ المعلومات العلمية ═══
                    _buildSectionTitle('المعلومات العلمية', Icons.science_outlined),
                    const SizedBox(height: 12),
                    _buildInfoCard([
                      _buildInfoRow('الاسم العلمي', drug['genericName'] ?? 'غير متوفر'),
                      _buildInfoRow('المواد الفعالة', (drug['activeIngredients'] as List?)?.join(', ') ?? 'غير متوفر'),
                      _buildInfoRow('دواعي الاستعمال', drug['indications'] ?? 'راجع الطبيب أو الصيدلاني'),
                      _buildInfoRow('الآثار الجانبية', (drug['sideEffects'] as List?)?.join(', ') ?? 'لا توجد آثار جانبية مسجلة'),
                    ]),

                    const SizedBox(height: 24),

                    // ═══ معلومات التوريد ═══
                    _buildSectionTitle('معلومات التوريد', Icons.local_shipping_outlined),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.grey.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.storefront, color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  drug['warehouse']?['name'] ?? drug['warehouse']?['pharmacyName'] ?? 'المستودع المركزي',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 8, height: 8,
                                      decoration: const BoxDecoration(color: AppColors.emerald, shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text('متوفر للتوصيل', style: TextStyle(fontSize: 12, color: AppColors.emerald, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight),
                        ],
                      ),
                    ),

                    // ═══ معلومات إضافية ═══
                    if (drug['publicPrice'] != null) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle('التسعير', Icons.attach_money),
                      const SizedBox(height: 12),
                      _buildInfoCard([
                        _buildInfoRow('سعر المستودع', '${drug['price']} ل.س'),
                        _buildInfoRow('سعر المبيع العام', '${drug['publicPrice']} ل.س'),
                        _buildInfoRow('هامش الربح', '${((drug['publicPrice'] as num) - (drug['price'] as num)).toStringAsFixed(0)} ل.س'),
                      ]),
                    ],

                    const SizedBox(height: 120), // Space for bottom button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // ═══ زر الإضافة للسلة مع محدد الكمية ═══
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: CartService(),
            builder: (context, _) {
              final cartItem = CartService().items.where((i) => i.drugId == drug['_id']).firstOrNull;
              final currentQty = cartItem?.quantity ?? 0;

              if (currentQty > 0) {
                // في السلة — إظهار محدد الكمية
                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.emerald, size: 20),
                            const SizedBox(width: 8),
                            const Text('في السلة', style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    QtySelector(
                      quantity: currentQty,
                      onChanged: (newQty) {
                        CartService().updateQuantity(drug['_id'], newQty);
                      },
                    ),
                  ],
                );
              }

              // ليس في السلة — زر إضافة
              return ElevatedButton.icon(
                onPressed: () {
                  try {
                    CartService().addItem(drug);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تمت إضافة ${drug['name']} إلى السلة ✅'),
                        backgroundColor: AppColors.emerald,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString().replaceAll('Exception: ', '')),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.add_shopping_cart, size: 22),
                label: const Text('إضافة إلى السلة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  elevation: 6,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.5)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.textLight.withValues(alpha: 0.7), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900),
      ),
    );
  }
}
