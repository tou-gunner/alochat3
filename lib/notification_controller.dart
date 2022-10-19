import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';

bool _initialized = false;

class NotificationController {

  static Future<void> onSilentActionHandle(ReceivedAction received) async {
    print('On new background action received: ${received.toMap()}');

    if (!_initialized) {
      SendPort? uiSendPort = IsolateNameServer.lookupPortByName('background_notification_action');
      if (uiSendPort != null) {
        print('Background action running on parallel isolate without valid context. Redirecting execution');
        uiSendPort.send(received);
        return;
      }
    }

    print('Background action running on main isolate');
    await _handleBackgroundAction(received);
  }

  static Future<void> _handleBackgroundAction(ReceivedAction received) async {
    // Your background action handle
  }

  static Future<void> initialize() async {
    ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(
      port.sendPort,
      'background_notification_action',
    );

    port.listen((var received) async {
      _handleBackgroundAction(received);
    });

    _initialized = true;
  }

}
