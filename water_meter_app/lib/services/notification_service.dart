import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:water_meter_app/utils/global.dart';

import '../models/notifyModel.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
}


class NotificationService {
  final String baseUrl = "http://your-server-url"; // Đổi thành URL server của bạn

  // Hàm lấy danh sách thông báo theo userId
  Future<List<Notification>> getNotifications(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/notifications/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Notification.fromJson(json)).toList();
    } else {
      throw Exception('Không thể lấy danh sách thông báo');
    }
  }

  NotificationService._();

  static final NotificationService instance = NotificationService._();
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool isFlutterLocalNotificationsInitialized = false;


  Future<void> initialize() async {
    await _requestPermission();
    await _setupMessageHandlers();

    // GET FCM token
    final token = await _messaging.getToken();
    fcmToken = token;
    
    print('FCM token: ${token}');
    

  }
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission
    (
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      carPlay: false,
      announcement: false,
      criticalAlert: false,
    );
     print('Permission status: ${settings.authorizationStatus}');
  }
  Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  const channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );
  await _localNotifications
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);
  const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');


    // ios setup
    final initializationSettingsDarwin = DarwinInitializationSettings(
      // onDidReceiveLocalNotification: (id, title, body, payload) async {
      //   // Handle iOS foreground notification
      // },
    );


    final initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
     iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {}
    );
    isFlutterLocalNotificationsInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

   Future<void> _setupMessageHandlers() async {
    //foreground message
    FirebaseMessaging.onMessage.listen((message) {
      print("Foreground message received: ${message.notification?.title}");
      showNotification(message);
    });

    // background message
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // opened app
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }
  void _handleBackgroundMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      // open chat screen
    }
  }

}