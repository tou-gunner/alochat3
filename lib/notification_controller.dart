import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:alochat/main.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Configs/Dbpaths.dart';
import 'Models/call.dart';
import 'Models/call_methods.dart';
import 'Services/Providers/currentchat_peer.dart';
import 'Utils/permissions.dart';

List<OverlaySupportEntry> overlayNotifications = [];

final _instance2 = NotificationController2();

class NotificationController2 {
  static bool _initialized = false;

  ///  *********************************************
  ///     REMOTE NOTIFICATION EVENTS
  ///  *********************************************

  static Future<void> initialize() async {
    ReceivePort port = ReceivePort();
    IsolateNameServer.registerPortWithName(
      port.sendPort,
      'background_notification_action',
    );

    port.listen((var received) async {
      _handleBackgroundNotification(received);
    });

    _initialized = true;

  }

  // static Future<void> onSilentActionHandle(ReceivedAction received) async {
  //   print('On new background action received: ${received.toMap()}');
  //
  //   if (!_initialized) {
  //     SendPort? uiSendPort = IsolateNameServer.lookupPortByName('background_notification_action');
  //     if (uiSendPort != null) {
  //       print('Background action running on parallel isolate without valid context. Redirecting execution');
  //       uiSendPort.send(received);
  //       return;
  //     }
  //   }
  //
  //   print('Background action running on main isolate');
  //   await _handleBackgroundNotification(received);
  // }

  /// Use this method to execute on background when a silent data arrives
  /// (even while terminated)
  @pragma("vm:entry-point")
  static Future<void> onSilentDataHandle(FcmSilentData silentData) async {
    print('"SilentData": ${silentData.toString()}');

    if (!_initialized) {
      SendPort? uiSendPort =
          IsolateNameServer.lookupPortByName('background_notification_action');
      if (uiSendPort != null) {
        print(
            'Background action running on parallel isolate without valid context. Redirecting execution');
        uiSendPort.send(silentData);
        return;
      }
    }

    if (silentData.createdLifeCycle != NotificationLifeCycle.Foreground) {
      print("bg");
    } else {
      print("FOREGROUND");
    }

    print('Background action running on main isolate');
    await _handleBackgroundNotification(silentData);
  }

