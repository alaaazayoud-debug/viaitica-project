import 'package:flutter/material.dart';

/// مفتاح Navigator عالمي للتمكن من التنقل من أي مكان (مثل interceptor).
/// يُستخدم في ApiService عند انتهاء صلاحية التوكن لتوجيه المستخدم لشاشة الدخول.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
