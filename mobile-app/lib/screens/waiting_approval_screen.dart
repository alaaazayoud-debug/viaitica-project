import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dighri_customer/constants/app_colors.dart';
import 'package:dighri_customer/services/api_service.dart';

class WaitingApprovalScreen extends StatefulWidget {
  const WaitingApprovalScreen({super.key});

  @override
  State<WaitingApprovalScreen> createState() => _WaitingApprovalScreenState();
}

class _WaitingApprovalScreenState extends State<WaitingApprovalScreen>
    with SingleTickerProviderStateMixin {
  bool _isChecking = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);
    try {
      final user = await ApiService().getMe();
      if (user['status'] == 'verified') {
        if (mounted) GoRouter.of(context).go('/home');
      } else if (user['status'] == 'rejected') {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: const Text('تم رفض طلبك، يرجى التواصل مع الدعم'),
               backgroundColor: AppColors.danger,
               behavior: SnackBarBehavior.floating,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
             )
           );
         }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('ما زال طلبك قيد المراجعة ⏳'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            )
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.danger,
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _logout() async {
    await ApiService().logout();
    if (mounted) GoRouter.of(context).go('/phone');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom - 64,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة نابضة
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.verified_user_outlined, size: 64, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 40),

                const Text(
                  'طلبك قيد المراجعة',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'شكراً لانضمامك لـ \"فارمجي\". يقوم فريقنا الآن بمراجعة رخصة الصيدلية الخاصة بك.\n\nسيتم تفعيل حسابك فور التأكد من البيانات.',
                  style: TextStyle(fontSize: 15, color: AppColors.textLight.withValues(alpha: 0.7), height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // خطوات العملية
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.grey.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      _buildStep(1, 'تسجيل البيانات', true),
                      _buildStep(2, 'مراجعة الترخيص', false, isCurrent: true),
                      _buildStep(3, 'تفعيل الحساب', false),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isChecking ? null : _checkStatus,
                    icon: _isChecking
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.refresh),
                    label: Text(
                      _isChecking ? 'جاري التحقق...' : 'تحديث الحالة',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, size: 18, color: AppColors.danger),
                  label: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int number, String label, bool completed, {bool isCurrent = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: completed
                  ? AppColors.emerald
                  : isCurrent
                      ? AppColors.primary
                      : AppColors.grey.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: completed
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      '$number',
                      style: TextStyle(
                        color: isCurrent ? Colors.white : AppColors.textLight,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontWeight: completed || isCurrent ? FontWeight.w900 : FontWeight.w500,
              color: completed || isCurrent ? AppColors.text : AppColors.textLight,
              fontSize: 14,
            ),
          ),
          if (isCurrent) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('الآن', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900)),
            ),
          ],
        ],
      ),
    );
  }
}