  static Future<void> _handleBackgroundNotification(
      FcmSilentData silentData) async {
    awesomeNotifications..cancelAll();

    final data = silentData.data!;
    if (data['title'] != 'Call Ended' &&
        data['title'] != 'Missed Call' &&
        data['title'] != 'You have new message(s)' &&
        data['title'] != 'Incoming Video Call...' &&
        data['title'] != 'Incoming Audio Call...' &&
        data['title'] != 'Incoming Call ended' &&
        data['title'] != 'New message in Group') {
    } else {
      if (data['title'] == 'New message in Group') {
      } else if (data['title'] == 'Call Ended') {
        awesomeNotifications.cancelAll();
      } else {
        if (data['title'] == 'Incoming Audio Call...' ||
            data['title'] == 'Incoming Video Call...' ||
            data['title'] == 'Call Ended' ||
            data['title'] == 'Missed Call') {
          final title = data['title'];
          final body = data['body'];
          final titleMultilang = data['titleMultilang'];
          final bodyMultilang = data['bodyMultilang'];
          await _showNotificationWithDefaultSound(
              title, body, titleMultilang, bodyMultilang);
        } else if (data['title'] == 'You have new message(s)') {
          // FlutterRingtonePlayer.playNotification();
          showOverlayNotification((context) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: SafeArea(
                child: ListTile(
                  title: Text(
                    data['titleMultilang']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    data['bodyMultilang']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        OverlaySupportEntry.of(context)!.dismiss();
                      }),
                ),
              ),
            );
          }, duration: Duration(milliseconds: 2000));
        } else {
          showOverlayNotification((context) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: SafeArea(
                child: ListTile(
                  leading: data.containsKey("image")
                      ? SizedBox()
                      : data["image"] == null
                          ? SizedBox()
                          : Image.network(
                              data['image']!,
                              width: 50,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                  title: Text(
                    data['titleMultilang']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    data['bodyMultilang']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        OverlaySupportEntry.of(context)!.dismiss();
                      }),
                ),
              ),
            );
          }, duration: Duration(milliseconds: 2000));
        }
      }
    }
  }

  static Future<void> _showNotificationWithDefaultSound(String? title,
      String? message, String? titleMultilang, String? bodyMultilang) async {
    if (Platform.isAndroid) {
      // flutterLocalNotificationsPlugin.cancelAll();
      awesomeNotifications.cancelAll();
    }

    // var initializationSettingsAndroid =
    //     new AndroidInitializationSettings('@mipmap/ic_launcher');
    // var initializationSettingsIOS = IOSInitializationSettings();
    // var initializationSettings = InitializationSettings(
    //     android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    // flutterLocalNotificationsPlugin.initialize(initializationSettings);
    // var androidPlatformChannelSpecifics =
    //     title == 'Missed Call' || title == 'Call Ended'
    //         ? local.AndroidNotificationDetails('channel_id', 'channel_name',
    //             importance: local.Importance.max,
    //             priority: local.Priority.high,
    //             sound: RawResourceAndroidNotificationSound('whistle2'),
    //             playSound: true,
    //             ongoing: true,
    //             visibility: NotificationVisibility.public,
    //             timeoutAfter: 28000)
    //
    //         : local.AndroidNotificationDetails('channel_id', 'channel_name',
    //             sound: RawResourceAndroidNotificationSound('ringtone'),
    //             playSound: true,
    //             ongoing: true,
    //             importance: local.Importance.max,
    //             priority: local.Priority.high,
    //             visibility: NotificationVisibility.public,
    //             timeoutAfter: 28000);
    // var iOSPlatformChannelSpecifics = local.IOSNotificationDetails(
    //   presentAlert: true,
    //   presentBadge: true,
    //   sound:
    //       title == 'Missed Call' || title == 'Call Ended' ? '' : 'ringtone.caf',
    //   presentSound: true,
    // );
    // var platformChannelSpecifics = local.NotificationDetails(
    //     android: androidPlatformChannelSpecifics,
    //     iOS: iOSPlatformChannelSpecifics);
    // await flutterLocalNotificationsPlugin
    //     .show(
    //   0,
    //   '$titleMultilang',
    //   '$bodyMultilang',
    //   platformChannelSpecifics,
    //   payload: 'payload',
    // )
    //     .catchError((err) {
    //   print('ERROR DISPLAYING NOTIFICATION: $err');
    // });

    // Seng Edit
    if (title == 'Missed Call') {
      awesomeNotifications..cancelAll();
      await awesomeNotifications.createNotification(
        content: NotificationContent(
          id: 0,
          channelKey: 'missed_call',
          title: '$titleMultilang',
          body: '$bodyMultilang',
          criticalAlert: true,
          wakeUpScreen: true,
          // customSound: 'whistle2'
          category: NotificationCategory.MissedCall,
        ),
      );
    } else {
      await awesomeNotifications.createNotification(
        content: NotificationContent(
            id: 1,
            channelKey: 'video_call',
            title: '$titleMultilang',
            body: '$bodyMultilang',
            criticalAlert: true,
            wakeUpScreen: true,
            autoDismissible: false,
            // customSound: 'ringtone',
            payload: {'message': message},
            category: NotificationCategory.Call,
            actionType: ActionType.DisabledAction),
        actionButtons: <NotificationActionButton>[
          NotificationActionButton(
            key: 'yes',
            label: 'Accept',
          ),
          NotificationActionButton(
              key: 'no', label: 'Reject', actionType: ActionType.SilentAction),
        ],
      );
    }
  }

  /// Use this method to detect when a new fcm token is received
  @pragma("vm:entry-point")
  static Future<void> onFcmTokenHandle(String token) async {
    debugPrint('FCM Token:"$token"');
  }

  /// Use this method to detect when a new native token is received
  @pragma("vm:entry-point")
  static Future<void> onNativeTokenHandle(String token) async {
    debugPrint('Native Token:"$token"');
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    print('"onNotificationCreatedMethod": ${receivedNotification.toString()}');
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print('"onDismissActionReceivedMethod": ${receivedAction.toString()}');
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print('"onActionReceivedMethod": ${receivedAction.toString()}');

    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    // MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/notification-page',
    //         (route) => (route.settings.name != '/notification-page') || route.isFirst,
    //     arguments: receivedAction);
  }
}

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  int _eventCount = 0;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final customData =
    await FlutterForegroundTask.getData<String>(key: 'customData');
    print('customData: $customData');
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    FlutterForegroundTask.updateService(
      notificationTitle: 'MyTaskHandler',
      notificationText: 'eventCount: $_eventCount',
    );

    // Send data to the main isolate.
    sendPort?.send(_eventCount);

    _eventCount++;
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // You can use the clearAllData function to clear all the stored data.
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    // Called when the notification button on the Android platform is pressed.
    print('onButtonPressed >> $id');
  }

  @override
  void onNotificationPressed() {
    // Called when the notification itself on the Android platform is pressed.
    //
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // this function to be called.

    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}

