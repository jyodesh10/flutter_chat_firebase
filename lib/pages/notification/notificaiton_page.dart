import 'package:firebase_chat_app/services/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    _notificationService.getFCMToken();
    _notificationService.foregroundNotifications();
    _notificationService.fm.getInitialMessage();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Center(
          child: Column(
        children: [
          MaterialBanner(content: const Text('Show Notification'), actions: [
            TextButton.icon(
                onPressed: () {
                  _notificationService.showNotification(
                      'Button Clicked', 'show');
                },
                icon: const Icon(Icons.notifications),
                label: const Text('Show'))
          ]),
          MaterialBanner(
              content: const Text('Scheduled Notification'),
              actions: [
                TextButton.icon(
                    onPressed: () {
                      _notificationService.scheduleNotificaton(
                          'Scheduled Notificaotn', 'This is scheduled');
                    },
                    icon: const Icon(Icons.notifications),
                    label: const Text('Show'))
              ]),
        ],
      )),
    );
  }
}
