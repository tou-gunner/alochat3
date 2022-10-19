//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:core';
import 'dart:isolate';
import 'dart:ui';
import 'package:alochat/notification_controller.dart';
import 'package:alochat/widgets/Camera/camera.dart';
import 'package:alochat/Configs/Dbkeys.dart';
import 'package:alochat/Configs/app_constants.dart';
import 'package:alochat/Screens/homepage/initialize.dart';
import 'package:alochat/Screens/splash_screen/splash_screen.dart';
import 'package:alochat/Services/Providers/BroadcastProvider.dart';
import 'package:alochat/Services/Providers/AvailableContactsProvider.dart';
import 'package:alochat/Services/Providers/GroupChatProvider.dart';
import 'package:alochat/Services/Providers/LazyLoadingChatProvider.dart';
import 'package:alochat/Services/Providers/Observer.dart';
import 'package:alochat/Services/Providers/StatusProvider.dart';
import 'package:alochat/Services/Providers/TimerProvider.dart';
import 'package:alochat/Services/Providers/currentchat_peer.dart';
import 'package:alochat/Services/Providers/seen_provider.dart';
import 'package:alochat/Services/localization/demo_localization.dart';
import 'package:alochat/Services/localization/language_constants.dart';
import 'package:alochat/Services/Providers/DownloadInfoProvider.dart';
import 'package:alochat/Services/Providers/call_history_provider.dart';
import 'package:alochat/Services/Providers/user_provider.dart';
import 'package:alochat/Utils/setStatusBarColor.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final awesomeFcm = AwesomeNotificationsFcm();
final awesomeNotifications = AwesomeNotifications();
List<CameraDescription> cameras = <CameraDescription>[];

void main() async {
  final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();

  binding.renderView.automaticSystemUiAdjustment = false;
  setStatusBarColor();
  if (IsBannerAdShow == true ||
      IsInterstitialAdShow == true ||
      IsVideoAdShow == true) {
    MobileAds.instance.initialize();
  }

  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }

  // Seng add
  await awesomeNotifications.initialize(
    // set the icon to null if you want to use the default app icon
    null,
    [
      NotificationChannel(
        channelGroupKey: 'channel_group_key',
        channelKey: 'channel_id',
        channelName: 'channel_name',
        channelDescription: 'channel_description',
        importance: NotificationImportance.Max,
      )
    ],
    debug: true,
  );

  ReceivedAction? receivedAction = await awesomeNotifications.getInitialNotificationAction(
      removeFromActionEvents: false
  );
  // if(receivedAction?.channelKey == 'call_channel') {
  //   setInitialPageToCallPage();
  // } else {
  //   setInitialPageToHomePage();
  // }

  await NotificationController.initialize();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(OverlaySupport(child: FiberchatWrapper()));
  });
}

class FiberchatWrapper extends StatefulWidget {
  const FiberchatWrapper({Key? key}) : super(key: key);
  static void setLocale(BuildContext context, Locale newLocale) {
    _FiberchatWrapperState state =
        context.findAncestorStateOfType<_FiberchatWrapperState>()!;
    state.setLocale(newLocale);
  }

  @override
  _FiberchatWrapperState createState() => _FiberchatWrapperState();
}

