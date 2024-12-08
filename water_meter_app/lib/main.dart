import 'package:flutter/material.dart';
import 'package:water_meter_app/providers/user_provider.dart';
import 'package:water_meter_app/views/login_page.dart';
import 'package:water_meter_app/views/home_page.dart';
import 'package:provider/provider.dart';
// import './views/home_page.dart';
void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider())
        ],
        child: const MyApp(),
        )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        // '/': (context) => const LoginPage(),
        // '/login': (context) => const LoginPage(),
        '/': (context) => const HomePage()
      },
      /// Đặt HomePage làm màn hình khởi tạo
    );
  }
}