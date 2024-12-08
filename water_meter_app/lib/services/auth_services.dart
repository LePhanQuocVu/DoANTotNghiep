
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:water_meter_app/models/usersModel.dart';
import 'package:http/http.dart' as http;
import 'package:water_meter_app/providers/user_provider.dart';
import 'package:water_meter_app/views/home_page.dart';
import 'package:water_meter_app/views/login_page.dart';
import 'package:water_meter_app/widgets/utils.dart';
import 'package:provider/provider.dart';
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

      http.Response res = await http.post(
        Uri.parse('http://10.0.186.166:3000/api/register'),
        body: user.toJson(),
        headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8'
        }
      );
      
      if(res.statusCode == 200) {
        showSnackBar(context, "Tạo tài khoản thành công!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        // Navigator.pushReplacement(context, '/login');
      } else {

      }
      // httpErrorHandle(
      //   respone: res,
      //   context: context,
      //   onSuccess: () {
      //     showSnackBar(context, 
      //     'Account created! Login with the same credentials');
      //   },
      // );
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
    final url = Uri.parse('http://10.0.186.166:3000/api/login');

    final response = await http.post(
      url,
      headers: <String, String>{
         'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        }),
    );
  
    if(response.statusCode == 200) {
      userProvider.setUser(response.body);
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false);
        // Chờ cho SnackBar hoàn thành thời gian hiển thị
    //await Future.delayed(Duration(seconds: 2));
    showSnackBar(context, "Đăng nhập thành công");
    } else{
      showSnackBar(context, jsonDecode(response.body)['msg'] );
    }
    // httpErrorHandle(
    //   respone: res,
    //   context: context,
    //   onSuccess: () async {
    //     //  SharedPreferences prefs = await SharedPreferences.getInstance();
    //       userProvider.setUser(res.body);
    //     //  await prefs.setString('x-auth-token', jsonDecode(res.body)['token']);

    //       navigator.pushAndRemoveUntil(
    //         MaterialPageRoute(
    //           builder: (context) => const HomePage(),
    //           ),
    //           (route) => false,
    //       );
    //    }
    //   );

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