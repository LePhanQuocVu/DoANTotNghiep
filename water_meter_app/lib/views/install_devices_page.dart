import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_meter_app/providers/device_provider.dart';
import 'package:water_meter_app/providers/user_provider.dart';
import 'package:water_meter_app/services/api_constant.dart';
import 'package:water_meter_app/services/devices_services.dart';
import 'package:location/location.dart';
import 'package:water_meter_app/views/BLE_Connect/select_mode_page.dart';
import 'package:water_meter_app/widgets/utils.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
class InstallDevicesPage extends StatefulWidget {
  const InstallDevicesPage({super.key});
  
  @override
  State<InstallDevicesPage> createState() => _InstallDevicesPagetate();
}

class _InstallDevicesPagetate extends State<InstallDevicesPage> {

  
   String? deviceName;
   String? type;
  //  String? location;
  String? selectedDeviceType;
  // String? deviceType;
  bool isSetup = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _accessTokenController = TextEditingController();
  late TextEditingController _locationControler = TextEditingController();
  late TextEditingController _longitudeController = TextEditingController();
  late TextEditingController _latitudeController = TextEditingController();

  late TextEditingController _specificLocationController = TextEditingController();

  late UserProvider userProvider;

  int _selectedWatchType = -1;

  late DeviceProvider deviceProvider;
  Future<void> fetchDeviceByUserId(String userId) async {
    try {
      String apiUrl = "${ApiConstant.baseUrl}/water/api/getDeviceByUserId/${userId}";
      print(apiUrl);
      final response = await http.get(Uri.parse(apiUrl));
      if(response.statusCode == 200) {
        print("Thông tin đồng hồ: ${response.body}");
        setState(() {
          isSetup = true;
          deviceProvider.setDeviceName("Created");
          // deviceProvider.setDevice(response.body.toString());
          // deviceProvider.setDeviceName("${deviceProvider.device.deviceType}");
          // print("Tên của thiết bị là: ${deviceProvider.deviceName}");
          // deviceProvider.setDevice(response.body);
        });
      } else {
        print("Chưa có thiết bị được cài đặt");
        setState(() {
          deviceProvider.setDeviceName("");
        });
      }
    }
    catch(e) {
      print("Error: ${e}");
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     final userProvider = Provider.of<UserProvider>(context, listen: false);
     _nameController = TextEditingController(text: userProvider.user.name);
     _emailController = TextEditingController(text: userProvider.user.email);
     fetchDeviceByUserId(userProvider.user.id);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _specificLocationController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    deviceProvider = Provider.of<DeviceProvider>(context);
    userProvider = Provider.of<UserProvider>(context);
    final DevicesServices devicesServices = DevicesServices();
    final formKey = GlobalKey<FormState>();


    Future<void> _getCurrentLocation() async {
      Location locationService = new Location();
      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData _locationData;

      _serviceEnabled = await locationService.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await locationService.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

    _permissionGranted = await locationService.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await locationService.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await locationService.getLocation();
    setState(() {
       _longitudeController.text = _locationData.longitude?.toString() ?? '';
      _latitudeController.text = _locationData.latitude?.toString() ?? '';
      _specificLocationController.text = "Lat: ${_locationData.latitude}, Long: ${_locationData.longitude}";
      print(_longitudeController.text);
      print(_latitudeController.text);
    });
  }

   
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin thiết bị'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if((!isSetup)) ...{
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     const Text(
                    'Chưa có thiết bị nào được cài đặt.',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  ],
                ),
              ),
             
