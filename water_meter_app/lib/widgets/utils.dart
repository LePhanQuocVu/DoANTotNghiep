
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
void showSnackBar(BuildContext context, String text) {
    // if(context.mounted) {
     
    // }
     ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(text),
              duration: Duration(seconds: 2),
            ),
          );
    
}

void httpErrorHandle({
  required http.Response respone,
  required BuildContext context,
  required VoidCallback onSuccess
}) {
  switch(respone.statusCode) {
    case 200:
      onSuccess;
      break;
    case 400:
      showSnackBar(context, jsonDecode(respone.body)['msg']);
      print(respone.body);
      break;
    case 500:
      showSnackBar(context, jsonDecode(respone.body)['error']);
      print(respone.body);
      break;
    default:
      showSnackBar(context, respone.body);
      print(respone.body);
      
  }
}