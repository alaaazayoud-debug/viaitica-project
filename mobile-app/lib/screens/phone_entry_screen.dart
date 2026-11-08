import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dighri_customer/constants/app_colors.dart';
import 'package:dighri_customer/services/api_service.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 9) {
      setState(() => _errorMessage = 'الرجاء إدخال رقم هاتف صحيح');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await ApiService().sendOtp(phone);
      if (mounted) {
        final isNew = result['isNewUser'] ?? false;
        final hasProfile = result['hasCompletedProfile'] ?? false;
        final userStatus = result['userStatus'] ?? 'pending_review';
        context.push('/otp?phone=$phone&isNewUser=$isNew&hasProfile=$hasProfile&userStatus=$userStatus');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // ═══ الشعار والترحيب ═══
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.local_pharmacy_rounded, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 32),

              const Text(
                'مرحباً بك في فارمجي',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'سجّل دخولك برقم هاتفك للبدء',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textLight.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 48),

              // ═══ حقل الهاتف ═══
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '09XX XXX XXX',
                    hintStyle: TextStyle(
                      color: AppColors.textLight.withValues(alpha: 0.3),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🇸🇾', style: TextStyle(fontSize: 24)),
                          SizedBox(width: 8),
                          Text('+963', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                        ],
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                    errorText: _errorMessage,
                    errorStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onSubmitted: (_) => _sendOtp(),
                ),
              ),

              const SizedBox(height: 24),

              // ═══ زر الإرسال ═══
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'متابعة',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                ),
              ),

              const SizedBox(height: 40),

              // ═══ نص أسفل الشاشة ═══
              Text(
                'سيتم إرسال رمز تحقق إلى هاتفك',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
