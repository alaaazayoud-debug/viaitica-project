import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:dighri_customer/services/api_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final Logger _logger = Logger();

  // Phase controllers for sequenced animations
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  // Logo animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotation;

  // Text animations
  late Animation<double> _brandOpacity;
  late Animation<Offset> _brandSlide;
  late Animation<double> _taglineOpacity;

  // Pulse glow
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSequence();
  }

  void _initAnimations() {
    // Phase 1: Logo entrance (0 → 1.5s)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Subtle rotation for a dynamic feel
    _logoRotation = Tween<double>(begin: -0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Phase 2: Text entrance (delayed)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _brandOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _brandSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    // Phase 3: Pulse glow (continuous)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Phase 4: Particles
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  Future<void> _startSequence() async {
    // Wait for the screen to render
    await Future.delayed(const Duration(milliseconds: 300));

    // Phase 1: Logo entrance
    _logoController.forward();

    // Phase 2: Text entrance (after logo settles)
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    // Phase 3: Wait for full animation then navigate
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await ApiService().getToken();
    _logger.d('Checking token: ${token != null ? "Found" : "Not Found"}');

    if (token == null) {
      if (mounted) GoRouter.of(context).go('/phone');
      return;
    }

    try {
      // Try to get user data
      final user = await ApiService().getMe();
      if (!mounted) return;

      _logger.i('User verified: ${user['phone']} - Status: ${user['status']}');

      // logic for routing based on user state
      final hasCompletedProfile = user['pharmacyName'] != null &&
          user['pharmacyName'] != '' &&
          user['name'] != 'مستخدم جديد';

      if (!hasCompletedProfile) {
        GoRouter.of(context).go('/complete-profile');
      } else if (user['status'] == 'pending_review') {
        GoRouter.of(context).go('/waiting');
      } else {
        GoRouter.of(context).go('/home');
      }
    } catch (e) {
      _logger.e('Splash check failed: $e');
      
      if (mounted) {
        // If it's a 401 (Unauthorized), then and ONLY then we go to login
        if (e.toString().contains('401')) {
          _logger.w('Token invalid (401) - Redirecting to login');
          GoRouter.of(context).go('/phone');
        } else {
          // For other errors (Timeout, Server 500, etc.), try to go home 
          // and let the specific screen handle future API failures
          _logger.w('Network/Server error but token exists - proceeding to home');
          GoRouter.of(context).go('/home');
        }
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1628), // Ultra-deep midnight
              Color(0xFF122B5E), // Deep blue
              Color(0xFF1E3A8A), // Primary blue
              Color(0xFF0D3B66), // Teal-blue transition
            ],
            stops: [0.0, 0.3, 0.65, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ═══ Floating Particles ═══
            ...List.generate(12, (i) => _buildFloatingParticle(i)),

            // ═══ Decorative Gradient Orbs ═══
            Positioned(
              top: -100,
              right: -60,
              child: AnimatedBuilder(
                animation: _pulseScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseScale.value,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF1E3A8A).withValues(alpha: 0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: AnimatedBuilder(
                animation: _pulseScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 2.0 - _pulseScale.value,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF10B981).withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ═══ Main Content ═══
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo with glow effect
                  AnimatedBuilder(
                    animation: Listenable.merge([_logoController, _pulseController]),
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _logoRotation.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow ring behind logo
                                Container(
                                  width: 200 * _pulseScale.value,
                                  height: 200 * _pulseScale.value,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                        blurRadius: 60,
                                        spreadRadius: 10,
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                                        blurRadius: 80,
                                        spreadRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                // Actual logo
                                SizedBox(
                                  width: 160,
                                  height: 160,
                                  child: SvgPicture.asset(
                                    'assets/images/pharmajy_logo.svg',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 48),

                  // Brand name
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _brandSlide,
                        child: Opacity(
                          opacity: _brandOpacity.value,
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return const LinearGradient(
                                colors: [Colors.white, Color(0xFFB8D4FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'Pharmajy',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 3,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // Tagline with border
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _taglineOpacity.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF10B981).withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Text(
                            'PHARMACY  TECH',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                              letterSpacing: 6,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ═══ Bottom Loading Indicator ═══
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _taglineOpacity.value,
                    child: Column(
                      children: [
                        // Custom animated dots loader
                        _buildDotsLoader(),
                        const SizedBox(height: 14),
                        Text(
                          'جاري التحميل...',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.35),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══ Animated Dots Loader ═══
  Widget _buildDotsLoader() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final offset = (_particleController.value * 3 - i).clamp(0.0, 1.0);
            final scale = 0.5 + (math.sin(offset * math.pi) * 0.5);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(
                  const Color(0xFF1E3A8A),
                  const Color(0xFF10B981),
                  offset,
                )!.withValues(alpha: 0.3 + scale * 0.5),
              ),
            );
          }),
        );
      },
    );
  }

  // ═══ Floating Particles ═══
  Widget _buildFloatingParticle(int index) {
    final rng = math.Random(index * 42);
    final startX = rng.nextDouble();
    final startY = rng.nextDouble();
    final size = 2.0 + rng.nextDouble() * 4;
    final speed = 0.3 + rng.nextDouble() * 0.7;
    final isGreen = rng.nextBool();

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final progress = (_particleController.value * speed) % 1.0;
        final x = startX + math.sin(progress * math.pi * 2) * 0.03;
        final y = (startY - progress * 0.3) % 1.0;
        final opacity = (math.sin(progress * math.pi) * 0.4).clamp(0.0, 0.35);

        return Positioned(
          left: x * MediaQuery.of(context).size.width,
          top: y * MediaQuery.of(context).size.height,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isGreen
                      ? const Color(0xFF10B981)
                      : const Color(0xFF60A5FA))
                  .withValues(alpha: opacity),
            ),
          ),
        );
      },
    );
  }
}