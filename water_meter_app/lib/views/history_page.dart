// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'dart:async';

// class HistoryPage extends StatefulWidget {
//   const HistoryPage({super.key});

//   @override
//   State<HistoryPage> createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   late IO.Socket socket;
//   //FlSpot(0,0),FlSpot(10, 22.2),FlSpot(10, 15),FlSpot(3, 20)]
//   late List<FlSpot> dataPoints = []; 
//   @override 
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//      connectToSocket();
//   }

//   void connectToSocket() {
//     socket = IO.io(
//       'http://192.168.43.171:3000', // Thay bằng IP máy tính chạy Node.js server
//       IO.OptionBuilder()
//           .setTransports(['websocket']) // Sử dụng websocket
//           .build(),
//     );

//     // Khi kết nối thành công
//     socket.onConnect((_) {
//       print('Connected to server');
//     });

//     // Khi nhận dữ liệu từ Node.js server
//     socket.on('mqtt_data', (data) {
//       print('Received data: $data');

//       final timestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
//       final value = double.tryParse(data['data']) ?? 0;

//       setState(() {
//         dataPoints.add(FlSpot(timestamp, value)); // Thêm điểm dữ liệu vào biểu đồ
//         if (dataPoints.length > 50) dataPoints.removeAt(0); // Giới hạn 50 điểm
//       });
//     });

//     // Khi ngắt kết nối
//     socket.onDisconnect((_) {
//       print('Disconnected from server');
//     });
//   }
//  @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.blue,
//       child: const AspectRatio(
//         aspectRatio: 1.25,
//         child: Column(
//           children: [
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: 10),
//               child: Text(
//                 'Learned words per day',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 2,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: EdgeInsets.only(right: 25, left: 2.5, bottom: 10),
//                 child: ,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );  
//   }
// }
  
// class _LineChart extends  StatelessWidget {
//   const _LineChart();
//   @override 
//   Widget build(BuildContext context,  List<FlSpot> data) {
//     return LineChart(lineChartData);
//   }
// }
  
//   LineChartData get lineChartData  => LineChartData(
//     lineTouchData: lineTouchData(),
//     gridData: gridData(),
//     titlesData: titlesData(),
//     borderData: borderData(),
//     //lineBarsData: lineBarsData(),
//     minX: dataPoints.isNotEmpty ? dataPoints.first.x : 0,
//     maxX: dataPoints.isNotEmpty ? dataPoints.last.x : 1,
//     minY: 0,
//     maxY: 6,
//     );
//     LineTouchData lineTouchData() => const LineTouchData(
//       handleBuiltInTouches: true,
//     );

//   FlGridData gridData() => FlGridData(
//     show: true,
//     drawVerticalLine: true,
//     horizontalInterval: 1,
//     verticalInterval: 1,
//     getDrawingHorizontalLine: (double _) => FlLine(
//       color: Colors.white.withOpacity(0.2),
//       strokeWidth: 1,
//     ),
//     getDrawingVerticalLine: (double _) => FlLine(
//       color: Colors.white.withOpacity(0.2),
//       strokeWidth: 1,
//     ),
//   );


//   FlTitlesData titlesData() => FlTitlesData(
//     bottomTitles: AxisTitles(
//       sideTitles: bottomTitles(),
//     ),
//     rightTitles: const AxisTitles(
//       sideTitles: SideTitles(showTitles: false),
//     ),
//     topTitles: const AxisTitles(
//       sideTitles: SideTitles(showTitles: false),
//     ),
//     leftTitles: AxisTitles(
//       sideTitles: leftTitles(),
//     ),
//   );

//   SideTitles bottomTitles() => SideTitles(
//     getTitlesWidget: bottomTitleWidgets,
//     interval: 1,
//     reservedSize: 32,
//     showTitles: true,
//   );
  
//   FlBorderData borderData() => FlBorderData(
//     show: true,
//     border: Border(
//       bottom: BorderSide(
//         color: const Color(0xFF50E4FF).withOpacity(0.2),
//         width: 4,
//       ),
//       left: const BorderSide(color: Colors.transparent),
//       right: const BorderSide(color: Colors.transparent),
//       top: const BorderSide(color: Colors.transparent),
//     ),
//   );

//   SideTitleWidget bottomTitleWidgets(double value, TitleMeta meta) {
//     String text = switch (value.toInt()) {
//       0 => 'Mon',
//       1 => 'Tue',
//       2 => 'Wed',
//       3 => 'Thu',
//       4 => 'Fri',
//       5 => 'Sat',
//       6 => 'Sun',
//       _ => '',
//     };
//   }



//     List<LineChartBarData> lineBarsData() => [
//         lineChartBarDataCurrentWeek(),
//         lineChartBarDataPreviousWeek(),
//       ];

//   LineChartBarData lineChartBarDataCurrentWeek() => LineChartBarData(
//     isCurved: true,
//     curveSmoothness: 0,
//     color: const Color(0xFF50E4FF),
//     barWidth: 2,
//     isStrokeCapRound: true,
//     dotData: const FlDotData(show: true),
//     belowBarData: BarAreaData(show: false),
//     spots: const [
//       FlSpot(0, 1),
//       FlSpot(1, 0),
//       FlSpot(2, 2),
//       FlSpot(3, 2),
//       FlSpot(4, 3),
//       FlSpot(5, 1),
//       FlSpot(6, 0),
//     ],
//   );

//   LineChartBarData lineChartBarDataPreviousWeek() => LineChartBarData(
//     isCurved: true,
//     curveSmoothness: 0,
//     color: Colors.deepOrangeAccent.withOpacity(0.8),
//     barWidth: 2,
//     isStrokeCapRound: true,
//     dotData: const FlDotData(show: true),
//     belowBarData: BarAreaData(show: false),
//     spots: const [
//       FlSpot(0, 0),
//       FlSpot(1, 1),
//       FlSpot(2, 2),
//       FlSpot(3, 4),
//       FlSpot(4, 5),
//       FlSpot(5, 0),
//       FlSpot(6, 1),
//     ],
//   );
// }
//  LineChartBarData lineChartBarDataPreviousWeek() => LineChartBarData(
//     isCurved: true,
//     curveSmoothness: 0,
//     color: Colors.deepOrangeAccent.withOpacity(0.8),
//     barWidth: 2,
//     isStrokeCapRound: true,
//     dotData: const FlDotData(show: true),
//     belowBarData: BarAreaData(show: false),
//     spots: const [
//       FlSpot(0, 0),
//       FlSpot(1, 1),
//       FlSpot(2, 2),
//       FlSpot(3, 4),
//       FlSpot(4, 5),
//       FlSpot(5, 0),
//       FlSpot(6, 1),
//     ],
//   );

//   SideTitles leftTitles() => SideTitles(
//     getTitlesWidget: leftTitleWidgets,
//     interval: 1,
//     reservedSize: 40,
//     showTitles: true,
//   );
//   Text leftTitleWidgets(double value, TitleMeta meta) {
//     String text = switch (value.toInt()) {
//       1 => '5',
//       2 => '10',
//       3 => '15',
//       4 => '20',
//       5 => '25',
//       6 => '30',
//       7 => '35',
//       _ => '',
//     };

//     return Text(
//       text,
//       textAlign: TextAlign.center,
//       style: const TextStyle(
//           fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
//     );
//   }

 
//   }
// }