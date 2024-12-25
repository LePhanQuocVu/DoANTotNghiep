import 'package:flutter/material.dart';

class ChangeThemePage extends StatefulWidget {
  const ChangeThemePage({super.key});

  @override
  State<ChangeThemePage> createState() => _ChangeThemePageState();
}

class _ChangeThemePageState extends State<ChangeThemePage> {
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