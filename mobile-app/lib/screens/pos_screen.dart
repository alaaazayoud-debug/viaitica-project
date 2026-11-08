import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:dighri_customer/constants/app_colors.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  final List<Map<String, dynamic>> _salesCart = [];
  bool _isScannerOpen = false;

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _scannerController.stop(); // Stop scanning momentarily
        _handleScannedBarcode(barcode.rawValue!);
        break; // Process one barcode at a time
      }
    }
  }

  void _handleScannedBarcode(String barcodeVal) {
    setState(() {
      final existingIndex = _salesCart.indexWhere((item) => item['barcode'] == barcodeVal);
      if (existingIndex != -1) {
        _salesCart[existingIndex]['quantity'] += 1;
      } else {
        _salesCart.add({
          'name': 'دواء ممسوح (باركود: $barcodeVal)',
          'price': 10000, 
          'quantity': 1,
          'isManual': false,
          'barcode': barcodeVal,
        });
      }
      _isScannerOpen = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت قراءة الباركود بنجاح ✅'), backgroundColor: Colors.green),
    );
  }

  void _openManualEntry() {
    final TextEditingController nameControl = TextEditingController();
    final TextEditingController priceControl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إدخال منتج يدوياً 👇', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameControl,
              decoration: const InputDecoration(labelText: 'اسم المنتج (اختياري)', hintText: 'مثال: علبة كمامات'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceControl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'السعر العمومي (ل.س)', prefixIcon: Icon(Icons.money)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (priceControl.text.isNotEmpty) {
                setState(() {
                  _salesCart.add({
                    'name': nameControl.text.isEmpty ? 'منتج متنوع' : nameControl.text,
                    'price': double.parse(priceControl.text),
                    'quantity': 1,
                    'isManual': true,
                  });
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('إضافة للفاتورة'),
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    double total = 0;
    for (var item in _salesCart) {
      total += (item['price'] * item['quantity']);
    }
    return total;
  }

  void _checkout() {
    if (_salesCart.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('تمت عملية البيع! 🎉', textAlign: TextAlign.center),
        content: Text('تم تسجيل الفاتورة بقيمة ${_calculateTotal().toStringAsFixed(0)} ل.س وتم خصم الأدوية من مخزونك بنجاح.', textAlign: TextAlign.center),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                setState(() => _salesCart.clear());
                Navigator.pop(ctx);
                context.pop();
              },
              child: const Text('إغلاق والعودة', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('نقطة البيع (كاشير)', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: false,
        actions: [
          if (_salesCart.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text('${_salesCart.length}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => setState(() => _salesCart.clear()),
                    child: const Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سجل المبيعات اليومية (قريباً)')));
            },
          )
        ],
      ),
      body: Column(
        children: [
          if (_isScannerOpen)
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.black,
              child: Stack(
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 30),
                      onPressed: () => setState(() {
                        _isScannerOpen = false;
                        _scannerController.stop();
                      }),
                    ),
                  ),
                  const Center(
                    child: Icon(Icons.qr_code_scanner, color: Colors.white54, size: 100),
                  )
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() {
                        _isScannerOpen = true;
                        _scannerController.start();
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.barcode_reader, size: 40, color: AppColors.primary),
                            SizedBox(height: 8),
                            Text('مسح باركود 📸', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _openManualEntry,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.keyboard_outlined, size: 40, color: Colors.orange.shade700),
                            const SizedBox(height: 8),
                            Text('إدخال يدوي ⌨️', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _salesCart.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('الفاتورة فارغة، ابدأ بإضافة منتجات', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _salesCart.length,
                  itemBuilder: (ctx, index) {
                    final item = _salesCart[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: item['isManual'] ? Colors.orange.shade50 : AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Icon(item['isManual'] ? Icons.local_pharmacy_outlined : Icons.medication_outlined, color: item['isManual'] ? Colors.orange : AppColors.primary),
                        ),
                        title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text('1 × ${item['price']} ل.س', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            setState(() => _salesCart.removeAt(index));
                          },
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
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الإجمالي المستحق:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text('${_calculateTotal().toStringAsFixed(0)} ل.س', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _salesCart.isEmpty ? null : _checkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('دفع وتسجيل (كاش) 💰', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
