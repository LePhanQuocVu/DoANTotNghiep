import 'package:flutter/material.dart';
import 'package:water_meter_app/services/socket_constant.dart';
import 'package:water_meter_app/views/BLE_Connect/access_point_page.dart';
import 'package:water_meter_app/views/BLE_Connect/scan_device_page.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
class SelectModePage extends StatefulWidget {
  const SelectModePage({super.key});

  @override
  State<SelectModePage> createState() => _SelectModePageState();
}

class _SelectModePageState extends State<SelectModePage> {
  late IO.Socket socket;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connectToSocket();
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
  void sendMode(String mode) {
        socket.emit('mode_selected', mode); // Gửi sự kiện 'mode_selected' với chế độ
        print('Send mode to server: $mode');
  }
  void _showModeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.wifi, color: Colors.blue),
                title: const Text("Access Point Mode"),
                onTap: () {
                  
                  // set(() {
                  //   // currentMode = "Access Point Mode";
                  // });
                  // _publishMessage('apmode');

                  this.sendMode('AC');
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AccessPointPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.cable, color: Colors.green),
                title: const Text("LAN Mode"),
                onTap: () {
                this.sendMode('LAN');
                  // setState(() {
                  //   currentMode = "LAN Mode";
                  // });
                  // _publishMessage('lanmode');
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScanDevicePage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bluetooth, color: Colors.teal),
                title: const Text("BLE Mode"),
                onTap: () {
                  this.sendMode('BLE');
                  // setState(() {
                  //   currentMode = "BLE Mode";
                  // });
                  //_publishMessage('blemode');
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScanDevicePage()),
                  );
                },
              ),
            ],
          ),
        );
      },
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
              Icons.swap_horiz , // Biểu tượng giọt nước
              color: Color.fromARGB(255, 22, 23, 23),
              size: 50,
            ),
            const SizedBox(width: 10),
            Text(
              'Lựa chọn kết nối',
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
      body: Center(
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(200, 200),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _showModeSelector(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.settings, size: 60),
              SizedBox(height: 10),
              Text("Select Mode", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      )
    );
  }
}

  