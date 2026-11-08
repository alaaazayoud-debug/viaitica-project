import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dighri_customer/constants/app_colors.dart';
import 'package:dighri_customer/screens/home_screen.dart';
import 'package:dighri_customer/screens/medicine_catalog_screen.dart';
import 'package:dighri_customer/screens/warehouses_list_screen.dart';
import 'package:dighri_customer/screens/my_orders_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  // حفظ حالة الشاشات عبر IndexedStack لتجنب إعادة التحميل
  final List<Widget> _screens = const [
    HomeScreen(),
    MedicineCatalogScreen(),
    WarehousesListScreen(),
    MyOrdersScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'الرئيسية'),
                _buildNavItem(1, Icons.medication_outlined, Icons.medication_rounded, 'الأدوية'),
                _buildNavItem(2, Icons.store_outlined, Icons.store_rounded, 'المستودعات'),
                _buildNavItem(3, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'الطلبات'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    
    return InkWell(
      onTap: () {
        if (_currentIndex != index) {
          // Haptic feedback عند التبديل
          HapticFeedback.lightImpact();
          setState(() => _currentIndex = index);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textLight,
              size: isSelected ? 24 : 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
