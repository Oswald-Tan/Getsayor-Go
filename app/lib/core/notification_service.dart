import 'dart:async';
import 'dart:convert';

import 'package:getsayor/presentation/pages/produk/components/order_page.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:getsayor/presentation/pages/produk/components/order_delivered.dart';
import 'package:provider/provider.dart';

class _LifecycleObserver extends WidgetsBindingObserver {
  final Function(AppLifecycleState) onStateChanged;

  _LifecycleObserver(this.onStateChanged);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    onStateChanged(state);
  }
}

class NotificationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Channel untuk status pesanan
  static const AndroidNotificationChannel statusChannel =
      AndroidNotificationChannel(
    'status_channel',
    'Status Updates',
    description: 'Channel untuk update status pesanan',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('notification'),
  );

  // Channel baru untuk order
  static const AndroidNotificationChannel orderChannel =
      AndroidNotificationChannel(
    'order_channel',
    'Order Updates',
    description: 'Channel untuk notifikasi order baru',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('notification'),
  );

  // Channel baru untuk topup
  static const AndroidNotificationChannel topupChannel =
      AndroidNotificationChannel(
    'topup_channel',
    'Topup Updates',
    description: 'Channel untuk notifikasi top up ',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('notification'),
  );

  static final Set<String> _processedMessages = {};
  static AppLifecycleState _appState = AppLifecycleState.resumed;

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) =>
          _handleNotificationPayload(details.payload),
    );

    await _setupNotificationChannel();
    _initLifecycleObserver();
  }

  static void _initLifecycleObserver() {
    WidgetsBinding.instance.addObserver(
      _LifecycleObserver((state) => _appState = state),
    );
  }

  static Future<void> _setupNotificationChannel() async {
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Buat kedua channel
    await androidPlugin?.createNotificationChannel(statusChannel);
    await androidPlugin?.createNotificationChannel(orderChannel);
    await androidPlugin?.createNotificationChannel(topupChannel);
  }

  static Future<void> setupFCM() async {
    await _requestPermissions();
    await _setupFCMHandlers();
    await _getInitialMessage();
    await _printFCMToken();
  }

  static Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _setupFCMHandlers() async {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  }

  static Future<void> _getInitialMessage() async {
    final message = await _firebaseMessaging.getInitialMessage();
    if (message != null) _handleMessage(message);
  }

  static Future<void> _printFCMToken() async {
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (_appState == AppLifecycleState.resumed) {
      if (_shouldSkipNotification(message)) return;
      await _showLocalNotification(message);
    }
  }

  static bool _shouldSkipNotification(RemoteMessage message) {
    return _isDuplicateMessage(message);
  }

  static bool _isDuplicateMessage(RemoteMessage message) {
    final String? uuid =
        message.data['uuid'] ?? message.notification?.android?.tag;

    if (uuid == null) {
      print('Warning: Received notification without UUID');
      return false;
    }

    if (_processedMessages.contains(uuid)) {
      return true;
    }

    _processedMessages.add(uuid);
    _startExpirationTimer(uuid);
    return false;
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final String? uuid = message.data['uuid'];
    final String title =
        message.data['title'] ?? message.notification?.title ?? 'No Title';
    final String body =
        message.data['body'] ?? message.notification?.body ?? 'No Body';
    final String? type = message.data['type'];

    if (uuid == null) {
      print('Error: Cannot show notification without UUID');
      return;
    }

    // Tentukan channel ID dan nama berdasarkan jenis notifikasi
    String channelId;
    String channelName;
    String channelDescription;
    if (type == 'new_order') {
      channelId = 'order_channel';
      channelName = 'Order Updates';
      channelDescription = 'Channel untuk notifikasi order baru';
    } else if (type == 'topup') {
      channelId = 'topup_channel';
      channelName = 'Topup Updates';
      channelDescription = 'Channel untuk notifikasi top up';
    } else {
      channelId = 'status_channel';
      channelName = 'Status Updates';
      channelDescription = 'Channel untuk notifikasi status';
    }

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription, // Gunakan parameter yang benar
      importance: Importance.high,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('notification'),
      autoCancel: true,
      channelShowBadge: true,
      tag: uuid,
      enableVibration: true,
      playSound: true,
    );

    await flutterLocalNotificationsPlugin.show(
      uuid.hashCode,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: json.encode(message.data),
    );
  }

  static void _startExpirationTimer(String uuid) {
    Timer(const Duration(minutes: 5), () {
      _processedMessages.remove(uuid);
    });
  }

  static void _handleMessageOpened(RemoteMessage message) {
    _handleMessage(message);
    _handleNotificationClick(message.data);
  }

  static void _handleMessage(RemoteMessage message) {
    navigatorKey.currentState?.pushNamed(
      '/empty_page',
      arguments: {"message": json.encode(message.data)},
    );
  }

  static void _handleNotificationClick(Map<String, dynamic> data) {
    final type = data['type'];
    final orderId = data['orderId'];

    if (type == 'new_order') {
      navigatorKey.currentState?.pushNamed(
        OrderDeliveredPage.routeName,
        arguments: orderId,
      );
    } else if (type == 'status_update') {
      // Navigasi ke OrderPage dengan mengambil userId dari provider
      final userProvider = Provider.of<UserProvider>(
        navigatorKey.currentContext!,
        listen: false,
      );
      navigatorKey.currentState?.pushNamed(
        OrderPage.routeName,
        arguments: userProvider.userId,
      );
    }
  }

  static void _handleNotificationPayload(String? payload) {
    if (payload == null) return;
    final data = json.decode(payload) as Map<String, dynamic>;
    _handleNotificationClick(data);
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();

    if (message.data.isNotEmpty) {
      _handleNotificationClick(message.data);
    }
  }
}
