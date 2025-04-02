import 'package:camera/camera.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  late CameraDescription _camera;

  factory CameraService() => _instance;

  CameraService._internal();

  Future<void> initialize() async {
    final cameras = await availableCameras();
    _camera = cameras.first; // Chọn camera đầu tiên
  }

  CameraDescription get camera => _camera;
}