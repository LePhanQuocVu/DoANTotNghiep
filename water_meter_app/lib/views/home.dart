import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:water_meter_app/providers/user_provider.dart';
import 'package:water_meter_app/services/socket_constant.dart';
import 'package:water_meter_app/views/BLE_Connect/select_mode_page.dart';
import 'package:water_meter_app/views/batery_page.dart';
import 'package:water_meter_app/views/chart_history.dart';
import 'package:water_meter_app/views/install_devices_page.dart';

import '../providers/device_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomeContentPage extends StatefulWidget {
  //  final String? wellcomeMessage;

  const HomeContentPage({super.key});
  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
 
   bool statusDevice = false;
 
  @override void initState() {
    // TODO: implement initState
    super.initState();
   
   // dataReceiver();
  }
 
    @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
 
  int _currentIndex = 0;
  final userProvider = Provider.of<UserProvider>(context);
  final deviceProvider = Provider.of<DeviceProvider>(context);
  final List<Map<String, dynamic>> cardData = [
    {
      "title": "Thiết bị",
      "icon": Icons.punch_clock_outlined,
    },
    {
      "title": "Kết nối ESP32",
      "icon": Icons.bluetooth,
    },
    {
      "title": "Lịch sử sử dụng",
      "icon": Icons.history,
    },
    {
      "title": "Dung lượng Pin",
      "icon": Icons.pin,
    },
  ];

  if(deviceProvider.device.status != null) {
    setState(() {
      statusDevice = true;
    });
  } 
  final List<Widget> _pages = [
      const InstallDevicesPage(),
      const SelectModePage(),
      const HistoryPage(),
      const BateryPage(),
  ];

  return Scaffold(
    body: NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [ 
          // SliverAppBar
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title:  Text('SMART METER',
              style: TextStyle(
                fontSize: 30.0, // Kích thước font chữ
                  fontWeight: FontWeight.bold, // Độ đậm chữ
                  fontFamily: 'Roboto', // Font chữ, có thể thay đổi thành font khác
                  color: const Color.fromARGB(255, 3, 5, 6), // Màu chữ
                  letterSpacing: 2.0, // Khoảng cách giữa các chữ
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0), // Độ lệch bóng
                      blurRadius: 3.0, // Độ mờ của bóng
                      color: Colors.black.withOpacity(0.3), // Màu bóng chữ
                    ),
                  ],
                ),
              ),
              background: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ];
      },
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
               Row(
                  children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    backgroundImage:  AssetImage("assets/images/profile.jpg"),
                  ),
                  SizedBox(width: 20),
                  Column(
                    children: [
                      Text("Xin chào", 
                      style: TextStyle(color: Colors.black, fontSize: 20, 
                      fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 5,),
                    Text(
                      "${userProvider.user.name}",
                       style: TextStyle(color: Colors.black, fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                    ],
                  ),
                   
                ],
              ),
              SizedBox(height: 30,),  
              // Hàng chứa 2 hình tròn
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 209, 226, 241),
                  border: Border.all(
                    color: Color.fromARGB(255, 197, 201, 205),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5, // Độ lan rộng của bóng
                      blurRadius: 10, // Độ mờ của bóng
                      offset: Offset(0, 5), // Độ lệch của bóng (x, y)
                  ),
                  ] 
                ),
                // color: const Color.fromARGB(255, 197, 201, 205),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Tổng lưu lượng
                    // CircularIndicator(
                    //   title: "Lưu lượng tức thời",
                    //   valueText: ' $currentFlowRate',
                    //   unitText: 'L/phút',

                    //     color: Colors.blue,
                    //   ),
                      DeviceCirleIndicator(
                        title: "Lưu lượng tức thời",
                         valueText: '0',
                          unitText: 'L/phút',
                          isActive: statusDevice, 
                          color: Colors.blue),
                    // Trạng thái
                    CircularIndicatorStatus(
                       title: "Trạng thái",
                      isActive: false, // Thay đổi theo trạng thái BLE
                      colorActive: Colors.green,
                      colorInactive: const Color.fromARGB(255, 213, 211, 211),
                    ),
                   ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                 height: 400,
                    child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      itemCount: cardData.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (BuildContext, int index) {
                        final card = cardData[index];
                        return GestureDetector(
                          onTap: (){
                            setState(() {
                              _currentIndex = index;
                              if(index == 0) {
                                Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => const InstallDevicesPage()));
                              } else if(index == 1) {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (builder) => const SelectModePage()));
                              }
                              else if(index == 2) {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (builder) => const HistoryPage()));
                              }
                              else if(index == 3) {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (builder) => const HistoryPage()));
                              }
                            });
                          },
                          child: Card(
                            elevation: 4,
                            color: Colors.blue.shade100,
                            shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    card["icon"],
                                    size: 48,
                                    color: Colors.blue.shade800,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    card["title"],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ) ,
                          ),
                        );
                      }
                    ),
                  )
                ),
              
              ],
            ),
          )
        )
      ),
    );
  }
}

