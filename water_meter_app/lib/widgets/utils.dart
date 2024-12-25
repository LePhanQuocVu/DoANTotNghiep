
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
void showSnackBar(BuildContext context, String text) {
    if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

void httpErrorHandle({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess
}) {
  switch(response.statusCode) {
    case 200:
      onSuccess();
      break;
    case 400:
      showSnackBar(context, jsonDecode(response.body)['msg']);
      print(response.body);
      break;
    case 500:
      showSnackBar(context, jsonDecode(response.body)['error']);
      print(response.body);
      break;
    default:
      showSnackBar(context, response.body);
      print(response.body);
      
  }
}