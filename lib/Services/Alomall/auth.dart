import 'dart:convert';

import 'package:alochat/Services/Alomall/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

class AloAuth {

  static AloAuth instance() {
    return AloAuth();
  }

  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Duration timeout,
    required Function(PhoneAuthCredential credential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout
  }) async {
    try {
      var response = await Dio().post(
        'https://alomall.la/demo/api/mobile/index.php?w=authentication&t=get_otp',
        data: FormData.fromMap({
          'phoneNumber': phoneNumber
        })
      );
      var data = jsonDecode(response.data) as Map<String, dynamic>;
      if (data['code'] != 200) {
        verificationFailed(FirebaseAuthException(
          message: data['message'],
          code: '400',
        ));
      }
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
      'https://alomall.la/demo/api/mobile/index.php?w=authentication&t=verify_otp',
      data: FormData.fromMap({
        'phoneNumber': phone,
        'otp': otp
      })
    );
    var data = jsonDecode(response.data) as Map<String, dynamic>;
    if (data['code'] != 200) {
      throw Exception(data['message']);
    }
    var token = data['datas']['token'];

    return await verifyToken(token);
  }

  static Future<AloUser?> verifyToken(String token) async {
    var response = await Dio().post(
        'https://alomall.la/demo/api/mobile/index.php?w=authentication&t=verify_token',
        data: FormData.fromMap({
          'accessToken': token
        })
    );
    var data = jsonDecode(response.data) as Map<String, dynamic>;
    if (data['code'] != 200) {
      throw Exception(data['message']);
    }
    var datas = data['datas'];
    return AloUser(
        uid: datas['member_id'],
        name: datas['member_name'],
        phone: datas['member_mobile'],
        photoURL: datas['member_avatar']
    );
  }

  Future<void> logout() async {

  }

}