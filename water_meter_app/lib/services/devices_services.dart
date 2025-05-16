import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_meter_app/models/devicesModel.dart';
import 'package:water_meter_app/providers/device_provider.dart';
import 'package:water_meter_app/services/api_constant.dart';
import 'package:water_meter_app/utils/global.dart';
import 'package:water_meter_app/widgets/utils.dart';
import 'package:http/http.dart' as http;
class DevicesServices {
  Future<void> createDevice({
  required BuildContext context,
  required String user_id,
  required String location,
  required String type,
  required String longitude,
  required String latitude,
  String? iotToken,
  }) async{
    try {
      final device = Provider.of<DeviceProvider>(context, listen: false);
      final url = Uri.parse('${ApiConstant.baseUrl}/water/api/create');
      print("📌 Dữ liệu gửi lên: ${jsonEncode({
        'user_id': user_id,
        'location': location,
        'deviceType': type,
        'longitude': longitude,
        'latitude': latitude,
        'iotToken': iotToken
      })}");
      final res = await http.post(
        url,
         headers: <String, String>{
         'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String,dynamic> {
          'user_id': user_id,
          'location': location,
          'deviceType': type,
          'longitude': longitude,
          'latitude': latitude,
          'iotToken': iotToken
        }),
      );
      print('${res.body}');
       print('Status code: ${res.statusCode}');
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Đã thêm thiết bị mới!",
                 style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color.fromARGB(255, 70, 140, 231), 
              duration: const Duration(seconds: 2),
            ),
           
          );
          // set devide for provider
          device.setDevice(res.body);
         
          // await updateFcmToken(context, )
        });

    } catch (e) {
      showSnackBar(context, e.toString());
      print("error: ${e}");
    }
  }

  Future<Devices> getDeviceByUserId(String user_id) async{
    final url = Uri.parse('${ApiConstant.baseUrl}/api/device/getByUserId/$user_id');
    final res = await http.get(url);

    if (res.statusCode == 200) {
      //nhận được từ Sever

      print('Json: ${res.body}');
      // Chuyển đổi từ JSON sang đối tượng Device
      
      return Devices.fromJson(res.body);
    } else {
      throw Exception('Failed to load device with id $user_id');
    }
  }
}