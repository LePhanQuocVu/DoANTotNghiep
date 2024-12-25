import 'package:flutter/material.dart';

class ChangeNotifyPage extends StatefulWidget {
  const ChangeNotifyPage({super.key});

  @override
  State<ChangeNotifyPage> createState() => _ChangeNotifyPageState();
}

class _ChangeNotifyPageState extends State<ChangeNotifyPage> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
    child: Column(
      children: [
        Text("Thông tin cá nhân"),
        // Các widget khác...
      ],
    ),
  );
  }
}