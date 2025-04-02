// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// // import 'package:http/http.dart' as http;
// import 'dart:io';

// // class BillpaymentPape extends StatefulWidget {
// //   const BillpaymentPape({super.key});

// //   @override
// //   State<BillpaymentPape> createState() => _BillpaymentPapeState();
// // }

// // class _BillpaymentPapeState extends State<BillpaymentPape> {
// //  File? _image; // Lưu trữ ảnh đã chụp
// //  final ImagePicker _picker = ImagePicker();
// //  // Hàm chụp ảnh
// //   Future<void> _captureImage() async {
// //     final pickedFile = await _picker.pickImage(source: ImageSource.camera);

// //     if (pickedFile != null) {
// //       setState(() {
// //         _image = File(pickedFile.path);
// //       });
// //     }
// //   }

// //   // Hàm gửi ảnh lên server
// //   Future<void> _uploadImage() async {
// //     if (_image == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Vui lòng chụp hoặc chọn ảnh trước!")),
// //       );
// //       return;
// //     }

// //     try {
// //       var request = http.MultipartRequest(
// //         'POST',
// //         Uri.parse('https://your-server-url.com/upload'), // URL server
// //       );

// //       request.files.add(await http.MultipartFile.fromPath(
// //         'image', // Tên field phía server
// //         _image!.path,
// //       ));

// //       var response = await request.send();

// //       if (response.statusCode == 200) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text("Gửi ảnh thành công!")),
// //         );
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text("Lỗi khi gửi ảnh!")),
// //         );
// //       }
// //     } catch (e) {
// //       print("Lỗi: $e");
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text("Có lỗi xảy ra!")),
// //       );
// //     }
// //   }

// // @override
// //   Widget build(BuildContext context) {
// //      return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Chụp Ảnh và Gửi Server"),
// //       ),
// //       body: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           _image != null
// //               ? Image.file(
// //                   _image!,
// //                   width: 200,
// //                   height: 200,
// //                   fit: BoxFit.cover,
// //                 )
// //               : const Icon(
// //                   Icons.image,
// //                   size: 100,
// //                   color: Colors.grey,
// //                 ),
// //           const SizedBox(height: 20),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               ElevatedButton.icon(
// //                 onPressed: _captureImage,
// //                 icon: const Icon(Icons.camera_alt),
// //                 label: const Text("Chụp ảnh"),
// //               ),
// //               const SizedBox(width: 20),
// //               ElevatedButton.icon(
// //                 onPressed: _uploadImage,
// //                 icon: const Icon(Icons.upload),
// //                 label: const Text("Gửi ảnh"),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';

// class BillpaymentPape extends StatefulWidget {
//   const BillpaymentPape({super.key});

//   @override
//   State<BillpaymentPape> createState() => _BillpaymentPapeState();
// }

// class _BillpaymentPapeState extends State<BillpaymentPape> {
//    final TextEditingController _meterController = TextEditingController();
//   File? _image; // Lưu trữ ảnh đã chụp
//   // final ImagePicker _picker = ImagePicker();

//    // Hàm chụp ảnh
//   Future<void> _captureImage() async {
//     final picker = ImagePicker();
//    // final pickedFile = await picker.pickImage(source: ImageSource.camera);
//     final pickedFile = null;
//     if (pickedFile != null) {
//       setState(() {
//         _image = File(pickedFile.path);
//       });
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Thanh Toán Hóa Đơn'),
//         centerTitle: true,
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: GestureDetector(
//                 onTap: _captureImage,
//                 child: Container(
//                   width: 200,
//                   height: 200,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(color: Colors.black54),
//                   ),
//                   child: _image != null
//                       ? ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: Image.file(
//                             _image!,
//                             fit: BoxFit.cover,
//                           ),
//                         )
//                       : const Center(
//                           child: Text(
//                             'Nhấn để chụp ảnh',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(color: Colors.black54),
//                           ),
//                       ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _meterController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'Chỉ số đồng hồ',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: (){},
//                 icon: const Icon(Icons.send),
//                 label: const Text('Xác nhận'),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   backgroundColor: Colors.blueAccent,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   }