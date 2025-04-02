import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:water_meter_app/views/BLE_Connect/devices_page.dart';
import 'dart:async';
import 'package:water_meter_app/utils/snackbar.dart';
import '../../widgets/system_device_tile.dart';
import '../../widgets/scan_result_tile.dart';
import '../../utils/extra.dart';
class ScanDevicePage extends StatefulWidget {
  const ScanDevicePage({super.key});

  @override
  State<ScanDevicePage> createState() => _ScanDeviceState();
}

class _ScanDeviceState extends State<ScanDevicePage> {
  
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;

  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

 Future onScanPressed() async {
    try {
      // `withServices` is required on iOS for privacy purposes, ignored on android.
      var withServices = [Guid("180f")]; // Battery Level Service
      _systemDevices = await FlutterBluePlus.systemDevices(withServices);
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("System Devices Error:", e), success: false);
      print(e);
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
     // await FlutterBluePlus.startScan();
    } catch (e) {
       Snackbar.show(ABC.b, prettyException("Start Scan Error:", e), success: false);
       print("Ban gap loi : ${e}");
    }
    if (mounted) {
      setState(() {});
    }
  }


   Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e), success: false);
    }
  }

   void onConnectPressed(BluetoothDevice device) {
    device.connectAndUpdateStream().catchError((e) {
      Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false);
    });
    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => DevicesPage(device: device), settings: RouteSettings(name: '/DeviceScreen'));
    Navigator.of(context).push(route);
  }

    
  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(Duration(milliseconds: 500));
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return Container(
        width: 100,
        height: 50,
        child: FloatingActionButton(
        onPressed: onStopPressed,
        backgroundColor: Colors.red,
        child: const Icon(Icons.stop),
        )
      );
      
    } else {
      return Container(
        width: 120,
        height: 50,
        child: FloatingActionButton(
          onPressed: onScanPressed,
          backgroundColor: const Color.fromARGB(255, 1, 1, 1),
          child: const Text("Quét thiết bị",
          style: TextStyle(
          fontSize: 20,
          color: Colors.white,
          ),
        ),
        ),
      );
       //FloatingActionButton(child: const Text("Quét"), onPressed: onScanPressed);
    }
  }

  List<Widget> _buildSystemDeviceTiles(BuildContext context) {
    return _systemDevices
        .map(
          (d) => SystemDeviceTile(
            device: d,
            onOpen: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DevicesPage(device: d),
                settings: RouteSettings(name: '/DeviceScreen'),
              ),
            ),
            onConnect: () => onConnectPressed(d),
          ),
        )
        .toList();
  }

  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () => onConnectPressed(r.device),
          ),
        )
        .toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyB,
      child: Scaffold(
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
                Icons.bluetooth, // Biểu tượng giọt nước
                color: Color.fromARGB(255, 22, 23, 23),
                size: 50,
              ),
              const SizedBox(width: 10),
              Text(
                'Kết nối ESP32',
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
          // Nút quét ở vị trí gần appBar
           Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text("Nhấn nút để quét thiết bị",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 10,),
                buildScanButton(context),
              ],
            ),
          ),
           Expanded(
            child:  RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                children: <Widget>[
                  ..._buildSystemDeviceTiles(context),
                  ..._buildScanResultTiles(context),
                ],
              ),
            )
          )
        ],
      ),
      //   body: RefreshIndicator(
      //     onRefresh: onRefresh,
      //     child: ListView(
      //       children: <Widget>[
      //         ..._buildSystemDeviceTiles(context),
      //         ..._buildScanResultTiles(context),
      //       ],
      //     ),
      //   ),
      //   floatingActionButton: buildScanButton(context),
       ),
    );
  }
}