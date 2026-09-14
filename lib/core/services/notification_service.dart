import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../api/api_manager.dart';
import '../api/endpoints.dart';
import '../di/di.dart';
import '../routes_manager/route_generator.dart';
import '../routes_manager/routes.dart';
import '../storage/secure_storage_service.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('FCM Background message received: ${message.messageId}, data: ${message.data}');

  // If backend sent a data-only payload, display local notification in background
  if (message.notification == null) {
    try {
      final flutterLocalNotifications = FlutterLocalNotificationsPlugin();
      await flutterLocalNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      final title = message.data['title'] ?? 'طلب جديد';
      final body = message.data['body'] ?? 'يوجد طلب جديد متاح للاستلام';
      await flutterLocalNotifications.show(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'إشعارات هامة',
            channelDescription: 'قناة التنبيهات الفورية والطلبات الجديدة للمندوب',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      debugPrint('Error showing background local notification: $e');
    }
  }
}

const AndroidNotificationChannel _highImportanceChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'إشعارات هامة',
  description: 'قناة التنبيهات الفورية والطلبات الجديدة للمندوب',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initializes FCM and local notifications
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Set background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 2. Request notification permissions (FCM)
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('FCM Authorization status: ${settings.authorizationStatus}');

      // 3. Foreground presentation options (iOS)
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 4. Initialize FlutterLocalNotifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: androidSettings,
          iOS: darwinSettings,
        ),
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          if (response.payload != null && response.payload!.isNotEmpty) {
            try {
              final data = jsonDecode(response.payload!) as Map<String, dynamic>;
              _handleNotificationNavigation(data);
            } catch (e) {
              debugPrint('Error parsing notification payload: $e');
            }
          }
        },
      );

      // 5. Create High Importance channel & request Android 13+ permission
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(_highImportanceChannel);
        final granted = await androidImplementation.requestNotificationsPermission();
        debugPrint('Android 13+ Notification Permission granted: $granted');
      }

      // 6. Listen for foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Foreground message received: ${message.notification?.title} | data: ${message.data}');
        _showForegroundNotification(message);
      });

      // 7. Listen for messages when app opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM Notification tapped (from background): ${message.data}');
        _handleNotificationNavigation(message.data);
      });

      // 8. Check if app was launched from a terminated notification
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('FCM Notification tapped (from terminated): ${initialMessage.data}');
        // Delay navigation slightly to let the widget tree build
        Future.delayed(const Duration(milliseconds: 600), () {
          _handleNotificationNavigation(initialMessage.data);
        });
      }

      // 9. Listen for token refreshes
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        sendTokenToBackend(forceToken: newToken);
      });

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');

      // Attempt to send token if user is already authenticated as delegate
      await sendTokenToBackend();
    } catch (e, stack) {
      debugPrint('Error initializing NotificationService: $e\n$stack');
    }
  }

  /// Displays a heads-up local notification when the app is in the foreground
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final title = notification?.title ?? message.data['title'] ?? 'طلب جديد';
      final body = notification?.body ?? message.data['body'] ?? 'يوجد طلب جديد متاح للاستلام';
      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await _localNotifications.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _highImportanceChannel.id,
            _highImportanceChannel.name,
            channelDescription: _highImportanceChannel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
      debugPrint('Local notification displayed: ID=$notificationId, Title=$title');
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  /// Handles navigation when the user taps on a notification
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    if (data.isEmpty) return;

    final type = data['type']?.toString();
    final orderId = data['orderId']?.toString();
    debugPrint('Navigating based on notification: type=$type, orderId=$orderId');

    final nav = RouteGenerator.navigatorKey.currentState;
    if (nav == null) {
      debugPrint('Navigator state is null, cannot navigate');
      return;
    }

    if (type == 'new_order') {
      // Navigate to available pickup orders for delegates
      nav.pushNamed(Routes.delegateAvailableOrdersRoute);
    } else if (type == 'new_order_admin') {
      // Navigate to admin home screen
      nav.pushNamed(Routes.adminHomeRoute);
    } else if (type == 'new_order_center') {
      // Navigate to center order details if orderId is provided, otherwise center home
      if (orderId != null && orderId.isNotEmpty) {
        nav.pushNamed(
          Routes.centerOrderDetailsRoute,
          arguments: orderId,
        );
      } else {
        nav.pushNamed(Routes.centerHomeRoute);
      }
    } else if (orderId != null && orderId.isNotEmpty) {
      // Navigate to tracking/details screen for specific order
      nav.pushNamed(
        Routes.orderTrackingRoute,
        arguments: orderId,
      );
    }
  }

  /// Sends the current FCM device token to the backend based on user role:
  /// - Delegate: POST /delegate/push-tokens
  /// - Center:   POST /centers/push-tokens
  /// - Admin:    POST /admin/push-tokens
  Future<void> sendTokenToBackend({String? forceToken}) async {
    try {
      final secureStorage = getIt<SecureStorageService>();
      final isLoggedIn = await secureStorage.isLoggedIn();
      if (!isLoggedIn) {
        debugPrint('Skipping sendTokenToBackend: User is not logged in');
        return;
      }

      final role = (await secureStorage.getUserRole())?.toLowerCase();
      String? endpoint;

      switch (role) {
        case 'delegate':
          endpoint = Endpoints.delegatePushTokens;
          break;
        case 'center':
          endpoint = Endpoints.centerPushTokens;
          break;
        case 'admin':
          endpoint = Endpoints.adminPushTokens;
          break;
        default:
          debugPrint('Skipping sendTokenToBackend: User role is "$role", push token registration not required');
          return;
      }

      final token = forceToken ?? await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('Skipping sendTokenToBackend: FCM token is null or empty');
        return;
      }

      debugPrint('========================================================');
      debugPrint('🔥 FCM TOKEN FOR THIS DEVICE (Role: $role):');
      debugPrint(token);
      debugPrint('========================================================');

      final apiManager = getIt<ApiManager>();
      final response = await apiManager.PostDate(
        endpoint,
        body: {'token': token},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Push token successfully registered for $role on backend');
      } else {
        debugPrint('Failed to register push token for $role: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      debugPrint('Error sending push token to backend: $e');
    }
  }
}
