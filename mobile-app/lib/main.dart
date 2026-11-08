import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dighri_customer/services/notification_service.dart';
import 'package:go_router/go_router.dart';
import 'package:dighri_customer/core/navigator_key.dart';
import 'package:dighri_customer/constants/app_theme.dart';
import 'package:dighri_customer/screens/main_layout_screen.dart';
import 'package:dighri_customer/screens/medicine_catalog_screen.dart';
import 'package:dighri_customer/screens/otp_screen.dart';
import 'package:dighri_customer/screens/phone_entry_screen.dart';
import 'package:dighri_customer/screens/splash_screen.dart';
import 'package:dighri_customer/screens/cart_screen.dart';
import 'package:dighri_customer/screens/my_orders_screen.dart';
import 'package:dighri_customer/screens/order_details_screen.dart';
import 'package:dighri_customer/screens/complete_profile_screen.dart';
import 'package:dighri_customer/screens/waiting_approval_screen.dart';
import 'package:dighri_customer/screens/offers_screen.dart';
import 'package:dighri_customer/screens/drug_detail_screen.dart';
import 'package:dighri_customer/screens/pharmacist_inventory_screen.dart';
import 'package:dighri_customer/screens/ledger_screen.dart';
import 'package:dighri_customer/screens/feed_details_screen.dart';
import 'package:dighri_customer/screens/notifications_screen.dart';
import 'package:dighri_customer/screens/pos_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. تهيئة فايربيس
  await Firebase.initializeApp();
  
  // 2. تهيئة خدمة الإشعارات
  await NotificationService().initialize();

  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/phone',
      builder: (context, state) => const PhoneEntryScreen(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainLayoutScreen(),
    ),
    GoRoute(
      path: '/catalog',
      builder: (context, state) {
        final category = state.uri.queryParameters['category'];
        final warehouseId = state.uri.queryParameters['warehouseId'];
        return MedicineCatalogScreen(initialCategory: category, warehouseId: warehouseId);
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const MyOrdersScreen(),
    ),
    GoRoute(
      path: '/orders/:id',
      builder: (context, state) => OrderDetailsScreen(orderId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/complete-profile',
      builder: (context, state) => const CompleteProfileScreen(),
    ),
    GoRoute(
      path: '/waiting',
      builder: (context, state) => const WaitingApprovalScreen(),
    ),
    GoRoute(
      path: '/offers',
      builder: (context, state) => const OffersScreen(),
    ),
    GoRoute(
      path: '/drug-detail',
      builder: (context, state) {
        if (state.extra == null) {
          return const Scaffold(body: Center(child: Text('عذراً، لم يتم العثور على الدواء')));
        }
        return DrugDetailScreen(drug: state.extra);
      },
    ),
    GoRoute(
      path: '/inventory',
      builder: (context, state) => const PharmacistInventoryScreen(),
    ),
    GoRoute(
      path: '/ledger',
      builder: (context, state) => const LedgerScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/feed-details',
      builder: (context, state) {
        final feed = state.extra;
        return FeedDetailsScreen(feed: feed);
      },
    ),
    GoRoute(
      path: '/pos',
      builder: (context, state) => const POSScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      key: navigatorKey,
      title: 'Farmaji - فارمجي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
