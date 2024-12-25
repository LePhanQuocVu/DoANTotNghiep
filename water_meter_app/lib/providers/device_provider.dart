import 'package:flutter/foundation.dart';
import 'package:water_meter_app/models/devicesModel.dart';
import 'package:intl/intl.dart';  // Import thư viện intl
class DeviceProvider  extends ChangeNotifier{
  Devices _device = Devices(
    id: '', 
    user_id: '', 
    location: '',
    deviceType: '',
    bateryLevel: 100,
    status: false,
    create_at: DateTime.now(),
    );

  Devices get device => _device;

  void setDevice(String device) {
    _device = Devices.fromJson(device);
    notifyListeners();
  }
  String? _deviceName;

  String? get deviceName => _deviceName;

  void setDeviceName(String name) {
    _deviceName = name;
    notifyListeners(); // Thông báo cho các widget lắng nghe trạng thái
  }
  String formatCreateAt() {
     final DateTime dateTime = _device.create_at ?? DateTime.now();  // Cung cấp giá trị mặc định nếu create_at là null
    final DateFormat formatter = DateFormat('HH:mm:ss, yyyy:MM:dd'); // Định dạng "Giờ:phút:giây, Năm:tháng:ngày"
    return formatter.format(dateTime);  // Sử dụng thời gian create_at trong Devices để định dạng
  }
}