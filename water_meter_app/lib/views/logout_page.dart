import 'package:flutter/material.dart';

class LogoutPage extends StatefulWidget {
  const LogoutPage({super.key});

  @override
  State<LogoutPage> createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
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