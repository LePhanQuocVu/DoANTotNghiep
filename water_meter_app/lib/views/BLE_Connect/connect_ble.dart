import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../utils/snackbar.dart';

import 'dart:async';
import 'dart:convert'; // For utf8 encoding



class ConnectBle extends StatefulWidget {
  final BluetoothDevice device;
  const ConnectBle({super.key, required this.device});
  @override
  State<ConnectBle> createState() => _ConnectBleState();
}

class _ConnectBleState extends State<ConnectBle> {

  List<int> _value = [];
  String _decodedValue = "";
  
  late StreamSubscription<List<int>> _lastValueSubscription;



    // Text controllers for SSID and Password
  TextEditingController ssidController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _lastValueSubscription = widget.characteristic.lastValueStream.listen((value) {
      // _value = value;
      // _decodedValue = _decodeBytesToString(_value);
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });
  }

  String _decodeBytesToString(List<int> bytes) {
    return String.fromCharCodes(bytes); // Decode byte to string
  }

  List<int> _convertInputToBytes() {
    String ssid = ssidController.text;
    String password = passwordController.text;
    String data = "ssid:$ssid,psw:$password"; // Format: ssid:<value>,psw:<value>
    return utf8.encode(data); // Convert the formatted string into a list of bytes
  }

  Future onWritePressed() async {
    try {
      List<int> bytes = _convertInputToBytes(); // Get bytes from input fields
      // await c.write(bytes, withoutResponse: c.properties.writeWithoutResponse);
      // Snackbar.show(ABC.c, "Gửi thành công", success: true);
      // if (c.properties.read) {
      //   await c.read();
      // }
    } catch (e) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false);
    }
  }

   // Text fields for SSID and Password input
  Widget buildInputFields(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text('Tên'),
            SizedBox(width: 10,),
            TextField(
              controller: ssidController,
              decoration: const InputDecoration(
                labelText: 'Tên wifi',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text('Mật khẩu'),
            SizedBox(width: 10,),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
          ],
        )
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        child: Column(
          children: [
            Row(
              children: [
                Text('Gửi thông tin wifi!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,

                ),)
              ],
            ),
            buildInputFields(context),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                     await onWritePressed();
                      if (mounted) {
                        setState(() {});
                      }
                  }, 
                  child: Text('Gửi thông tin'))
              ],
            )
          ],
        ),
      ),
    );
  }
}