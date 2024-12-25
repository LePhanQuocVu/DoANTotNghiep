// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? address;
  final String? image;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.address,
     this.image,
    this.token,
    }
  );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'image': image,
      'token': token,
    };
  }


  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      phone: map['phone'] != null ? map['phone'] as String : null, // Kiểm tra null
      address: map['address'] != null ? map['address'] as String : null, // Kiểm tra null
      image: map['image'] != null ? map['image'] as String : null, // Kiểm tra null
      token: map['token'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source) as Map<String, dynamic>);
}
