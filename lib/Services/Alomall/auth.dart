import 'dart:convert';

import 'package:alochat/Services/Alomall/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

class AloAuth {

  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Duration timeout,
    required Function(PhoneAuthCredential credential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout
  }) async {
    try {
      await Dio().post(
        'https://alomall.la/demo/api/mobile/index.php?w=authentication&t=get_otp',
        data: jsonEncode({
          'phoneNumber': phoneNumber,
          'isRegister': false
        })
      );
      verificationCompleted(PhoneAuthProvider.credential(
        verificationId: phoneNumber,
        smsCode: ''
      ));
      codeSent(phoneNumber, null);
    } catch(ex) {
      verificationFailed(FirebaseAuthException(
        message: ex.toString(),
        code: '400',
      ));
    }
  }

  static Future<AloUser?> login(String phone, String otp) async {
    var response = await Dio().post(
      'https://alomall.la/demo/api/mobile/index.php?w=authentication&t=verify',
      data: jsonEncode({
        'phoneNumber': phone,
        'otp': otp
      })
    );
    var data = response.data as Map<String, dynamic>;
    return AloUser(
      uid: data['id'],
      name: data['name'],
      phone: data['phone'],
      photoURL: data['image']
    );
  }
}