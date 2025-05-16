import 'dart:convert';
// import 'dart:ffi';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart';

class Devices {
  final String id;
  final String user_id;
  final String location;
  final String deviceType;
  final bool? status;
  final int? bateryLevel;
  // final String? image;
  // final String deviceName;
  final String longitude;
  final String latitude;
  final String? iotToken;
  final DateTime? create_at;
  final DateTime? update_at;
  
  Devices({
    required this.id,
    required this.user_id,
    required this.location,
    required this.deviceType,
    this.status,
    this.bateryLevel,
    required this.longitude,
    required this.latitude,
    // this.image,
    // required this.deviceName,
    this.iotToken,
    this.create_at,
    this.update_at,
  });

  Map<String,dynamic> toMap() {
    return <String, dynamic> {
      'id': id,
      'user_id': user_id,
      'location': location,
      'type': deviceType,
      'status': status,
      'bateryLevel': bateryLevel,
      'longitude': longitude,
      'latitude': latitude,
      'iotToken': iotToken,
      'create_at': create_at,
      'update_at': update_at
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
      longitude: map['longitude'] != null ? map['longitude']  as String : '',
      latitude: map['latitude'] != null ? map['latitude'] as String : '',
      iotToken: map['iotToken'] != null ? map['iotToken'] as String : null,
      create_at: map['create_at'] != null
            ? DateTime.parse(map['create_at'] as String)
            : null, // Chuyển đổi chuỗi ngày giờ thành DateTime
      update_at: map['update_at'] != null
            ? DateTime.parse(map['update_at'] as String)
            : null, // Chuyển đổi chuỗi ngày giờ thành DateTime      
    );
  }
  String toJson() => json.encode(toMap());
  factory Devices.fromJson(String source) => Devices.fromMap(jsonDecode(source) as Map<String, dynamic>);
  // String toJson() => jsonEncode(toMap());

}