              ElevatedButton(
              onPressed: () {
               showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  // Tạo một biến state cục bộ cho modal
                  int modalSelectedWatchType = _selectedWatchType;
                  return FractionallySizedBox(
                    heightFactor: 0.9,
                    widthFactor: 0.9,
                    child: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Cài đặt thiết bị')
                              ],
                            ),
                            SizedBox(height: 20,),
                             TextFormField(
                              readOnly: true,
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: "Tên người dùng",
                                prefixIcon: const Icon(Icons.person_outline),
                                filled: true, // Bật màu nền
                                fillColor: Colors.grey[300], // Màu nền mờ
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                           
                            ),
                            SizedBox(height: 20,),
                            TextFormField(
                              readOnly: true,
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: "Email",
                                prefixIcon: const Icon(Icons.phone_android_rounded),
                                filled: true, // Bật màu nền
                                fillColor: Colors.grey[300], // Màu nền mờ
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                              SizedBox(height: 20,),
                            TextFormField(
                              enableInteractiveSelection: true,
                              controller: _accessTokenController,
                              decoration: InputDecoration(
                                labelText: "Access Token",
                                prefixIcon: const Icon(Icons.location_city_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (String? value){
                                if(value == null || value.isEmpty){
                                  return "Access token CoreIOT";
                                }
                                return null;
                              }
                            ),
                            SizedBox(height: 20,),
                            TextFormField(
                              controller: _locationControler,
                              decoration: InputDecoration(
                                labelText: "Địa chỉ",
                                prefixIcon: const Icon(Icons.location_city_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (String? value){
                                if(value == null || value.isEmpty){
                                  return "Vui lòng nhập địa chỉ";
                                }
                                return null;
                              }
                            ),
                          
                            const SizedBox(height: 20,),
                            TextFormField(
                              controller: _specificLocationController,
                              decoration: InputDecoration(
                                labelText: "Vị trí",
                                prefixIcon: const Icon(Icons.location_searching_sharp),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _getCurrentLocation,
                              child: const Text('Lấy vị trí hiện tại'),
                            ),
                            SizedBox(height: 10,),
                            const Row(
                               children: [
                                Text('Chọn thiết bị',
                                style: TextStyle(
                                  fontSize: 16,
                                ),),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // First watch type
                                WatchTypeSelector(
                                  index: 0,
                                  isSelected: _selectedWatchType == 1,
                                  imagePath: 'assets/images/dhc.jpg',
                                  label: 'Đồng hồ loại 1',
                                  onTap: () {
                                    setState(() {
                                      print('Chọn device 1');
                                      type = "1";
                                      _selectedWatchType = 1;
                                      // Tạo một biến state cục bộ cho modal
                                      int modalSelectedWatchType = _selectedWatchType;
                                    });
                                  },
                                ),
                                
                                // Second watch type
                                WatchTypeSelector(
                                  index: 1,
                                  isSelected: _selectedWatchType == 2,
                                  imagePath: 'assets/images/dhc.jpg',
                                  label: 'Đồng hồ loại 2',
                                  onTap: () {
                                    setState(() {
                                       print('Chọn device 2');
                                       type = "2";
                                      _selectedWatchType = 2;
                                      modalSelectedWatchType = _selectedWatchType;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                child: const Text('Lưu'),
                                onPressed: () async {
                                  //CREATE DEVICE
                                  if(formKey.currentState?.validate() ?? false) {
                                    await devicesServices.createDevice(context: context, user_id: userProvider.user.id, location: _locationControler.text, type: type.toString(), longitude: _longitudeController.text, latitude: _latitudeController.text, iotToken: _accessTokenController.text); 
                                      if(mounted) {
                                        setState(() {
                                          isSetup = true;
                                        }); // Cập nhật lại UI để load thiết bị mới
                                        Navigator.pop(context);
                                      }
                                    //  try{
                                    //   await  devicesServices.createDevice(context: context, user_id: userProvider.user.id, location: _locationControler.text, type: type.toString(), longitude: _longitudeController.text, latitude: _latitudeController.text); 
                                    //   if(mounted) {
                                    //     Navigator.pop(context);
                                    //   }
                                    //  } 
                                    //  catch (e) {
                                    //     SnackBar(content: Text('${e}'),
                                    //     );
                                    //  }
                                  } 
                                },
                              ),
                            ],
                          ),
                          ],
                        ),
                      ),
                    )
                  );
                }
               );
              },
              child: const Text('Cài đặt',
              style: TextStyle(
                color: Colors.white,
              ),),
             style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 83, 82, 84),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                textStyle: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold)),
            ),
            } else ...{
              
              DeviceInfor(),
            },
             const SizedBox(height: 30),
            // Nút "Cài đặt" thiết bị
          ],
        ),
      ),
    ); 
  }
}


class DeviceInfor extends StatefulWidget {
  const DeviceInfor({super.key});

  @override
  State<DeviceInfor> createState() => _DeviceInforState();
}

