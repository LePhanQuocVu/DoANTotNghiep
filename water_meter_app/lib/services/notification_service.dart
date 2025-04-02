import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/notifyModel.dart';
class NotificationService {
  final String baseUrl = "http://your-server-url"; // Đổi thành URL server của bạn

  // Hàm lấy danh sách thông báo theo userId
  Future<List<Notification>> getNotifications(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/notifications/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Notification.fromJson(json)).toList();
    } else {
      throw Exception('Không thể lấy danh sách thông báo');
    }
  }
}