class NotificationController with ChangeNotifier {
  /// *********************************************
  ///   SINGLETON PATTERN
  /// *********************************************
  static final NotificationController _instance =
      NotificationController._internal();

  factory NotificationController() {
    return _instance;
  }

  NotificationController._internal();

  /// *********************************************
  ///  OBSERVER PATTERN
  /// *********************************************
  String _firebaseToken = '';
  String get firebaseToken => _firebaseToken;

  String _nativeToken = '';
  String get nativeToken => _nativeToken;

  /// *********************************************
  ///   INITIALIZATION METHODS
  /// *********************************************
  static Future<void> initializeLocalNotifications(
      {required bool debug}) async {
    await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelGroupKey: 'message_channels',
            channelKey: 'new_group_message',
            channelName: 'New Group Message',
            channelDescription: 'New Group Message',
            importance: NotificationImportance.Max,
            playSound: true,
            soundSource: 'resource://raw/whistle',
          ),
          NotificationChannel(
            channelGroupKey: 'call_channels',
            channelKey: 'video_call',
            channelName: 'Video Call',
            channelDescription: 'Video Call',
            importance: NotificationImportance.Max,
            playSound: true,
            soundSource: 'resource://raw/ringtone',
          ),
          NotificationChannel(
            channelGroupKey: 'call_channels',
            channelKey: 'audio_call',
            channelName: 'Audio Call',
            channelDescription: 'Audio Call',
            importance: NotificationImportance.Max,
            playSound: true,
            soundSource: 'resource://raw/ringtone',
          ),
          NotificationChannel(
              channelGroupKey: 'call_channels',
              channelKey: 'missed_call',
              channelName: 'Missed Call',
              channelDescription: 'Missed Call',
              importance: NotificationImportance.Max,
              playSound: true,
              soundSource: 'resource://raw/whistle')
        ],
        channelGroups: [
          NotificationChannelGroup(
              channelGroupKey: 'message_channels',
              channelGroupName: 'Message Channels'),
          NotificationChannelGroup(
              channelGroupKey: 'call_channels',
              channelGroupName: 'Call Channels'),
        ],
        debug: debug);

    // await _initForegroundTask();

    // FlutterForegroundTask.wakeUpScreen();
    // await _startForegroundTask();
  }

  static Future<void> _initForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'notification_channel_id',
        channelName: 'Foreground Notification',
        channelDescription:
        'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
          backgroundColor: Colors.orange,
        ),
        buttons: [
          const NotificationButton(id: 'sendButton', text: 'Send'),
          const NotificationButton(id: 'testButton', text: 'Test'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 1000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<bool> _startForegroundTask() async {
    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      final isGranted =
      await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) {
        print('SYSTEM_ALERT_WINDOW permission denied!');
        return false;
      }
    }

    // You can save data using the saveData function.
    // await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    bool reqResult;
    if (await FlutterForegroundTask.isRunningService) {
      reqResult = await FlutterForegroundTask.restartService();
    } else {
      reqResult = await FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        callback: startCallback,
      );
    }

    ReceivePort? receivePort;
    if (reqResult) {
      receivePort = await FlutterForegroundTask.receivePort;
    }

    return _registerReceivePort(receivePort);
  }

  static ReceivePort? _receivePort;

  static void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  static bool _registerReceivePort(ReceivePort? receivePort) {
    _closeReceivePort();

    if (receivePort != null) {
      _receivePort = receivePort;
      _receivePort?.listen((message) {
        if (message is int) {
          print('eventCount: $message');
        } else if (message is String) {
          if (message == 'onNotificationPressed') {
            // Navigator.of(context).pushNamed('/resume-route');
          }
        } else if (message is DateTime) {
          print('timestamp: ${message.toString()}');
        }
      });

      return true;
    }

    return false;
  }

  static Future<void> initializeRemoteNotifications(
      {required bool debug}) async {
    await Firebase.initializeApp();
    await AwesomeNotificationsFcm().initialize(
        onFcmSilentDataHandle: NotificationController.mySilentDataHandle,
        onFcmTokenHandle: NotificationController.myFcmTokenHandle,
        onNativeTokenHandle: NotificationController.myNativeTokenHandle,
        licenseKeys: [
          //come.alo.alochat
          'G0E3HQtVUxGt886U9Bn0Z6WKlUoNHLjCMtHQV9sUaIcK0Ay5TZcnlTL1abIutDs4aCe6'
          'bBJ4x7nziBA78qcEQxVUrTX9cJjC8RH/Tth1GczYMgdhTNaxAkRjrlGB7BaYpfD137a8'
          '8FcMyws1BoPo1N+RmXE/EyzeT+2zAm4U7G0=',
        ],
        // On this example app, the app ID / Bundle Id are different
        // for each platform
        // Platform.isIOS
        //   ? 'B3J3yxQbzzyz0KmkQR6rDlWB5N68sTWTEMV7k9HcPBroUh4RZ/Og2Fv6Wc/lE'
        //       '2YaKuVY4FUERlDaSN4WJ0lMiiVoYIRtrwJBX6/fpPCbGNkSGuhrx0Rekk'
        //       '+yUTQU3C3WCVf2D534rNF3OnYKUjshNgQN8do0KAihTK7n83eUD60='
        //   : 'UzRlt+SJ7XyVgmD1WV+7dDMaRitmKCKOivKaVsNkfAQfQfechRveuKblFnCp4'
        //       'zifTPgRUGdFmJDiw1R/rfEtTIlZCBgK3Wa8MzUV4dypZZc5wQIIVsiqi0Zhaq'
        //       'YtTevjLl3/wKvK8fWaEmUxdOJfFihY8FnlrSA48FW94XWIcFY=',
        debug: debug);
  }

  static Future<void> initializeNotificationListeners() async {
    // Only after at least the action method is set, the notification events are delivered
    await AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.myActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.myNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.myNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.myDismissActionReceivedMethod);
  }

  static Future<void> getInitialNotificationAction() async {
    ReceivedAction? receivedAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: true);
    if (receivedAction == null) return;
    // Fluttertoast.showToast(
    //     msg: 'Notification action launched app: $receivedAction',
    //   backgroundColor: Colors.deepPurple
    // );
    print('Notification action launched app: $receivedAction');
  }

  ///  *********************************************
  ///    LOCAL NOTIFICATION METHODS
  ///  *********************************************
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> myNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content:
    //     Text('Notification from ${AwesomeAssertUtils.toSimpleEnumString(receivedNotification.createdSource)} created'),
    //     backgroundColor: Colors.green));
    print(receivedNotification);
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> myNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content:
    //     Text('Notification from ${AwesomeAssertUtils.toSimpleEnumString(receivedNotification.createdSource)} displayed'),
    //     backgroundColor: Colors.blue));
    print(receivedNotification);
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> myDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content:
    //     Text('Notification from ${AwesomeAssertUtils.toSimpleEnumString(receivedAction.createdSource)} dismissed'),
    //     backgroundColor: Colors.orange));
    print(receivedAction);
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> myActionReceivedMethod(
      ReceivedAction receivedAction) async {
    String? actionSourceText =
        AwesomeAssertUtils.toSimpleEnumString(receivedAction.actionLifeCycle);

    if (receivedAction.channelKey == 'video_call' || receivedAction.channelKey == 'audio_call') {
      // final firebase = await Firebase.initializeApp();
      final CallMethods callMethods = CallMethods();
      final data = jsonDecode(receivedAction.payload!['data']!);
      Call call = Call.fromMap(data);
      if (receivedAction.buttonKeyPressed == 'no') {
        awesomeNotifications.cancelAll();
        await callMethods.endCall(call: call);
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(call.callerId)
            .collection(DbPaths.collectioncallhistory)
            .doc(call.timeepoch.toString())
            .set({
          'STATUS': 'rejected',
          'ENDED': DateTime.now(),
        }, SetOptions(merge: true));
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(call.receiverId)
            .collection(DbPaths.collectioncallhistory)
            .doc(call.timeepoch.toString())
            .set({
          'STATUS': 'rejected',
          'ENDED': DateTime.now(),
        }, SetOptions(merge: true));
        //----------
        await FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(call.callerId)
            .collection('recent')
            .doc('callended')
            .delete();
        Future.delayed(const Duration(milliseconds: 200), () async {
          await FirebaseFirestore.instance
              .collection(DbPaths.collectionusers)
              .doc(call.callerId)
              .collection('recent')
              .doc('callended')
              .set({
            'id': call.callerId,
            'ENDED': DateTime.now().millisecondsSinceEpoch
          });
        });

        // firestoreDataProviderCALLHISTORY.fetchNextData(
        //     'CALLHISTORY',
        //     FirebaseFirestore.instance
        //         .collection(DbPaths.collectionusers)
        //         .doc(call.receiverId)
        //         .collection(
        //         DbPaths.collectioncallhistory)
        //         .orderBy('TIME', descending: true)
        //         .limit(14),
        //     true);
        awesomeNotifications.cancelAll();
      }
    }

    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text('Notification action captured on $actionSourceText')));

    // String targetPage = PAGE_NOTIFICATION_DETAILS;

    // Avoid to open the notification details page over another details page already opened
    // MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(targetPage,
    //         (route) => (route.settings.name != targetPage) || route.isFirst,
    //     arguments: receivedAction);
  }

  ///  *********************************************
  ///     REMOTE NOTIFICATION METHODS
  ///  *********************************************
  /// Use this method to execute on background when a silent data arrives
  /// (even while terminated)
  @pragma("vm:entry-point")
  static Future<void> mySilentDataHandle(FcmSilentData silentData) async {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text('Silent data received',
    //       style: TextStyle(
    //           color: Colors.white,
    //           fontSize: 16
    //       ),
    //     ),
    //     backgroundColor: Colors.blueAccent,));

    // print('"SilentData": ${silentData.toString()}');

    // if (silentData.createdLifeCycle != NotificationLifeCycle.Foreground) {
    //   print("bg");
    // } else {
    //   print("FOREGROUND");
    // }

    // print("starting long task");
    // await Future.delayed(Duration(seconds: 4));
    // final url = Uri.parse("http://google.com");
    // final re = await http.get(url);
    // print(re.body);
    // print("long task done");

    _handleBackgroundNotification(silentData);
  }

  static Future<void> _handleBackgroundNotification(
      FcmSilentData silentData) async {
    awesomeNotifications..cancelAll();

    final data = silentData.data!;
    if (data['title'] != 'Call Ended' &&
        data['title'] != 'Missed Call' &&
        data['title'] != 'You have new message(s)' &&
        data['title'] != 'Incoming Video Call...' &&
        data['title'] != 'Incoming Audio Call...' &&
        data['title'] != 'Incoming Call ended' &&
        data['title'] != 'New message in Group') {
    } else {
      if (data['title'] == 'New message in Group') {
        awesomeNotifications..cancelAll();

        await awesomeNotifications.createNotification(
          content: NotificationContent(
            id: 0,
            channelKey: 'new_group_message',
            title: data['titleMultilang']!,
            body: data['bodyMultilang']!,
            criticalAlert: true,
            wakeUpScreen: true,
            // customSound: 'whistle2'
            category: NotificationCategory.Message,
          ),
        );
      } else if (data['title'] == 'Call Ended') {
        awesomeNotifications.cancelAll();
      } else {
        if (data['title'] == 'Incoming Audio Call...' ||
            data['title'] == 'Incoming Video Call...' ||
            data['title'] == 'Call Ended' ||
            data['title'] == 'Missed Call') {
          final title = data['title'];
          final body = data['body'];
          final titleMultilang = data['titleMultilang'];
          final bodyMultilang = data['bodyMultilang'];
          await _showNotificationWithDefaultSound(data['phone']!, data['data']!,
              title, body, titleMultilang, bodyMultilang);
        } else if (data['title'] == 'You have new message(s)') {
          // FlutterRingtonePlayer.playNotification();
          overlayNotifications.add(showOverlayNotification((context) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: SafeArea(
                child: ListTile(
                  title: Text(
                    data['titleMultilang']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    data['bodyMultilang']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        OverlaySupportEntry.of(context)!.dismiss();
                      }),
                ),
              ),
            );
          }, duration: Duration(milliseconds: 2000)));
        } else {
          overlayNotifications.add(showOverlayNotification((context) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: SafeArea(
                child: ListTile(
                  leading: data.containsKey("image")
                      ? SizedBox()
                      : data["image"] == null
                          ? SizedBox()
                          : Image.network(
                              data['image']!,
                              width: 50,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                  title: Text(
                    data['titleMultilang']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    data['bodyMultilang']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        OverlaySupportEntry.of(context)!.dismiss();
                      }),
                ),
              ),
            );
          }, duration: Duration(milliseconds: 2000)));
        }
      }
    }
  }

  static Future<void> _showNotificationWithDefaultSound(
      String phone,
      String data,
      String? title,
      String? message,
      String? titleMultilang,
      String? bodyMultilang) async {
    if (Platform.isAndroid) {
      // flutterLocalNotificationsPlugin.cancelAll();
      awesomeNotifications.cancelAll();
    }

    // var initializationSettingsAndroid =
    //     new AndroidInitializationSettings('@mipmap/ic_launcher');
    // var initializationSettingsIOS = IOSInitializationSettings();
    // var initializationSettings = InitializationSettings(
    //     android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    // flutterLocalNotificationsPlugin.initialize(initializationSettings);
    // var androidPlatformChannelSpecifics =
    //     title == 'Missed Call' || title == 'Call Ended'
    //         ? local.AndroidNotificationDetails('channel_id', 'channel_name',
    //             importance: local.Importance.max,
    //             priority: local.Priority.high,
    //             sound: RawResourceAndroidNotificationSound('whistle2'),
    //             playSound: true,
    //             ongoing: true,
    //             visibility: NotificationVisibility.public,
    //             timeoutAfter: 28000)
    //
    //         : local.AndroidNotificationDetails('channel_id', 'channel_name',
    //             sound: RawResourceAndroidNotificationSound('ringtone'),
    //             playSound: true,
    //             ongoing: true,
    //             importance: local.Importance.max,
    //             priority: local.Priority.high,
    //             visibility: NotificationVisibility.public,
    //             timeoutAfter: 28000);
    // var iOSPlatformChannelSpecifics = local.IOSNotificationDetails(
    //   presentAlert: true,
    //   presentBadge: true,
    //   sound:
    //       title == 'Missed Call' || title == 'Call Ended' ? '' : 'ringtone.caf',
    //   presentSound: true,
    // );
    // var platformChannelSpecifics = local.NotificationDetails(
    //     android: androidPlatformChannelSpecifics,
    //     iOS: iOSPlatformChannelSpecifics);
    // await flutterLocalNotificationsPlugin
    //     .show(
    //   0,
    //   '$titleMultilang',
    //   '$bodyMultilang',
    //   platformChannelSpecifics,
    //   payload: 'payload',
    // )
    //     .catchError((err) {
    //   print('ERROR DISPLAYING NOTIFICATION: $err');
    // });

    // Seng Edit
    if (title == 'Missed Call') {
      awesomeNotifications..cancelAll();
      await awesomeNotifications.createNotification(
        content: NotificationContent(
          id: 0,
          channelKey: 'missed_call',
          title: '$titleMultilang',
          body: '$bodyMultilang',
          criticalAlert: true,
          wakeUpScreen: true,
          // customSound: 'whistle2'
          category: NotificationCategory.MissedCall,
        ),
      );
    } else if(title == 'Incoming Video Call...') {
      await awesomeNotifications.createNotification(
        content: NotificationContent(
            id: 1,
            channelKey: 'video_call',
            title: '$titleMultilang',
            body: '$bodyMultilang',
            criticalAlert: true,
            wakeUpScreen: true,
            autoDismissible: false,
            // customSound: 'ringtone',
            payload: {'phone': phone, 'data': data},
            category: NotificationCategory.Call,
            // actionType: ActionType.DisabledAction
        ),
        actionButtons: <NotificationActionButton>[
          NotificationActionButton(
            key: 'yes',
            label: 'Accept'
          ),
          NotificationActionButton(
              key: 'no',
              label: 'Reject',
              actionType: ActionType.SilentBackgroundAction),
        ],
      );

      // FlutterForegroundTask.init(
      //   androidNotificationOptions: AndroidNotificationOptions(
      //     channelId: 'video_call',
      //     channelName: 'Video Call',
      //     channelDescription: 'Video Call',
      //     channelImportance: NotificationChannelImportance.MAX,
      //     priority: NotificationPriority.MAX,
      //     // iconData: const NotificationIconData(
      //     //   resType: ResourceType.mipmap,
      //     //   resPrefix: ResourcePrefix.ic,
      //     //   name: 'launcher',
      //     // ),
      //     buttons: [
      //       const NotificationButton(id: 'yes', text: 'Accept'),
      //       const NotificationButton(id: 'no', text: 'Reject'),
      //     ],
      //   ),
      //   actionButtons: <NotificationActionButton>[
      //     NotificationActionButton(
      //       key: 'yes', label: 'Accept',
      //     ),
      //     NotificationActionButton(
      //         key: 'no', label: 'Reject',
      //         actionType: ActionType.SilentBackgroundAction
      //     ),
      //   ],
      // );

      // final prefs = await SharedPreferences.getInstance();
      // var oldId = prefs.getInt('incoming_call_id') ?? 0;
      // await prefs.setString('incoming_call', data);
      // await prefs.setInt('incoming_call_id', oldId++);

      // await _initForegroundTask();
      // FlutterForegroundTask.wakeUpScreen();
      // await _startForegroundTask();

    } else if(title == 'Incoming Audio Call...') {
      await awesomeNotifications.createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'audio_call',
          title: '$titleMultilang',
          body: '$bodyMultilang',
          criticalAlert: true,
          wakeUpScreen: true,
          autoDismissible: false,
          // customSound: 'ringtone',
          payload: {'phone': phone, 'data': data},
          category: NotificationCategory.Call,
          // actionType: ActionType.DisabledAction
        ),
        actionButtons: <NotificationActionButton>[
          NotificationActionButton(
            key: 'yes',
            label: 'Accept',
          ),
          NotificationActionButton(
              key: 'no',
              label: 'Reject',
              actionType: ActionType.SilentBackgroundAction),
        ],
      );
    }
  }

  /// Use this method to detect when a new fcm token is received
  @pragma("vm:entry-point")
  static Future<void> myFcmTokenHandle(String token) async {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text('Fcm token received',
    //       style: TextStyle(
    //           color: Colors.white,
    //           fontSize: 16
    //       ),
    //     ),
    //     backgroundColor: Colors.blueAccent,));
    debugPrint('Firebase Token:"$token"');

    _instance._firebaseToken = token;
    _instance.notifyListeners();
  }

  /// Use this method to detect when a new native token is received
  @pragma("vm:entry-point")
  static Future<void> myNativeTokenHandle(String token) async {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text('Native token received',
    //       style: TextStyle(
    //         color: Colors.white,
    //         fontSize: 16
    //       ),
    //     ),
    //     backgroundColor: Colors.blueAccent,));
    debugPrint('Native Token:"$token"');
  }

  ///  *********************************************
  ///     REMOTE TOKEN REQUESTS
  ///  *********************************************

  static Future<String> requestFirebaseToken() async {
    if (await AwesomeNotificationsFcm().isFirebaseAvailable) {
      try {
        return await AwesomeNotificationsFcm().requestFirebaseAppToken();
      } catch (exception) {
        debugPrint('$exception');
      }
    } else {
      debugPrint('Firebase is not available on this project');
    }
    return '';
  }

}
