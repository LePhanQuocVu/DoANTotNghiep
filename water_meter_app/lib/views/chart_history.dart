import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:water_meter_app/models/dataModel.dart';
import 'package:water_meter_app/providers/user_provider.dart';
import 'package:water_meter_app/services/api_constant.dart';
import 'package:water_meter_app/services/socket_constant.dart';
import 'package:water_meter_app/widgets/utils.dart';
import '../providers/device_provider.dart';
import 'package:http/http.dart' as http;
import '../providers/user_provider.dart';
import 'dart:convert';
import 'package:intl/date_symbol_data_local.dart'; // Thêm dòng này

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late UserProvider userProvider;
  late DeviceProvider deviceProvider;
  bool isSetup = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userProvider = Provider.of<UserProvider>(context,listen: false);
    deviceProvider = Provider.of<DeviceProvider>(context,listen: false);
    // final userProvider = Provider.of<UserProvider>(context, listen: false);
    if(deviceProvider.deviceName != "") {
      setState(() {
        isSetup = true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    deviceProvider = Provider.of<DeviceProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70), // Chỉ định chiều cao cho AppBar
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
        
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              if(!isSetup) ...{
                   Container(
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text(
                      'Chưa có thiết bị nào được cài đặt.',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    ],
                  ),
                ),
              }
              else ...{
                ChartHistory(),
                RealTimeHistory(),
              }
            ],
          ),
        ),
      )
    );
  }
}

class ChartHistory extends StatefulWidget {
  
  const ChartHistory({super.key});

  @override
  State<ChartHistory> createState() => _ChartHistoryState();
}

class _ChartHistoryState extends State<ChartHistory> {
  late IO.Socket socket;
  late List<FlSpot> dataPoints = [];
  late String currentFlowRate = "";
  late DeviceProvider deviceProvider;
  // //final deviceProvider = Provider.of<DeviceProvider>;
  late UserProvider userProvider;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userProvider = Provider.of<UserProvider>(context,listen: false);
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
    
