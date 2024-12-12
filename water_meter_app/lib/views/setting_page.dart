import 'package:flutter/material.dart';
import 'package:water_meter_app/views/notification_page.dart';
import 'package:water_meter_app/views/profile_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int _currentIndex = 0;

  final List<String> menuItems = [
    'Thông tin người dùng',
    'Cảnh báo',
    'Đăng xuất',
  ];


  final List<Widget> _pages = [
    ProfilePage(),
    NotificationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cài đặt",),
      ),
      body: Row(
          children: [
            Container(
              width: 200,
              color: Colors.blueGrey,
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index){
                  return ListTile(
                    title: Text(menuItems[index],
                    style: TextStyle(
                      color: _currentIndex == index ? Colors.blue : Colors.black,
                      fontWeight: _currentIndex == index ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  );
                }
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              )
              
            )
          ],
        // Container(
        //   width: 200,
        //   color: Colors.blueGrey,
        //   child: ListView.builder(
        //     itemBuilder: 
        //   ),
        // ),
      )
    );
  }
}