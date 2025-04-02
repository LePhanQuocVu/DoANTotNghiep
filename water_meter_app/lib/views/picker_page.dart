import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:water_meter_app/services/api_constant.dart';
class PickerPage extends StatefulWidget {
  const PickerPage({super.key});

  @override
  State<PickerPage> createState() => _PickerPageState();
}

class _PickerPageState extends State<PickerPage> {
  File? _capturedImage; // Lưu ảnh đã chụp
  final ImagePicker _picker = ImagePicker();
  String? _result;

  bool _isUploading = false; // To show a loading indicator during upload
  


  Future<void> _takePicture() async {
    try {
      // Mở camera và chụp ảnh
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 600, // Tùy chọn: giảm kích thước ảnh để tối ưu hiệu năng
      );

      if (photo != null) {
        setState(() {
          _capturedImage = File(photo.path); // Lưu đường dẫn ảnh
          _result = null;  // Clear previous results
          print('File path:' + _capturedImage!.path);
        });
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _sendPicture() async {
    if(_capturedImage == null) {
      setState(() {
        _result = "Please select Image";
      });
      return;
    }
    try {
      setState(() {
        _isUploading = true;
        _result = null; // Clear previous results
      });
      
      var uri = Uri.parse('http://192.168.43.171:5000/predict');
      var request = http.MultipartRequest('POST', uri);
        
        request.files.add(
          await http.MultipartFile.fromPath('file', _capturedImage!.path)
        );

        print('My request: ' + request.toString());
           // Gửi request và nhận response
      // var response = await request.send();
      // var response = await http.Response.fromStream(await request.send());
      var response = await request.send();

      var responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        // var responseBody = await response.stream.bytesToString();
        print("Image uploaded successfully");
        print("Response Body: ${responseData}");
         var jsonResponse = jsonDecode(responseData);
        setState(() {
           _result = jsonResponse["message"]; // Hiển thị thông báo nhận được
        });
      } else {
        setState(() {
          _result = "Failed to predict. Server responded with status code ${response.statusCode}.";
        });
      }
    } catch (e) {
      print("Error sending Picture: $e");
      if (e is http.ClientException) {
        print("ClientException: ${e.message}");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Payment'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_capturedImage != null)
            Image.file(
              _capturedImage!,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            )
          else
            const Text('No image captured yet.'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _takePicture,
            icon: const Icon(Icons.camera),
            label: const Text('Take Picture'),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _sendPicture,
            icon: const Icon(Icons.upload),
            label: const Text('Upload Picture'),
          ),
           SizedBox(height: 20),
            if (_isUploading) const CircularProgressIndicator(),
            if (_result != null) Text(_result!),
        ],
      ),
    );
  }
}