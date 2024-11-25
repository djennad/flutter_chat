import 'package:flutter/foundation.dart';
import 'package:js/js.dart';
import 'dart:js_util';

@JS('window.Notification')
external dynamic get notification;

@JS('window.Notification.requestPermission')
external dynamic requestPermission();

@JS('window.Notification.permission')
external String get notificationPermission;

class NotificationService {
  static Future<void> initialize() async {
    if (kIsWeb) {
      try {
        final permission = await promiseToFuture(requestPermission());
        print('Notification permission: $permission');
      } catch (e) {
        print('Error requesting notification permission: $e');
      }
    }
  }

  static void showNotification(String title, String body) {
    if (kIsWeb && notificationPermission == 'granted') {
      try {
        final options = {
          'body': body,
          'icon': '/flutter_chat/favicon.png',
          'badge': '/flutter_chat/favicon.png',
          'sound': '/flutter_chat/notification.mp3'
        };
        callConstructor(notification, [title, jsify(options)]);
      } catch (e) {
        print('Error showing notification: $e');
      }
    }
  }
}
