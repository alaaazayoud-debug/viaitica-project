import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dighri_customer/constants/app_colors.dart';
import 'package:dighri_customer/services/cart_service.dart';

class AnimatedCartBadge extends StatefulWidget {
  const AnimatedCartBadge({super.key});

  @override
  State<AnimatedCartBadge> createState() => _AnimatedCartBadgeState();
}

class _AnimatedCartBadgeState extends State<AnimatedCartBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.elasticIn)), weight: 50),
    ]).animate(_controller);

    CartService().addListener(_onCartChanged);
  }

  void _onCartChanged() {
    final currentCount = CartService().items.fold<int>(0, (sum, item) => sum + item.quantity);
    if (currentCount > _previousCount) {
      _controller.forward(from: 0.0);
    }
    _previousCount = currentCount;
  }

  @override
  void dispose() {
    CartService().removeListener(_onCartChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartService(),
      builder: (context, _) {
        final itemCount = CartService().items.fold<int>(0, (sum, item) => sum + item.quantity);
        
        return IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: const Icon(Icons.shopping_cart_outlined, size: 24),
              ),
              if (itemCount > 0)
                Positioned(
                  right: -4,
                  top: -6,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Center(
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () => context.push('/cart'),
        );
      },
    );
  }
}
