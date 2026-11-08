import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

// معالجة الإشعارات عندما يكون التطبيق في الخلفية (Background/Terminated)
// يجب أن تكون الدالة top-level أو static.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final Logger logger = Logger();
  logger.i('Handling a background message: ${message.messageId}');
}

class NotificationService {
  static String? fcmToken;
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  Future<void> initialize() async {
    print('NotificationService: initialize() called');
    // 1. طلب الإذن (مهم جداً للـ iOS والأندرويد 13+)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _logger.i('User granted notification permission');
    } else {
      _logger.w('User declined or has not accepted notification permission');
    }

    // 2. الحصول على التوكن (FCM Token) وطباعته
    try {
      fcmToken = await _firebaseMessaging.getToken();
      print('=== FCM Token ===');
      print(fcmToken);
      _logger.i('FCM Token: $fcmToken');
      // TODO: إرسال التوكن إلى السيرفر الخاص بنا ليتم ربطه بالمستخدم الحالي
    } catch (e) {
      print('=== FCM Token Error ===');
      print(e.toString());
      _logger.e('Failed to get FCM token: $e');
    }

    // 3. تهيئة Flutter Local Notifications للإشعارات أثناء استخدام التطبيق (Foreground)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // إعدادات الـ iOS الافتراضية
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _logger.i('Notification clicked: ${response.payload}');
        // هنا يمكن توجيه المستخدم لشاشة معينة بناءً على الـ payload
      },
    );

    // 4. معالجة الإشعارات
    
    // أ) في الـ Foreground (أثناء الاستخدام)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.i('Got a message whilst in the foreground!');
      _logger.i('Message data: ${message.data}');

      if (message.notification != null) {
        _logger.i('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });

    // ب) معالجة الضغط على الإشعار من الخلفية (App is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.i('A new onMessageOpenedApp event was published!');
      _logger.i('Message data: ${message.data}');
      // التوجيه عبر GoRouter ممكن هنا باستخدام navigatorKey
    });

    // ج) تسجيل الـ Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'high_importance_channel', // id
        'High Importance Notifications', // name
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
        payload: message.data.toString(), // حفظ البيانات الإضافية للتوجيه لاحقاً
      );
    }
  }
}
