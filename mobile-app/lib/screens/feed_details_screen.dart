import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dighri_customer/constants/app_colors.dart';

class FeedDetailsScreen extends StatelessWidget {
  final dynamic feed;

  const FeedDetailsScreen({super.key, required this.feed});

  @override
  Widget build(BuildContext context) {
    Color typeColor = AppColors.primary;
    IconData typeIcon = Icons.article_outlined;
    String typeLabel = 'خبر حصري';

    if (feed['type'] == 'warning') {
      typeColor = AppColors.danger;
      typeIcon = Icons.warning_amber_rounded;
      typeLabel = 'تحذير طبي هام';
    } else if (feed['type'] == 'tip') {
      typeColor = AppColors.emerald;
      typeIcon = Icons.lightbulb_outline;
      typeLabel = 'نصيحة طبية';
    } else if (feed['type'] == 'update') {
      typeColor = Colors.indigo;
      typeIcon = Icons.info_outline;
      typeLabel = 'تحديث نظام';
    }

    final createdAt = feed['createdAt'] != null 
        ? DateTime.parse(feed['createdAt'].toString()).toLocal().toString().substring(0, 10)
        : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: typeColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [typeColor.withValues(alpha: 0.8), typeColor.withValues(alpha: 1.0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Icon(typeIcon, size: 250, color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(typeIcon, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                typeLabel,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -20, 0),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feed['title'] ?? 'بدون عنوان',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Meta bar
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textLight.withValues(alpha: 0.8)),
                      const SizedBox(width: 6),
                      Text(
                        createdAt,
                        style: TextStyle(fontSize: 12, color: AppColors.textLight.withValues(alpha: 0.8), fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (feed['createdBy'] != null) ...[
                        const Icon(Icons.verified_user, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          feed['createdBy']['pharmacyName'] ?? 'الإدارة',
                          style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ]
                    ],
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(color: AppColors.grey),
                  ),
                  
                  // Content
                  Text(
                    feed['content'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textLight,
                      height: 1.8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