        // Lắng nghe sự kiện 'mqtt_data' từ server
      print('nhận được từ socket: ${userProvider.user.id}');
      socket.on('mqtt_data/${userProvider.user.id}', (data) {
        print('Dữ liệu nhận được: $data'); // Kiểm tra xem có nhận được dữ liệu không
        print('Data: ${data['flowRate']}');
        DateTime now = DateTime.now();
        final timestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
        final value = double.tryParse(data['flowRate']?.toString() ?? '') ?? 0;
        print(now.hour.toString() + ":" + now.minute.toString() + ":" + now.second.toString());
        print(value);
        setState(() {
          currentFlowRate = data['flowRate'].toString();
          dataPoints.add(FlSpot(timestamp, value));
         // deviceProviderupdateFlowRate(currentFlowRate);
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
    deviceProvider = Provider.of<DeviceProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        child:Column(
          children: [
          SizedBox(height: 15,),
          SizedBox (
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Tốc độ: ',
                    style: TextStyle(fontSize: 25),
                    textAlign: TextAlign.center),
                  Text(currentFlowRate,
                    style: TextStyle(fontSize: 25,
                    color: Colors.blue),
                    textAlign: TextAlign.center,
                    ),
                     SizedBox(width: 5,),
                  Text('L/phút',
                  style: TextStyle(
                    fontSize: 25 
                  ),),
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
              maxY: 60,  
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
              lineTouchData: LineTouchData(enabled: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 5,
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
                      'Thời gian',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  )
                ),
                
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5, // Khoảng cách giữa các giá trị Y
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
    ),
    );
  }
}

class RealTimeHistory extends StatefulWidget {
  const RealTimeHistory({super.key});

  @override
  State<RealTimeHistory> createState() => _RealTimeHistoryState();
}

class _RealTimeHistoryState extends State<RealTimeHistory> {

  String selectedType = "";// Mặc định chọn Hôm nay
  DateTime? selectedDate;
  DateTime? startDate;
  DateTime? endDate;
  String totalFlow = "";
   List<Datamodel> dataList = [];
  final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // var historyList = [];

   // Chọn 1 ngày
  Future<void> _selectDate() async {
    DateTime initialDate = selectedDate ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
      // var userProvider = Provider.of<UserProvider>(context, listen: false);
      // fetchHistoryData(userProvider.user.id);

    
  }
  // Chọn khoảng thời gian
  Future<void> _selectDateRange() async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );
    if (pickedRange != null) {
      setState(() {
        startDate = pickedRange.start;
        endDate = pickedRange.end;
      });
    }
  }

 
 // Hàm fetch dữ liệu từ API
  Future<void> fetchHistoryData(String userId) async {
    String apiUrl = "";
    print(selectedDate);
    print(userId);
    if((selectedType == 'today' || selectedType == 'select_day') && selectedDate != null) {
      String date = DateFormat('yyyy-MM-dd').format(selectedDate!);
      apiUrl = "${ApiConstant.baseUrl}/water/api/device/daily/$userId?date=$date";
      print(apiUrl);
    } else if(selectedType != 'today' && startDate != null && endDate != null) {
      String start = DateFormat('yyyy-MM-dd').format(startDate!);
      String end = DateFormat('yyyy-MM-dd').format(endDate!);
      apiUrl = "${ApiConstant.baseUrl}/water/api/device/range/$userId?start=$start&end=$end";
    }
    print(apiUrl);
    if (apiUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(apiUrl));
        if (response.statusCode == 200) {
    
          final jsonData= jsonDecode(response.body);
          print(jsonData);
          final totalData = jsonData['totalAllDays'];

           // final List<dynamic> data = jsonData["data"];
            var listData = jsonData["data"];
          print(listData);
       // 🔹 Chuyển JSON thành danh sách `Datamodel`
        List<Datamodel> tempList = listData.map<Datamodel>((item) => Datamodel.fromJson(item)).toList();

        print("Temolist:  ${tempList}");
          setState(() {
            totalFlow = totalData.toString();
            dataList = tempList;
          });
          
        } 
        
      } catch (error) {
        SnackBar(content: Text('${error}'));
      }
    }
  }

  void updateDateRange(){
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final lastDayOfWeek = firstDayOfWeek.add(Duration(days: 6));
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    print(firstDayOfMonth);
    print(lastDayOfMonth);
    print(firstDayOfWeek);
    print(lastDayOfWeek);
    print(selectedType);
    setState(() {
      switch (selectedType) {
        case "today":
          selectedDate = now;
          startDate = null;
          endDate = null;
          String date = DateFormat('yyyy-MM-dd').format(selectedDate!);
          print(date);
          break;
        case "this_week":
          startDate = firstDayOfWeek;
          endDate = lastDayOfWeek;
          selectedDate = null;
          break;
        case "this_month":
          startDate = firstDayOfMonth;
          endDate = lastDayOfMonth;
          selectedDate = null;
          break;
        case "select_day":
          _selectDate();
          break;
        case "date_range":
          _selectDateRange();
          break;
      }
    });
  }
  List<BarChartGroupData> convertToChartData(List<Datamodel> dataList) {
    // List<BarChartGroupData> barGroups = [];

    // for (int i = 0; i < dataList.length; i++) {
    //   barGroups.add(
    //     BarChartGroupData(
    //       x: i, // Trục Y là ngày (index)
    //       barRods: [
    //         BarChartRodData(
    //           toY: dataList[i].totalFlow, // Trục X là totalFlow
    //           color: const Color.fromARGB(255, 52, 120, 176),
    //           width: 16,
    //           borderRadius: BorderRadius.circular(4),
    //         ),
    //       ],
    //     ),
    //   );
    // }
    // return barGroups;
    return List.generate(dataList.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: dataList[i].totalFlow,
            color: const Color.fromARGB(255, 80, 144, 196),
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: [0], // Display tooltip for each bar
      );
    });
  }


  @override 
  void initState() {
    // TODO: implement initState
    super.initState();
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    selectedType = 'today';
    selectedDate = DateTime.now();
    fetchHistoryData(userProvider.user.id);
  }

  List<String> getXAxisLabels() {
  if (selectedType == 'this_week') {
    // Return labels for each day of the week
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  } else if (selectedType == 'this_month') {
    // Return labels for each month
    return [
      'Tháng này'
    ];
  } else if(selectedType == 'today') {
   // Lấy ngày hiện tại
    DateTime now = DateTime.now();
    // Lấy thứ trong tuần, ví dụ: 'Monday'
    String dayOfWeek = DateFormat('EEEE').format(now);
    return [dayOfWeek];
  }  else {
    return [];
  }
   
}
  
  Widget _bottomTitlesWidget(double value, TitleMeta meta) {
    List<String> xLabels = getXAxisLabels();
    int index = value.toInt();
    if (index >= 0 && index < xLabels.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(xLabels[index], style: TextStyle(fontSize: 16)),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    return Container(
      height: 550,
      child: Column(
         children: [
          const Row(
            children: [
              Text('Real-time data',
              style: TextStyle(
                fontSize: 18,
              ),
              ),
            ],
          ),
          Row(children: [
            DropdownButton<String>(
              value: selectedType,
              items:  const [
                DropdownMenuItem(value: "today", child: Text("Hôm nay")),
                DropdownMenuItem(value: "this_week", child: Text("Tuần này")),
                DropdownMenuItem(value: "this_month", child: Text("Tháng này")),
                DropdownMenuItem(value: "select_day", child: Text("Chọn ngày")),
                DropdownMenuItem(value: "date_range", child: Text("Từ ngày - Đến ngày")),
              ],
             onChanged: (String? newValue) {
              setState(() {
                selectedType = newValue!;
                updateDateRange();
              });
             },
             ),
             const SizedBox(width: 10,),
             Column(
              children: [
                if (selectedType == "today" || selectedType == "select_day")
                  Text("Ngày: ${selectedDate != null ? DateFormat.yMd().format(selectedDate!) : 'Chưa chọn'}"),
                
                if (selectedType == "this_week" || selectedType == "this_month" || selectedType == "date_range")
                  Column(
                    children: [
                      Text("Ngày: ${startDate != null ? DateFormat.yMd().format(startDate!) : 'Chưa chọn'}"),
                      Text("Đến ngày: ${endDate != null ? DateFormat.yMd().format(endDate!) : 'Chưa chọn'}"),
                    ],
                  ),
              ],
            )
           // Hiển thị ngày tùy theo lựa chọn
          ],),
          Row(
            children: [
              TextButton(
                onPressed: () {
                   print(userProvider.user.id);
                   fetchHistoryData(userProvider.user.id);
                   }
                ,child: Text('Xem lịch sử')
                )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Tổng lưu lượng: ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),),
              const SizedBox(width: 10,),
              Text('${totalFlow}',
              style: TextStyle(
                fontSize: 20
              ),),
              SizedBox(width: 4,),
              Text(' m³')
            ],
          ),
          SizedBox(
            height: 20,
          ),
          const Text('Biểu đồ Lịch sử',
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
          SizedBox(height: 10,),
          SizedBox(
            height: 300,
            width: 300,
            child:BarChart(
                  BarChartData(
                    backgroundColor: Colors.lightBlue[50],
                    barGroups: convertToChartData(dataList),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 8.0,
                        tooltipPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Khoảng cách bên trong tooltip
                        getTooltipItem: (
                          BarChartGroupData group,
                          int groupIndex,
                          BarChartRodData rod,
                          int rodIndex,
                        ) {
                          return BarTooltipItem(
                            rod.toY.round().toString(),
                            TextStyle(
                              color: Colors.amber,
                              fontSize: 16.0,
                            ),
                          );
                        },
                      ),
                      enabled: true,
                      ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < dataList.length) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(dataList[index].date, style: TextStyle(fontSize: 10)),
                              );
                            }
                            return Container();
                          },
                          reservedSize: 40, // Giữ không gian để hiển thị ngày tháng
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true, // Hiển thị totalFlow trên trục X
                          reservedSize: 30,
                          // interval: 20, // Chia khoảng
                           getTitlesWidget: _bottomTitlesWidget,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles:  const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)
                      )
                    ),
                    borderData: FlBorderData(show: true),
                    gridData: FlGridData(show: true),
                    alignment: BarChartAlignment.spaceBetween,
                  ),
                ), 
          )
        ],
        
      ),
    );
  }
}
