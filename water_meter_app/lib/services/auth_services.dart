
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:water_meter_app/models/usersModel.dart';
import 'package:http/http.dart' as http;
import 'package:water_meter_app/providers/user_provider.dart';
import 'package:water_meter_app/services/api_constant.dart';
import 'package:water_meter_app/views/home.dart';
import 'package:water_meter_app/views/home_page.dart';
import 'package:water_meter_app/views/login_page.dart';
import 'package:water_meter_app/widgets/utils.dart';
import 'package:provider/provider.dart';

import '../services/api_constant.dart';
class AuthServices {

 /* SIGN UP */
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      User user = User(
        id: '',
        name: name,
        password:  password,
        email: email,
        token: ''
      );

    print('Call LINK: ${ApiConstant.baseUrl}/api/register');
      http.Response res = await http.post(
        Uri.parse('${ApiConstant.baseUrl}/api/register'),
        body: user.toJson(),
        headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8'
        }
      );
      
      httpErrorHandle(
      response: res,
      context: context,
      onSuccess: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Tạo tài khoản thành công!",
                 style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color.fromARGB(255, 70, 140, 231), 
              duration: const Duration(seconds: 2),
            )
          );
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
       }
      );
    } catch (e) {
        print("error: ${e}");
        showSnackBar(context, e.toString());
    }
  }
  
 /* SIGN UP */

 void signInUser({
    required BuildContext context,
    required String email,
    required String password,
 }) async {
  try{
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    print('Call LINK: ${ApiConstant.baseUrl}/api/login');
    final url = Uri.parse('${ApiConstant.baseUrl}/api/login');

    final res = await http.post(
      url,
      headers: <String, String>{
         'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        }),
    );
        print('${res.body}');
       print('Status code: ${res.statusCode}');
  
    httpErrorHandle(
      response: res,
      context: context,
      onSuccess: () async {
          userProvider.setUser(res.body);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Đâng nhập thành công!",
                 style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color.fromARGB(255, 70, 140, 231), 
              duration: const Duration(seconds: 2),
            )
          );
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
       }
      );

  } catch(e) {
     showSnackBar(context, e.toString());
      print("error: ${e}");
  }
 }

 /**LOG OUT */

 void signOut(BuildContext context) {
    final navigator = Navigator.of(context);
    
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()), 
      (route) => false);
 }

}