class DeviceCirleIndicator extends StatefulWidget {
  
  final String title;
  final String valueText;
  final String unitText;
  final bool isActive;
  final Color color;
  DeviceCirleIndicator({
    Key?key,
    required this.title,
    required this.valueText,
    required this.unitText,
    required this.isActive,
    required this.color
  }) : super(key: key);

  @override
  State<DeviceCirleIndicator> createState() => _DeviceCirleIndicatorState();
}

class _DeviceCirleIndicatorState extends State<DeviceCirleIndicator> {
  late String curentFlow;
  late IO.Socket socket;
  
  
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    curentFlow = widget.valueText;
    dataReceiver();
  }
   void dataReceiver() {
    socket = IO.io('${SocketConstant.socket_url}', // kết nối cùng wife với dt và dùng ip config de lay address
      IO.OptionBuilder()
      .setTransports(['websocket'])
      .enableReconnection()  // Kích hoạt reconnect tự động // for Flutter or Dart VM
      .build());
      
      socket.connect();
      socket.on('connection', (_) {
      print('Kết nối thành công');
      });
       socket.on('connect_error', (error) {
        print('Lỗi kết nối: $error');
      });
      socket.on('mqtt_data', (data) {
        print('Tốc độ tức thời: $data');
        setState(() {
          curentFlow = data['data'].toString();
        });
      });
  }
 
    @override
  void dispose() {
    super.dispose();
    socket.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                strokeWidth: 8.0,
                backgroundColor: widget.isActive ? widget.color.withOpacity(0.3) : Colors.grey,
                color: widget.isActive ? widget.color : Colors.grey,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  curentFlow,
                   style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    // color: Colors.black,
                    color: widget.isActive ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  widget.unitText, // Đơn vị (VD: L/phút)
                  style: TextStyle(
                    fontSize: 15,
                    color: widget.isActive ? Colors.black : Colors.grey,
                  ), 
                )
              ],
            ),
            
          ],
        ),
        SizedBox(height: 20,),
            Text(
              widget.isActive ? widget.title : "Chưa kích hoạt",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
              color: widget.isActive ? widget.color : Colors.grey),
            )
      ],
    );
  }
}


class CircularIndicatorStatus extends StatelessWidget {
  final String title;
  final bool isActive; // Trạng thái BLE (true: Kích hoạt, false: Chưa kích hoạt)
  final Color colorActive; // Màu sắc khi Kích hoạt
  final Color colorInactive; // Màu sắc khi Chưa kích hoạt
  
  const CircularIndicatorStatus({
     Key? key,
    required this.title,
    required this.isActive,
    required this.colorActive,
    required this.colorInactive,
  }) : super(key: key);

  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? colorActive.withOpacity(0.3): colorInactive.withOpacity(0.3),
            ),
          child: Center(
            child: Icon(
              isActive ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
              size: 40,
              color: isActive ? colorActive : colorInactive,
            ),
        
          ),
          ),
           SizedBox(height: 20),
           Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
           ),
           Text(
            isActive ? "Đã Kích hoạt" : "Chưa kích hoạt",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color:  isActive ? colorActive : colorInactive
            ),
           )
      ],
    );
  }
}
