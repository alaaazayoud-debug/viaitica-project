import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dighri_customer/constants/app_colors.dart';
import 'package:dighri_customer/services/cart_service.dart';
import 'package:dighri_customer/services/api_service.dart';
import 'package:dighri_customer/widgets/qty_selector.dart';
import 'package:url_launcher/url_launcher.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isSubmitting = false;

  Future<void> _launchWhatsApp(String orderId, List<CartItem> items, double total) async {
    // Replace with the actual warehouse phone number
    const phoneNumber = '963966262458'; 
    
    final StringBuffer message = StringBuffer();
    message.writeln('مرحباً، طلب جديد من تطبيق الصيدلي 🏥');
    message.writeln('رقم الطلب: #$orderId');
    message.writeln('----------------');
    for (var item in items) {
      message.writeln('- ${item.name} (${item.quantity})');
    }
    message.writeln('----------------');
    message.writeln('المجموع: $total ل.س');
    message.writeln('يرجى تأكيد الاستلام والتوصيل. شكراً!');

    final url = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message.toString())}');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكن فتح واتساب')),
      );
    }
  }

  void _placeOrder() async {
    final cart = CartService();
    if (cart.items.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final warehouseId = cart.currentWarehouseId;
      if (warehouseId == null) throw Exception('السلة فارغة');

      // Keep a copy of items for the message before clearing cart
      final currentItems = List<CartItem>.from(cart.items);
      final currentTotal = cart.totalPrice;

      final orderData = {
        'warehouse': warehouseId,
        'drugs': cart.items.map((item) => {
          'drug': item.drugId,
          'quantity': item.quantity,
          'price': item.price,
        }).toList(),
        'deliveryAddress': 'موقع الصيدلية الافتراضي',
      };

      await ApiService().createOrder(orderData);
      
      // Simulate getting an ID back (in a real app, backend should return the created order ID)
      // For now, we'll use a placeholder or timestamp
      final orderId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);

      cart.clear();
      if (!mounted) return;

      // Show Success Dialog with WhatsApp Option
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('تم الإرسال بنجاح'),
            ],
          ),
          content: const Text('تم استلام طلبك. هل تريد إرسال التفاصيل للمستودع عبر واتساب لسرعة التنفيذ؟'),
          actions: [
            TextButton(
              onPressed: () {
                context.pop(); // Close dialog
                context.go('/home');
              },
              child: const Text('لاحقاً'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('أرسل عبر واتساب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                context.pop(); // Close dialog
                _launchWhatsApp(orderId, currentItems, currentTotal);
                context.go('/home');
              },
            ),
          ],
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل إرسال الطلب: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة المشتريات'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: CartService(),
        builder: (context, child) {
          final cart = CartService();
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('السلة فارغة', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('تصفح الأدوية'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.medication, color: AppColors.primary),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item.price} ل.س للوحدة | الإجمالي: ${item.total} ل.س', style: const TextStyle(fontSize: 11)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Hybrid Quantity Selector
                            QtySelector(
                              quantity: item.quantity,
                              editable: true,
                              onChanged: (newQty) {
                                cart.updateQuantity(item.drugId, newQty);
                              },
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () => cart.removeItem(item.drugId),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('المجموع الكلي:', style: TextStyle(fontSize: 18)),
                        Text(
                          '${cart.totalPrice} ل.س',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'سيتم تطبيق البونص (10+2) والخصومات تلقائياً من نظام المستودع عند التأكيد.',
                              style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('تأكيد الطلب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
