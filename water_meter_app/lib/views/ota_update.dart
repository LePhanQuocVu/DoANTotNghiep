import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:water_meter_app/providers/user_provider.dart';
import 'package:water_meter_app/services/api_constant.dart';
import '../services/api_constant.dart';
import 'package:intl/intl.dart';  // Thêm package này (nếu chưa)
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:water_meter_app/services/socket_constant.dart';

class GetLatestFirmwareScreen extends StatefulWidget {
  const GetLatestFirmwareScreen({super.key});

  @override
  _GetLatestFirmwareScreenState createState() => _GetLatestFirmwareScreenState();
}

class _GetLatestFirmwareScreenState extends State<GetLatestFirmwareScreen> {
  Map<String, dynamic>? firmwareData;
  bool isLoading = true;
  late UserProvider userProvider;
  late IO.Socket socket;
  var userId;
  @override
  void initState() {
    
    super.initState();
    fetchLatestFirmware();
    connectToSocket();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    userId = userProvider.user.id;
  }

  void connectToSocket(){
    socket = IO.io(
      '${SocketConstant.socket_url}', // Thay bằng địa chỉ IP server của bạn
      IO.OptionBuilder()
          .setTransports(['websocket']) // Sử dụng WebSocket
          .disableAutoConnect() // Không tự động kết nối
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('Kết nối thành công với server');
    });

    socket.onDisconnect((_) {
      print('Đã ngắt kết nối với server');
    });
  } 
  void sendMessageUpdateOta(String mode) {
         final otaData = {
          'userId': userId,
          'message': mode
      };
      socket.emit('ota_update_requested', otaData); //  gửi đúng event đã setup bên server
      print('Sent OTA update: $otaData');
  }

  String formatTimestamp(dynamic timestamp) {
      if (timestamp == null) return 'N/A';
      try {
        if (timestamp is int) {
          return DateFormat('dd/MM/yyyy HH:mm')
              .format(DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal());
        } else if (timestamp is String) {
          return DateFormat('dd/MM/yyyy HH:mm')
              .format(DateTime.parse(timestamp).toLocal());
        } else {
          return 'Invalid';
        }
      } catch (e) {
        return 'Invalid';
      }
    }
  Future<void> fetchLatestFirmware() async {
    final url = Uri.parse('${ApiConstant.baseUrl}/user/api/latestFirmware');

    // final url = Uri.parse('http://192.168.43.171:3000/user/api/latestFirmware');
    print('url: ${url}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print('DatA: ${response.body}');
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          firmwareData = responseData['firmware'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load firmware. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching firmware: $e');
    }
  }

  void uploadNewFirmware() {
   showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Xác nhận cập nhật'),
        content: const Text('Bạn có chắc chắn muốn cập nhật firmware mới không?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng dialog
            },
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              // Gửi yêu cầu OTA
              sendMessageUpdateOta("1");

              Navigator.of(context).pop(); // Đóng dialog sau khi gửi

              // Thông báo đã gửi thành công
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Yêu cầu cập nhật firmware đã được gửi'),
                ),
              );
            },
            child: const Text(
              'Xác nhận',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
  }

  @override
   Widget buildFirmwareCard() {
    if (firmwareData == null) {
      return const Center(child: Text('No firmware available.'));
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                 Text(
                  'Phiên bản : ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                ),
                 const SizedBox(width: 8),
                  Text(
                    firmwareData!['version'] ?? '',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Mô tả: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                Text(
                  firmwareData!['description'] ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                 Text(
                  'Tên file: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                Text(
                  firmwareData!['fileName'] ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
              Text(
              'Cập nhật lúc:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              ),
             const SizedBox(width: 8),
              Text(
                formatTimestamp(firmwareData!['createdAt']),
                style: const TextStyle(fontSize: 14),
              )
              ],
            )
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
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
              Icons.cloud_upload, // Biểu tượng giọt nước
              color: Color.fromARGB(255, 22, 23, 23),
              size: 50,
            ),
            const SizedBox(width: 10),
            Text(
              'Firmware update',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(child: SingleChildScrollView(child: buildFirmwareCard())),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: uploadNewFirmware,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 195, 197, 201),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cập nhật firmware mới',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