class _DeviceInforState extends State<DeviceInfor> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  final DevicesServices device = DevicesServices();
  
  String? selectedDeviceType;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: userProvider.user.name);
     _emailController = TextEditingController(text: userProvider.user.email);
     _addressController = TextEditingController(text: userProvider.user.address);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final deviceProvider = Provider.of<DeviceProvider>(context);
    String? deviceName;
    String? type;
     //  String? location;
    String? selectedDeviceType;
    
    int _selectedWatchType = -1;

    final formKey = GlobalKey<FormState>();
    setState(() {
      //  device.getDeviceByUserId(userProvider.user.id);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
     _nameController = TextEditingController(text: userProvider.user.name);
     _emailController = TextEditingController(text: userProvider.user.email);
     _addressController = TextEditingController(text: deviceProvider.device.location);
    });

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        child: Column(
          children: [
            // Avatar và phần Edit
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundImage:  AssetImage("assets/images/profile.jpg"),
                    ),
                    Positioned(
                      top: 80,
                      left: -8,
                      child: GestureDetector(
                        onTap: () {
                          // Logic để thay đổi ảnh đại diện
                          print("Chỉnh sửa ảnh đại diện");
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ID thiết bị",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Roboto",
                ),),
                const SizedBox(height: 5,),
                Container(
                  padding: const EdgeInsets.all(5.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 224, 221, 221), // Màu nền
                  borderRadius: BorderRadius.circular(10), // Bo tròn 4 góc
                  ), // Màu nền
                  child: const Text(
                    '111',
                    style: TextStyle(
                      fontSize: 20, // Cỡ chữ
                      fontFamily: 'Roboto', // Font chữ
                      color: Colors.black, // Màu chữ
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15,),
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Dung lượng pin",
              style: TextStyle(
                fontSize: 16,
                fontFamily: "Roboto",
              ),),
              Container(
                padding: const EdgeInsets.all(10.0),
                width: double.infinity,
                decoration: BoxDecoration(
                color: const Color.fromARGB(255, 224, 221, 221), // Màu nền
                borderRadius: BorderRadius.circular(10), // Bo tròn 4 góc
                ), // Màu nền
                child: const Text(
                  '100%',
                  style: TextStyle(
                    fontSize: 20, // Cỡ chữ
                    fontFamily: 'Roboto', // Font chữ
                    color: Colors.black, // Màu chữ
                  ),
                ),
              ),
            ],
            ),
            SizedBox(height: 5,),
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Loại thiết bị",
              style: TextStyle(
                fontSize: 16,
                fontFamily: "Roboto",
              ),),
              SizedBox(height: 5,),
              Container(
                padding: const EdgeInsets.all(10.0),
                width: double.infinity,
                decoration: BoxDecoration(
                color: const Color.fromARGB(255, 224, 221, 221), // Màu nền
                borderRadius: BorderRadius.circular(10), // Bo tròn 4 góc
                ), // Màu nền
                child: const Text(
                  'Đồng hồ cơ',
                  style: TextStyle(
                    fontSize: 20, // Cỡ chữ
                    fontFamily: 'Roboto', // Font chữ
                    color: Colors.black, // Màu chữ
                  ),
                ),
              ),
            ],
            ),
            SizedBox(height: 5,),
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Địa chỉ",
              style: TextStyle(
                fontSize: 16,
                fontFamily: "Roboto",
              ),),
              SizedBox(height: 5,),
              Container(
                padding: const EdgeInsets.all(10.0),
                width: double.infinity,
                decoration: BoxDecoration(
                color: const Color.fromARGB(255, 224, 221, 221), // Màu nền
                borderRadius: BorderRadius.circular(10), // Bo tròn 4 góc
                ), // Màu nền
                child: Text(
                  '${deviceProvider.device.location}',
                  style: TextStyle(
                    fontSize: 20, // Cỡ chữ
                    fontFamily: 'Roboto', // Font chữ
                    color: Colors.black, // Màu chữ
                  ),
                ),
              ),
          ],
        ),
            SizedBox(height: 5,),
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Thời gian",
              style: TextStyle(
                fontSize: 16,
                fontFamily: "Roboto",
              ),),
              SizedBox(height: 5,),
              Container(
                padding: const EdgeInsets.all(10.0),
                width: double.infinity,
                decoration: BoxDecoration(
                color: const Color.fromARGB(255, 224, 221, 221), // Màu nền
                borderRadius: BorderRadius.circular(10), // Bo tròn 4 góc
                ),
                child: Text(
                  '${deviceProvider.formatCreateAt()}',
                  style: TextStyle(
                    fontSize: 20, // Cỡ chữ
                    fontFamily: 'Roboto', // Font chữ
                    color: Colors.black, // Màu chữ
                  ),
                ),
              ),
            ],
            ),
            SizedBox(height: 10,),
            Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             ElevatedButton(
              onPressed: () {
               showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  int modalSelectedWatchType = _selectedWatchType;
                    return FractionallySizedBox(
                    heightFactor: 0.8,
                    widthFactor: 0.9,
                    child: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          children: [
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Cập nhật thiết bị',
                                style: TextStyle(
                                  fontSize: 20,
                                ),)
                              ],
                            ),
                            SizedBox(height: 20,),
                             TextFormField(
                              readOnly: true,
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: "Tên người dùng",
                                prefixIcon: const Icon(Icons.person_outline),
                                filled: true, // Bật màu nền
                                fillColor: Colors.grey[300], // Màu nền mờ
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                           
                            ),
                            SizedBox(height: 20,),
                            TextFormField(
                              readOnly: true,
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: "Email",
                                prefixIcon: const Icon(Icons.phone_android_rounded),
                                filled: true, // Bật màu nền
                                fillColor: Colors.grey[300], // Màu nền mờ
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            SizedBox(height: 20,),
                             SizedBox(height: 20,),
                            TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                labelText: "Địa chỉ",
                                prefixIcon: const Icon(Icons.location_city_rounded),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              validator: (String? value){
                                if(value == null || value.isEmpty){
                                  return "Vui lòng nhập địa chỉ";
                                }
                              }
                            ),
                            SizedBox(height: 20,),
                            const Row(
                               children: [
                                Text('Chọn thiết bị'),
                              ],
                            ),
                            Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // First watch type
                              WatchTypeSelector(
                                index: 0,
                                isSelected: _selectedWatchType == 1,
                                imagePath: 'assets/images/dhc.jpg',
                                label: 'Đồng hồ loại 1',
                                onTap: () {
                                  setState(() {
                                     selectedDeviceType = "1";
                                     type = "1";
                                    _selectedWatchType = 1;
                                    modalSelectedWatchType = _selectedWatchType;
                                  });
                                },
                              ),
                              
                              // Second watch type
                              WatchTypeSelector(
                                index: 1,
                                isSelected: _selectedWatchType == 2,
                                imagePath: 'assets/images/dhc.jpg',
                                label: 'Đồng hồ loại 2',
                                onTap: () {
                                  setState(() {
                                    selectedDeviceType = "2";
                                    type = "2";
                                    _selectedWatchType = 2;
                                    modalSelectedWatchType = _selectedWatchType;
                                  });
                                },
                              ),
                            ],
                          ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                child: const Text('Lưu'),
                                // onPressed: () => Navigator.pop(context),
                                onPressed: () {
                                  //UPDATE
                                  if(formKey.currentState?.validate() ?? false) {
                                    //update
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                              ],
                            ),
                          ]
                        )
                      )
                    ),
                  );                
                    }
               )
               ;
              },
            child: const Text('Cập nhật',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black
            ),), 
            )
          ],
        )
          ],
        ),
      ),
    );
  }
}