class _FiberchatWrapperState extends State<FiberchatWrapper> {
  Locale? _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseGroupServices firebaseGroupServices = FirebaseGroupServices();
    final FirebaseBroadcastServices firebaseBroadcastServices =
        FirebaseBroadcastServices();
    if (this._locale == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Splashscreen(),
      );
    } else {
      return FutureBuilder(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Splashscreen(),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return FutureBuilder(
                  future: SharedPreferences.getInstance(),
                  builder:
                      (context, AsyncSnapshot<SharedPreferences> snapshot) {
                    if (snapshot.hasData) {
                      return MultiProvider(
                        providers: [
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderMESSAGESforBROADCASTCHATPAGE()),
                          //---
                          ChangeNotifierProvider(
                              create: (_) => StatusProvider()),
                          ChangeNotifierProvider(
                              create: (_) => TimerProvider()),
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderMESSAGESforGROUPCHAT()),
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderMESSAGESforLAZYLOADINGCHAT()),

                          ChangeNotifierProvider(
                              create: (_) => AvailableContactsProvider()),
                          ChangeNotifierProvider(create: (_) => Observer()),
                          Provider(create: (_) => SeenProvider()),
                          ChangeNotifierProvider(
                              create: (_) => DownloadInfoprovider()),
                          ChangeNotifierProvider(create: (_) => UserProvider()),
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderCALLHISTORY()),
                          ChangeNotifierProvider(
                              create: (_) => CurrentChatPeer()),
                        ],
                        child: StreamProvider<List<BroadcastModel>>(
                          initialData: [],
                          create: (BuildContext context) =>
                              firebaseBroadcastServices.getBroadcastsList(
                                  snapshot.data!.getString(Dbkeys.phone) ?? ''),
                          child: StreamProvider<List<GroupModel>>(
                            initialData: [],
                            create: (BuildContext context) =>
                                firebaseGroupServices.getGroupsList(
                                    snapshot.data!.getString(Dbkeys.phone) ??
                                        ''),
                            child: MaterialApp(
                              builder: (BuildContext? context, Widget? widget) {
                                ErrorWidget.builder =
                                    (FlutterErrorDetails errorDetails) {
                                  return CustomError(
                                      errorDetails: errorDetails);
                                };

                                return widget!;
                              },
                              theme: ThemeData(
                                  fontFamily: FONTFAMILY_NAME,
                                  primaryColor: fiberchatgreen,
                                  primaryColorLight: fiberchatgreen,
                                  indicatorColor: fiberchatLightGreen),
                              title: Appname,
                              debugShowCheckedModeBanner: false,
                              home: Initialize(
                                app: K11,
                                doc: K9,
                                prefs: snapshot.data!,
                                id: snapshot.data!.getString(Dbkeys.phone),
                              ),
                              // home: Homepage(
                              //   doc: ,
                              //   prefs: snapshot.data!,
                              //   currentUserNo:
                              //       snapshot.data!.getString(Dbkeys.phone),
                              //   isSecuritySetupDone: snapshot.data!.getString(
                              //               Dbkeys.isSecuritySetupDone) ==
                              //           null
                              //       ? false
                              //       : ((snapshot.data!
                              //                   .getString(Dbkeys.phone) ==
                              //               null)
                              //           ? false
                              //           : (snapshot.data!.getString(Dbkeys
                              //                       .isSecuritySetupDone) ==
                              //                   snapshot.data!
                              //                       .getString(Dbkeys.phone))
                              //               ? true
                              //               : false),
                              // ),

                              // ignore: todo
                              //TODO:---- All localizations settings----
                              locale: _locale,
                              supportedLocales: supportedlocale,
                              localizationsDelegates: [
                                DemoLocalization.delegate,
                                GlobalMaterialLocalizations.delegate,
                                GlobalWidgetsLocalizations.delegate,
                                GlobalCupertinoLocalizations.delegate,
                              ],
                              localeResolutionCallback:
                                  (locale, supportedLocales) {
                                for (var supportedLocale in supportedLocales) {
                                  if (supportedLocale.languageCode ==
                                          locale!.languageCode &&
                                      supportedLocale.countryCode ==
                                          locale.countryCode) {
                                    return supportedLocale;
                                  }
                                }
                                return supportedLocales.first;
                              },
                              //--- All localizations settings ended here----
                            ),
                          ),
                        ),
                      );
                    }
                    return MultiProvider(
                      providers: [
                        ChangeNotifierProvider(create: (_) => UserProvider()),
                      ],
                      child: MaterialApp(
                          theme: ThemeData(
                              fontFamily: FONTFAMILY_NAME,
                              primaryColor: fiberchatgreen,
                              primaryColorLight: fiberchatgreen,
                              indicatorColor: fiberchatLightGreen),
                          debugShowCheckedModeBanner: false,
                          home: Splashscreen()),
                    );
                  });
            }
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Splashscreen(),
            );
          });
    }
  }
}

class CustomError extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomError({
    Key? key,
    required this.errorDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0,
      width: 0,
    );
  }
}

void logError(String code, String? message) {
  if (message != null) {
    print('Error: $code\nError Message: $message');
  } else {
    print('Error: $code');
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
