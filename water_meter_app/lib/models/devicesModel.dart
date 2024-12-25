import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class Devices {
  final String id;
  final String user_id;
  final String location;
  final String deviceType;
  final bool? status;
  final int? bateryLevel;
  // final String? image;
  // final String deviceName;
   final DateTime? create_at;

  Devices({
    required this.id,
    required this.user_id,
    required this.location,
    required this.deviceType,
    this.status,
    this.bateryLevel,
    // this.image,
    // required this.deviceName,
    this.create_at,
  });

  Map<String,dynamic> toMap() {
    return <String, dynamic> {
      'id': id,
      'user_id': user_id,
      'location': location,
      'type': deviceType,
      'status': status,
      'bateryLevel': bateryLevel,
      
    };
  }


  factory Devices.fromMap(Map<String, dynamic> map) {
   // return Devices(user_id: user_id, location: location, deviceType: deviceType)
    return Devices(
      id: map['_id'] as String,
      user_id: map['user_id'] as String,
      location: map['location'] as String,
      deviceType: map['deviceType'] as String,
      status: map['status'] != null ? map['status'] as bool : null, // Kiểm tra null
      bateryLevel: map['bateryLevel'] != null ? map['bateryLevel'] as int : null, // Kiểm tra null
      create_at: map['create_at'] != null
            ? DateTime.parse(map['create_at'] as String)
            : null, // Chuyển đổi chuỗi ngày giờ thành DateTime
    );
  }
  String toJson() => json.encode(toMap());
  factory Devices.fromJson(String source) => Devices.fromMap(jsonDecode(source) as Map<String, dynamic>);
  // String toJson() => jsonEncode(toMap());

}