class WatchTypeSelector extends StatefulWidget {
  final int index;
  final bool isSelected;
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  const WatchTypeSelector({
    Key? key,
    required this.index,
    required this.isSelected,
    required this.imagePath,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  State<WatchTypeSelector> createState() => _WatchTypeSelectorState();
}

class _WatchTypeSelectorState extends State<WatchTypeSelector> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WatchTypeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kích thước cơ bản của container
    final double baseSize = 120;
    
    return GestureDetector(
      onTap: () {
        // Thêm hiệu ứng phản hồi khi chạm
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isSelected ? _scaleAnimation.value : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: widget.isSelected ? baseSize * 1.1 : baseSize,
                  height: widget.isSelected ? baseSize * 1.1 : baseSize,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget.isSelected ? Colors.blue : Colors.grey,
                      width: widget.isSelected ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: widget.isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            widget.imagePath,
                            fit: BoxFit.cover,
                            // Nếu không có hình ảnh thực tế, bạn có thể sử dụng placeholder
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: Text(
                                    'Đồng hồ ${widget.index + 1}',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (widget.isSelected)
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: widget.isSelected ? 16 : 14,
              fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
              color: widget.isSelected ? Colors.blue : Colors.black,
            ),
            child: Text(widget.label),
          ),
        ],
      ),
    );
  }
}
