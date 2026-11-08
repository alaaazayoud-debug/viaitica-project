import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:dighri_customer/constants/app_colors.dart';
import 'package:dighri_customer/services/api_service.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with SingleTickerProviderStateMixin {
  final Logger _logger = Logger();
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  String phone = '';
  String pharmacyName = '';
  String? _errorMessage;
  bool _isVerifying = false;
  int _seconds = 30;
  Timer? _timer;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  void _startCountdown() {
    _seconds = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds--;
        if (_seconds <= 0) {
          timer.cancel();
        }
      });
    });
  }

  bool isNewUser = true;
  bool hasCompletedProfile = false;
  String userStatus = 'pending_review';
  double? lat;
  double? lng;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = GoRouterState.of(context).uri;
    phone = uri.queryParameters['phone'] ?? '';
    pharmacyName = uri.queryParameters['pharmacy'] ?? '';
    
    // Parse routing flags from sendOTP response
    final isNewParam = uri.queryParameters['isNewUser'];
    _logger.d('isNewParam from URL: $isNewParam');
    if (isNewParam != null) {
      isNewUser = isNewParam == 'true';
    }
    
    final hasProfileParam = uri.queryParameters['hasProfile'];
    if (hasProfileParam != null) {
      hasCompletedProfile = hasProfileParam == 'true';
    }
    
    final statusParam = uri.queryParameters['userStatus'];
    if (statusParam != null) {
      userStatus = statusParam;
    }
    _logger.d('isNewUser: $isNewUser, hasProfile: $hasCompletedProfile, status: $userStatus');
    
    if (uri.queryParameters['lat'] != null) {
      lat = double.tryParse(uri.queryParameters['lat']!);
    }
    if (uri.queryParameters['lng'] != null) {
      lng = double.tryParse(uri.queryParameters['lng']!);
    }
  }

  Future<void> _verifyCode() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 4) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      // Send optional registration data if available
      final token = await ApiService().verifyOtp(
        phone, 
        code,
        name: pharmacyName.isNotEmpty ? pharmacyName : null,
        lat: lat,
        lng: lng,
      );
      
      _logger.i('Token received: $token'); 
      
      if (mounted) {
        if (isNewUser && !hasCompletedProfile) {
          // Truly new user — needs to fill profile
          GoRouter.of(context).go('/complete-profile');
        } else if (hasCompletedProfile && userStatus == 'pending_review') {
          // Returning user who completed profile but not yet verified
          GoRouter.of(context).go('/waiting');
        } else if (userStatus == 'verified') {
          // Verified user — go to home
          GoRouter.of(context).go('/home');
        } else {
          // Fallback: check with getMe
          GoRouter.of(context).go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
        // هز الحقول عند الخطأ
        _shakeController.forward().then((_) => _shakeController.reverse());
        HapticFeedback.mediumImpact();
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (value.length == 1 && index == 3) {
      _verifyCode();
    }
    // مسح الخطأ عند الكتابة
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('رمز التحقق', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          reverse: true,
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // أيقونة
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sms_outlined, color: AppColors.primary, size: 36),
              ),
              const SizedBox(height: 24),

              Text(
                'أدخل رمز التحقق',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 14, color: AppColors.textLight.withValues(alpha: 0.7), fontFamily: 'Tajawal'),
                  children: [
                    const TextSpan(text: 'تم إرسال رمز التحقق إلى الرقم\n'),
                    TextSpan(
                      text: phone,
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.text, fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ═══ حقول OTP مع Shake Animation ═══
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (i) => Container(
                      width: 64,
                      height: 72,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: _errorMessage != null
                              ? AppColors.danger.withValues(alpha: 0.05)
                              : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: _errorMessage != null ? AppColors.danger : AppColors.grey,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: _errorMessage != null ? AppColors.danger : AppColors.grey,
                              width: _errorMessage != null ? 2 : 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (val) => _onChanged(val, i),
                      ),
                    ),
                  ),
                ),
              ),

              // رسالة الخطأ
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // ═══ زر التحقق ═══
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('تحقق من الرمز', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                ),
              ),

              const SizedBox(height: 24),

              // ═══ العد التنازلي / إعادة الإرسال ═══
              if (_seconds > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_outlined, size: 16, color: AppColors.textLight.withValues(alpha: 0.5)),
                    const SizedBox(width: 6),
                    Text(
                      'إعادة الإرسال خلال $_seconds ثانية',
                      style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                )
              else
                TextButton.icon(
                  onPressed: () async {
                    try {
                      await ApiService().sendOtp(phone);
                      for (final c in _controllers) {
                        c.clear();
                      }
                      _startCountdown();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('تم إعادة الإرسال بنجاح ✅'),
                            backgroundColor: AppColors.emerald,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() => _errorMessage = 'فشل الإرسال: $e');
                      }
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('إعادة إرسال الرمز', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
