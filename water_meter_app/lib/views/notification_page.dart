
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_meter_app/providers/user_provider.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
 
  @override
  void initState() {
    super.initState();
    getDeviceToken();
  }

  void getDeviceToken() async {
    final notificationSettings = await FirebaseMessaging.instance.requestPermission(provisional: true);

    // For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
    // APNS token is available, make FCM plugin API requests...
      print('APNS token: ${apnsToken}');
    }
    // Send this token to your backend

    FirebaseMessaging.instance.onTokenRefresh
    .listen((fcmToken) {
      // TODO: If necessary send token to application server.

      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    })
    .onError((err) {
      // Error getting token.
    });
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
  }
  
 
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    final List<Map<String, dynamic>> notification = [
      {
        "UserId": "Vũ",
        "title": "Thông báo",
        "icone": Icons.notification_add,
        "description": "Đã lắp đặt thiết bị thành công!",
        "date": "12/12/2024",
        "time" : "12:3",
        "type": "Thông báo"
      },
       {
        "UserId": "Vũ",
        "title": "Cảnh báo",
        "icone": Icons.warning,
        "description": "Xuất hiện rò rỉ nước",
        "date": "12/12/2024",
        "time" : "12:3",
        "type": "Cảnh báo"
      }
    ];
    return Scaffold(
     appBar: PreferredSize(
        preferredSize: Size.fromHeight(70), // Chỉ định chiều cao cho AppBar
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20), // Bo góc dưới bên trái
            bottomRight: Radius.circular(20), // Bo góc dưới bên phải
          ), 
          child: AppBar(
          title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(
              Icons.notification_add, // Biểu tượng giọt nước
              color: Color.fromARGB(255, 22, 23, 23),
              size: 50,
            ),
            const SizedBox(width: 10),
            Text(
              'Thông báo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
                letterSpacing: 1.2, // Giãn cách chữ
                shadows: [
                  Shadow(
                    offset: Offset(1.0, 2.0), // Đổ bóng
                    blurRadius: 3.0, // Độ mờ của bóng
                    color: Colors.black.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ],
        ),
          flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
              Color.fromARGB(255, 144, 158, 183),
                Colors.lightBlueAccent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            
          ),
        ),
        centerTitle: true,
        elevation: 8, // Đổ bóng dưới AppBar
        toolbarHeight: 70,
        ),
        ),
     ),
     body: ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: notification.length,
      itemBuilder:(context,index) {
        final notify = notification[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: Card(
            color: notify["type"] == "Cảnh báo"
                      ? Colors.red[100]
                      : Colors.green[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                  backgroundColor: notify["type"] == "Cảnh báo"
                      ? const Color.fromARGB(255, 224, 33, 52)
                      : const Color.fromARGB(255, 4, 124, 40),
                  child: Icon(notify["icone"], color: Colors.white),
                  ),
                  title: Text(
                    notify["title"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: notify["type"] == "Cảnh báo"
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notify["description"],
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                        "Ngày: ${notify["date"]} | Giờ: ${notify["time"]}",
                        style: const TextStyle(fontSize: 16, color: Color.fromARGB(255, 114, 114, 114)),
                      ),
                    const SizedBox(width: 8),
                  ],
                ),
                SizedBox(height: 8,)
              ],
            ),
          )
        );
      }
     ),
    );
  }
}