import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dighri_customer/services/api_service.dart';
import 'package:dighri_customer/constants/app_colors.dart';
import 'package:dighri_customer/widgets/shimmer_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;
  final bool _isAutoScrolling = true;

  List<dynamic> _offers = [];
  bool _isLoadingOffers = true;
  List<dynamic> _feeds = [];
  bool _isLoadingFeeds = true;
  List<dynamic> _notifications = [];
  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadOffers(),
      _loadFeeds(),
      _loadProfile(),
      _loadNotifications(),
    ]);
  }

  Future<void> _loadFeeds() async {
    try {
      final feeds = await ApiService().getFeeds();
      if (mounted) {
        setState(() {
          _feeds = feeds;
          _isLoadingFeeds = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingFeeds = false);
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await ApiService().getNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
        });
      }
    } catch (e) {
      // ignore errors since we don't display a loading state for notifications
    }
  }

  Future<void> _loadProfile() async {
    try {
      final user = await ApiService().getMe();
      if (mounted) {
        setState(() {
          _userProfile = user;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _loadOffers() async {
    try {
      final offers = await ApiService().getOffers();
      if (mounted) {
        setState(() {
          _offers = offers;
          _isLoadingOffers = false;
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingOffers = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_offers.isEmpty) return;
    
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (_isAutoScrolling && _pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _offers.length) nextPage = 0;
        
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuart,
        );
      }
    });
  }

  void _handleManualSwipe(int index) {
    setState(() {
      _currentPage = index;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await ApiService().logout();
    if (mounted) {
      context.go('/phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          // 💎 Elite Personalized Header
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.midnightGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Subtle background pattern or circle
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.white24,
                                      radius: 20,
                                      child: const Icon(Icons.person_outline, color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _isLoadingProfile ? 'مرحباً بك' : 'أهلاً د. ${_userProfile?['name'] ?? 'صيدلاني'}',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        Text(
                                          _userProfile?['pharmacyName'] ?? 'صيدلية فياتيكا',
                                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final unreadCount = _notifications.where((n) => n['read'] == false).length;
                                        return Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                                              onPressed: () => context.push('/notifications'),
                                            ),
                                            if (unreadCount > 0)
                                              Positioned(
                                                top: 10,
                                                left: 10,
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                                  child: Text(
                                                    unreadCount.toString(),
                                                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                                      onPressed: _logout,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom search bar that slides up
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: InkWell(
                    onTap: () => context.push('/catalog'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Text('ماذا تحتاج لصيدليتك اليوم؟', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // 🛡️ Verification Banner (Conditional)
                  if (_userProfile != null && _userProfile!['isVerified'] == false)
                    _buildVerificationBanner(),
                    
                  // 🎁 Premium Offers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('أفضل العروض', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                      TextButton(
                        onPressed: () => context.push('/offers'),
                        child: const Text('المزيد', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 170,
                    child: _isLoadingOffers 
                    ? ShimmerLoading(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      )
                    : _offers.isEmpty 
                      ? Center(child: Text('لا توجد عروض حالياً', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5))))
                      : PageView.builder(
                          itemCount: _offers.length,
                          controller: _pageController,
                          onPageChanged: _handleManualSwipe,
                          itemBuilder: (context, index) {
                            final offer = _offers[index];
                            return _buildOfferCard(offer);
                          },
                        ),
                  ),

                  const SizedBox(height: 30),

                  // 📰 Viatica Feed (News & Warnings)
                  const Text('نبض فارمجي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  const SizedBox(height: 12),
                  if (_isLoadingFeeds)
                    ShimmerLoading(
                      child: SizedBox(
                        height: 180,
                        child: Row(
                          children: [
                            Expanded(child: Container(
                              margin: const EdgeInsets.only(left: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            )),
                          ],
                        ),
                      ),
                    )
                  else if (_feeds.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Center(child: Text('لا توجد نشرات حالياً', style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5)))),
                    )
                  else
                    SizedBox(
                      height: 180, // Height for horizontal cards
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _feeds.length,
                        itemBuilder: (context, index) {
                          return _buildFeedItem(_feeds[index]);
                        },
                      ),
                    ),

                  const SizedBox(height: 30),

                  // 📂 Smart Categories
                  const Text('الأصناف الدوائية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCategoryItem(context, 'مضادات', Icons.biotech_outlined, AppColors.primary, 'antibiotic'),
                      _buildCategoryItem(context, 'مسكنات', Icons.healing_outlined, Colors.pink.shade400, 'analgesic'),
                      _buildCategoryItem(context, 'فيتامينات', Icons.bolt_outlined, Colors.amber.shade600, 'other'),
                      _buildCategoryItem(context, 'المزيد', Icons.dashboard_customize_outlined, Colors.blueGrey.shade400, null),
                    ],
                  ),

                  const SizedBox(height: 35),

                  // 📊 Command Center (Quick Actions)
                  const Text('مركز الإدارة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  _buildPremiumActionCard(
                    context,
                    'نقطة البيع (كاشير) 📸',
                    'فاتورة جديدة، امسح الباركود بالكاميرا وسجل أرباحك فوراً',
                    Icons.point_of_sale,
                    Colors.orange.shade600,
                    () => context.push('/pos'),
                    badge: 'جديد ومهم',
                  ),
                  const SizedBox(height: 12),
                  _buildPremiumActionCard(
                    context,
                    'إحصائيات المخزن',
                    'دقة عالية في تتبع الأدوية وتواريخ انتهاء الصلاحية',
                    Icons.inventory_2_outlined,
                    AppColors.emerald,
                    () => context.push('/inventory'),
                    badge: 'مُحدَّث',
                  ),
                  const SizedBox(height: 12),
                  _buildPremiumActionCard(
                    context,
                    'سجل الحساب المادي',
                    'راجع جميع الديون والمستحقات والطلبات السابقة',
                    Icons.account_balance_wallet_outlined,
                    AppColors.primary,
                    () => context.push('/ledger'),
                  ),
                  const SizedBox(height: 12),
                  _buildPremiumActionCard(
                    context,
                    'طلباتي الحالية',
                    'تتبع حركة الطلبات من المستودع إلى باب الصيدلية',
                    Icons.local_shipping_outlined,
                    AppColors.accent,
                    () => context.push('/orders'),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(dynamic offer) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1587854692152-cbe660dbbb88?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              offer['title']?.toString() ?? 'عرض الحصري', 
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)
            ),
            const SizedBox(height: 4),
            Text(
              offer['subtitle']?.toString() ?? 'سعر منافس لأفضل حزمة أدوية',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w500)
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('احصل عليه الآن', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String label, IconData icon, Color color, String? categoryId) {
    return InkWell(
      onTap: () => categoryId != null ? context.push('/catalog?category=$categoryId') : context.push('/catalog'),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        ],
      ),
    );
  }

  Widget _buildPremiumActionCard(BuildContext context, String title, String sub, IconData icon, Color color, VoidCallback onTap, {String? badge}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.5)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.emerald.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(badge, style: const TextStyle(color: AppColors.emerald, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(sub, style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.textLight.withValues(alpha: 0.3), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade600, Colors.orange.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.verified_user_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'حسابك قيد المراجعة',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  'يرجى رفع ترخيص الصيدلية ليتم تفعيل حسابك والوصول لكافة الميزات.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedItem(dynamic feed) {
    Color typeColor = AppColors.primary;
    IconData typeIcon = Icons.article_outlined;
    String typeLabel = 'خبر';

    if (feed['type'] == 'warning') {
      typeColor = AppColors.danger;
      typeIcon = Icons.warning_amber_rounded;
      typeLabel = 'تحذير طبي';
    } else if (feed['type'] == 'tip') {
      typeColor = AppColors.emerald;
      typeIcon = Icons.lightbulb_outline;
      typeLabel = 'نصيحة';
    } else if (feed['type'] == 'update') {
      typeColor = Colors.indigo;
      typeIcon = Icons.info_outline;
      typeLabel = 'تحديث نظام';
    }

    return GestureDetector(
      onTap: () {
        context.push('/feed-details', extra: feed);
      },
      child: Container(
        width: 280, // Fixed width for horizontal scroll
        margin: const EdgeInsets.only(left: 16), // space between cards
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: typeColor.withValues(alpha: 0.15), width: 1.5),
          boxShadow: [
            BoxShadow(color: typeColor.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(typeIcon, color: typeColor, size: 12),
                      const SizedBox(width: 4),
                      Text(typeLabel, style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              feed['title'] ?? '', 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.5, height: 1.3)
            ),
            const SizedBox(height: 8),
            Text(
              feed['content'] ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.8), fontSize: 12, height: 1.5),
            ),
            const Spacer(),
            if (feed['createdBy'] != null)
              Text(
                'من: ${feed['createdBy']['pharmacyName'] ?? feed['createdBy']['name'] ?? 'الإدارة'}',
                style: const TextStyle(color: AppColors.textLight, fontSize: 10, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
