import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/repositories/api_repositories.dart';

class NotificationService {
  NotificationService(this._deviceTokens);

  final DeviceTokenRepository _deviceTokens;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _local.initialize(settings);

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    await messaging.setAutoInitEnabled(true);

    final token = await messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await _registerToken(token);
    }

    FirebaseMessaging.onMessage.listen((msg) async {
      await _showLocal(
        title: msg.notification?.title ?? 'Euro Mall',
        body: msg.notification?.body ?? '',
      );
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      await _registerToken(token);
    });
  }

  /// Call after login so the backend stores FCM under the authenticated member.
  Future<void> syncRegisteredTokenToBackend() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _registerToken(token);
      }
    } catch (_) {}
  }

  Future<void> showExpiryReminder({
    required String title,
    required String body,
  }) async {
    await _showLocal(title: title, body: body);
  }

  Future<void> _registerToken(String token) async {
    try {
      await _deviceTokens.register(
        fcmToken: token,
        platform: kIsWeb
            ? 'web'
            : Platform.isAndroid
                ? 'android'
                : Platform.isIOS
                    ? 'ios'
                    : 'unknown',
      );
    } catch (_) {
      // Token sync should never block app flows.
    }
  }

  Future<void> _showLocal({
    required String title,
    required String body,
  }) async {
    const android = AndroidNotificationDetails(
      'euromall_default',
      'Euro Mall',
      channelDescription: 'General notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: android, iOS: ios),
    );
  }
}

