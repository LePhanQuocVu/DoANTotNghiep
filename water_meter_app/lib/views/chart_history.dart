import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;


class ChartHistory extends StatefulWidget {
  
  const ChartHistory({super.key});

  @override
  State<ChartHistory> createState() => _ChartHistoryState();
}

class _ChartHistoryState extends State<ChartHistory> {
  late IO.Socket socket;
  late List<FlSpot> dataPoints = [];
  late String currentFlowRate = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dataReceiver();
  }
  void dataReceiver() {
      socket = IO.io('http://192.168.43.171:3000', // kết nối cùng wife với dt và dùng ip config de lay address
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
    
        // Lắng nghe sự kiện 'mqtt_data' từ server
      socket.on('mqtt_data', (data) {
        print('Dữ liệu nhận được: $data'); // Kiểm tra xem có nhận được dữ liệu không
        
        DateTime now = DateTime.now();
        final timestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
        final value = double.tryParse(data['data']) ?? 0;

        print(now.hour.toString() + ":" + now.minute.toString() + ":" + now.second.toString());
        print(value);
        setState(() {
          currentFlowRate = data['data'].toString();
          dataPoints.add(FlSpot(timestamp, value));
          if (dataPoints.length > 10) {
            dataPoints.removeAt(0);
          } // Giới hạn 50 điểm
        });
      });
  }
  @override
  void dispose() {
    socket.dispose();
    super.dispose();
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
              Icons.water_drop, // Biểu tượng giọt nước
              color: Color.fromARGB(255, 10, 81, 204),
              size: 50,
            ),
            const SizedBox(width: 10),
            Text(
              'Lịch sử ',
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
        
        body: Column(
        children: [
        SizedBox(height: 15,),
         SizedBox (
          height: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Tốc độ tức thời: ',
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.center),
                Text(currentFlowRate,
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.center),
            ] 
          ),
        ),
        const SizedBox (
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
                  Text('Biểu đồ lưu lượng',
                  style: TextStyle(
                    fontSize: 30, 
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 32, 32, 33),
                    letterSpacing: 2.0, 
                    shadows: [
                      Shadow(
                        offset: Offset(1.0, 2.0), // Đổ bóng (x,y)
                        blurRadius: 3.0, // Độ mờ của bóng
                        color: Colors.grey, // Màu bóng
                      ),
                    ],
                    ),
                    textAlign: TextAlign.center, // căn chỉnh chữ nằm giữa
                  ),

            ] 
          ),
        ),
        Container(
        padding: const EdgeInsets.all(4),
        width: 320,
        height: 360,
        child: LineChart(
          LineChartData(
            minX: dataPoints.isNotEmpty ? dataPoints.first.x : 0, 
            maxX: dataPoints.isNotEmpty ? dataPoints.last.x : 1,
            minY: 0,
            maxY: 200,  
            lineBarsData: [
              LineChartBarData(
                spots: dataPoints,
                isCurved: true,
                color: Colors.blue,// Màu đường biểu đồ
                barWidth: 3,
                isStrokeCapRound: true, 
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blue.withOpacity(0.3),
                )
              )
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 20,
                  getTitlesWidget: (value, meta) {
                    final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    return Text(
                      '${dateTime.hour}:${dateTime.minute}:${dateTime.second}',
                      style: const TextStyle(fontSize: 10),
                      );
                  },
                ),
                axisNameWidget: const Padding(
                  padding:  EdgeInsets.only(top: 0),
                  child:  Text(
                     'Time',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                )
              ),
              
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20, // Khoảng cách giữa các giá trị Y
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      value.toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                 ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
                ),
                getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              ),
              ),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                bottom: BorderSide(color: Colors.black, width: 1),
                left: BorderSide(color: Colors.black, width: 1),
              ),
              )
            ),
          ),
      ),
       
    ],
  ),
  
);

  }
}