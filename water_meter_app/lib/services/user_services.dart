import 'package:flutter/material.dart';
import 'package:water_meter_app/services/api_constant.dart';
import 'package:water_meter_app/widgets/utils.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserServices {
  // UPDATE USE
  // void updateUser( {
  // String? phone,
  // String? address,
  // }
  // ) async {
  //   try {
    
  //   }
  //   catch(e) {
      
  //   }
  // }

  // UPDATE fcmToken

  void updateFcmToken({
    required BuildContext context,
    required String userId,
    String? fcmToken
  }) async {
    var userProvider = Provider.of<UserProvider>(context, listen: false);

    final url = Uri.parse('${ApiConstant.baseUrl}/user/api/${userId}/updateFcmToken');
    print('API To update Fcmtoken: ${url}');
    final res = await http.put(
      url,
      headers: <String, String>{
         'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'fcmToken': fcmToken
      })
    );
    
    print('${res.body}');
    print('Status code: ${res.statusCode}');
    final jsonResponse = jsonDecode(res.body);

    if(res.statusCode == 200) {
      print('Update Success');
    } else if(res.statusCode == 400) {
      ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "FCMtoken not found!",
                 style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Color.fromARGB(255, 208, 13, 13), 
              duration: const Duration(seconds: 2),
            )
          );
    } 
  }
  void getAllNotifications ({
    required String userId
  }) async{
    final url = Uri.parse('${ApiConstant.baseUrl}/user/api/getAllNotifications/${userId}');
    final res = await http.get(url); 
    
  }
  void getLatestFirmware() async {
    final url = Uri.parse('${ApiConstant}/user/getLatestFirmware');
    final res = await http.get(url);
  }
}