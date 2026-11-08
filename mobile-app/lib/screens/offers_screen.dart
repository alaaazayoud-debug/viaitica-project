import 'package:flutter/material.dart';
import 'package:dighri_customer/services/api_service.dart';
import 'package:dighri_customer/widgets/shimmer_loading.dart';
import 'package:dighri_customer/widgets/empty_state.dart';
import 'package:dighri_customer/widgets/error_state.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  List<dynamic> _offers = [];
  bool _isLoading = true;
  dynamic _error;

  @override
  void initState() {
    super.initState();
    _fetchOffers();
  }

  Future<void> _fetchOffers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final offers = await ApiService().getOffers();
      setState(() {
        _offers = offers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  Color _getOfferColor(String? colorName) {
    switch (colorName) {
      case 'purple': return Colors.purple.shade600;
      case 'teal': return Colors.teal.shade600;
      case 'orange': return Colors.orange.shade600;
      case 'blue':
      default: return Colors.blue.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('العروض والخصومات'),
        centerTitle: true,
      ),
      body: _isLoading
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(3, (_) => const ShimmerOfferCard()),
              ),
            )
          : _error != null
              ? ErrorStateWidget(error: _error, onRetry: _fetchOffers)
              : _offers.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.local_offer_outlined,
                      title: 'لا توجد عروض نشطة حالياً',
                      subtitle: 'تابعنا! ستظهر هنا أحدث العروض والخصومات من المستودعات',
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchOffers,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _offers.length,
                        itemBuilder: (context, index) {
                          final offer = _offers[index];
                          final mainColor = _getOfferColor(offer['color']);
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: mainColor.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with Gradient
                                Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [mainColor, mainColor.withValues(alpha: 0.7)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              offer['title'] ?? 'عرض جديد',
                                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              offer['endDate'] != null
                                                ? 'ينتهي في: ${DateFormat('yyyy/MM/dd').format(DateTime.parse(offer['endDate']))}'
                                                : 'عرض لفترة محدودة',
                                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        offer['type'] == 'bonus' ? Icons.plus_one : 
                                        offer['type'] == 'discount' ? Icons.percent : Icons.local_offer,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Content
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        offer['subtitle'] ?? '',
                                        style: TextStyle(color: Colors.grey.shade800, fontSize: 14, height: 1.5),
                                      ),
                                      if (offer['type'] == 'discount' && offer['discountPercentage'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text('خصم ${offer['discountPercentage']}%', style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
                                        ),
                                      if (offer['type'] == 'bonus' && offer['bonusBase'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text('بونص ${offer['bonusBase']} + ${offer['bonusQuantity']}', style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
                                        ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          const Icon(Icons.business, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            (offer['warehouse'] != null && offer['warehouse']['name'] != null)
                                              ? offer['warehouse']['name']
                                              : 'المستودع المركزي',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                                          ),
                                          const Spacer(),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (offer['drug'] != null) {
                                                // Navigate filtered by drug name or ID (future)
                                                context.push('/catalog'); 
                                              } else {
                                                context.push('/catalog');
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: mainColor,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            child: const Text('استفد من العرض'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
