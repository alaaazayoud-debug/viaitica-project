import 'package:flutter/material.dart';
import 'package:dighri_customer/constants/app_colors.dart';

/// ويدجت Shimmer متحرك لإظهار حالة التحميل بشكل احترافي.
/// يُستخدم بدلاً من CircularProgressIndicator.
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  const ShimmerLoading({super.key, required this.child});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// صندوق Shimmer — مستطيل رمادي متحرك
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer لبطاقة دواء واحدة في الكتالوج
class ShimmerDrugCard extends StatelessWidget {
  const ShimmerDrugCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const ShimmerBox(width: 70, height: 70, borderRadius: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: MediaQuery.of(context).size.width * 0.35, height: 16),
                  const SizedBox(height: 8),
                  const ShimmerBox(width: 100, height: 12),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      ShimmerBox(width: 60, height: 18, borderRadius: 6),
                      SizedBox(width: 6),
                      ShimmerBox(width: 50, height: 18, borderRadius: 6),
                    ],
                  ),
                ],
              ),
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ShimmerBox(width: 60, height: 14),
                SizedBox(height: 12),
                ShimmerBox(width: 36, height: 36, borderRadius: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer لبطاقة طلب واحدة
class ShimmerOrderCard extends StatelessWidget {
  const ShimmerOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 140, height: 16),
                    SizedBox(height: 6),
                    ShimmerBox(width: 100, height: 11),
                  ],
                ),
                ShimmerBox(width: 80, height: 28, borderRadius: 10),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                const ShimmerBox(width: 40, height: 40, borderRadius: 12),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: 120, height: 14),
                      SizedBox(height: 4),
                      ShimmerBox(width: 160, height: 11),
                    ],
                  ),
                ),
                const ShimmerBox(width: 70, height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer لبطاقة عرض واحدة
class ShimmerOfferCard extends StatelessWidget {
  const ShimmerOfferCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const ShimmerBox(width: double.infinity, height: 80, borderRadius: 0),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: 200, height: 14),
                  SizedBox(height: 8),
                  ShimmerBox(width: 150, height: 12),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox(width: 100, height: 12),
                      ShimmerBox(width: 100, height: 36, borderRadius: 12),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer لبطاقة مستودع واحدة
class ShimmerWarehouseCard extends StatelessWidget {
  const ShimmerWarehouseCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.5)),
        ),
        child: const Row(
          children: [
            ShimmerBox(width: 60, height: 60, borderRadius: 16),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 160, height: 16),
                  SizedBox(height: 6),
                  ShimmerBox(width: 120, height: 11),
                ],
              ),
            ),
            ShimmerBox(width: 16, height: 16),
          ],
        ),
      ),
    );
  }
}

/// Shimmer لسجل مالي واحد
class ShimmerLedgerCard extends StatelessWidget {
  const ShimmerLedgerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            ShimmerBox(width: 36, height: 36, borderRadius: 18),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 140, height: 14),
                  SizedBox(height: 4),
                  ShimmerBox(width: 100, height: 11),
                ],
              ),
            ),
            ShimmerBox(width: 80, height: 14),
          ],
        ),
      ),
    );
  }
}

/// Shimmer لإشعار واحد
class ShimmerNotificationCard extends StatelessWidget {
  const ShimmerNotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 40, height: 40, borderRadius: 12),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 120, height: 14),
                  SizedBox(height: 6),
                  ShimmerBox(width: double.infinity, height: 12),
                  SizedBox(height: 8),
                  ShimmerBox(width: 80, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer للشاشة الرئيسية — الأقسام المتعددة
class ShimmerHomeSection extends StatelessWidget {
  const ShimmerHomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offers shimmer
            const ShimmerBox(width: 120, height: 18),
            const SizedBox(height: 12),
            const ShimmerBox(width: double.infinity, height: 170, borderRadius: 24),
            const SizedBox(height: 30),
            // Feed shimmer
            const ShimmerBox(width: 100, height: 18),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: Row(
                children: const [
                  Expanded(child: ShimmerBox(width: 280, height: 180, borderRadius: 20)),
                  SizedBox(width: 16),
                  Expanded(child: ShimmerBox(width: 280, height: 180, borderRadius: 20)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Categories shimmer
            const ShimmerBox(width: 130, height: 18),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 64, height: 80, borderRadius: 20),
                ShimmerBox(width: 64, height: 80, borderRadius: 20),
                ShimmerBox(width: 64, height: 80, borderRadius: 20),
                ShimmerBox(width: 64, height: 80, borderRadius: 20),
              ],
            ),
            const SizedBox(height: 35),
            // Action cards shimmer
            const ShimmerBox(width: 110, height: 18),
            const SizedBox(height: 16),
            ...List.generate(3, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: const ShimmerBox(width: double.infinity, height: 80, borderRadius: 24),
            )),
          ],
        ),
      ),
    );
  }
}
