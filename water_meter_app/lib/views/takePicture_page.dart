// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import '../services/camera_service.dart';
// class BillPaymentPage extends StatefulWidget {
//   const BillPaymentPage({super.key});

//   @override
//   State<BillPaymentPage> createState() => _BillPaymentPageState();
// }

// class _BillPaymentPageState extends State<BillPaymentPage> {
//   late CameraController _cameraController;
//   late Future<void> _initializeControllerFuture;
//   String? _capturedImagePath; // Lưu đường dẫn ảnh đã chụp
  
//   @override
//   void initState() {
    
//     super.initState();
//     _initializeCamera();
//   }

//   Future<void> _initializeCamera() async {
//     WidgetsFlutterBinding.ensureInitialized();
//     await CameraService().initialize(); // Khởi tạo CameraService
//     final camera = CameraService().camera;
//     _cameraController = CameraController(camera, ResolutionPreset.medium);
//     _initializeControllerFuture = _cameraController.initialize();
//     setState(() {}); // Cập nhật trạng thái sau khi camera được khởi tạo
//   }

//   Future<void> _takePicture() async {
//     try {
//       await _initializeControllerFuture; // Đảm bảo camera đã khởi tạo
//       final image = await _cameraController.takePicture();
//       setState(() {
//         _capturedImagePath = image.path; // Lưu đường dẫn ảnh
//       });
//     } catch (e) {
//       print('Error taking picture: $e');
//     }
//   }

//   Future<void> _uploadPicture() async {
//     if (_capturedImagePath != null) {
//       // Gửi ảnh lên server
//       print('Uploading picture: $_capturedImagePath');
//       // Implement logic gửi ảnh lên server
//     } else {
//       print('No picture taken');
//     }
//   }

//   @override
//   void dispose() {
//     _cameraController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Bill Payment'),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           if (_capturedImagePath != null)
//             Image.file(
//               File(_capturedImagePath!), // Hiển thị ảnh đã chụp
//               height: 200,
//               width: 200,
//               fit: BoxFit.cover,
//             )
//           else
//             const Text('No image captured yet.'),
//           const SizedBox(height: 20),
//           ElevatedButton.icon(
//             onPressed: () async {
//               await _takePicture();
//             },
//             icon: const Icon(Icons.camera),
//             label: const Text('Take Picture'),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton.icon(
//             onPressed: _uploadPicture,
//             icon: const Icon(Icons.upload),
//             label: const Text('Upload Picture'),
//           ),
//         ],
//       ),
//     );
//   }
// }
