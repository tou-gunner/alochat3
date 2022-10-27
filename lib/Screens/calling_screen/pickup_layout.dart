//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:alochat/main.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alochat/Screens/splash_screen/splash_screen.dart';
import 'package:alochat/Services/Providers/Observer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alochat/Models/call.dart';
import 'package:alochat/Services/Providers/user_provider.dart';
import 'package:alochat/Models/call_methods.dart';
import 'package:alochat/Screens/calling_screen/pickup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final SharedPreferences prefs;
  final CallMethods callMethods = CallMethods();

  PickupLayout({
    required this.scaffold,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final Observer observer = Provider.of<Observer>(context);

    return observer.isOngoingCall == true
        ? scaffold
        : (userProvider.getUser != null)
            ? StreamBuilder<DocumentSnapshot>(
                stream:
                    callMethods.callStream(phone: userProvider.getUser!.phone),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.data() != null) {
                    Call call = Call.fromMap(
                        snapshot.data!.data() as Map<dynamic, dynamic>);

                    if (!call.hasDialled!) {
                      return _PickUpWrapper(
                        prefs: prefs,
                        call: call,
                        currentuseruid: userProvider.getUser!.phone,
                      );
                    }
                  }
                  return scaffold;
                },
              )
            : Splashscreen();
  }
}

class _PickUpWrapper extends StatefulWidget {
  final SharedPreferences prefs;
  final Call call;
  final String? currentuseruid;
  const _PickUpWrapper({Key? key, required this.prefs, required this.call, required this.currentuseruid}) : super(key: key);

  @override
  State<_PickUpWrapper> createState() => _PickUpWrapperState();
}

class _PickUpWrapperState extends State<_PickUpWrapper> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    AwesomeNotifications().getInitialNotificationAction(
        removeFromActionEvents: false
    ).then((receivedAction) {
      // if(receivedAction?.channelKey == 'call_channel') {
      //   setInitialPageToCallPage();
      // } else {
      //   setInitialPageToHomePage();
      // }
      print(receivedAction);
      if (mounted) {
        setState(() {
          _ready = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ready ?
    PickupScreen(
      prefs: widget.prefs,
      call: widget.call,
      currentuseruid: widget.currentuseruid,
    ) :
    Center(
      child: CircularProgressIndicator(),
    );
  }
}

