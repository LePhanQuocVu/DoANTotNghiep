import 'package:flutter/material.dart';
import 'package:water_meter_app/views/change_notify_page.dart';
import 'package:water_meter_app/views/change_theme_page.dart';
import 'package:water_meter_app/views/login_page.dart';
import 'package:water_meter_app/views/logout_page.dart';
import 'package:water_meter_app/views/notification_page.dart';
import 'package:water_meter_app/views/profile_page.dart';
import 'package:water_meter_app/views/update_infor.dart';

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
    'Change Theme',
    'Đăng xuất',
  ];

  List<IconData> menuIcons = [
    Icons.person_2_outlined, // Icon cho mục 1
    Icons.notification_add_rounded, // Icon cho mục 2
    Icons.color_lens,
    Icons.logout,
];

  final List<Widget> _pages = [
    ProfilePage(),
    UpdateInforPage(),
    ProfilePage(),
    LoginPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70), // Chỉ định chiều cao cho AppBar
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20), // Bo góc dưới bên trái
            bottomRight: Radius.circular(20), // Bo góc dưới bên phải
          ), 
          child: AppBar(
          title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(
              Icons.settings, // Biểu tượng giọt nước
              color: Color.fromARGB(255, 22, 23, 23),
              size: 50,
            ),
            const SizedBox(width: 10),
            Text(
              'Cài đặt',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
                letterSpacing: 1.2, // Giãn cách chữ
                shadows: [
                  Shadow(
                    offset: Offset(1.0, 2.0), // Đổ bóng
                    blurRadius: 3.0, // Độ mờ của bóng
                    color: Colors.black.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ],
        ),
          flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
              Color.fromARGB(255, 144, 158, 183),
                Colors.lightBlueAccent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            
          ),
        ),
        centerTitle: true,
        elevation: 8, // Đổ bóng dưới AppBar
        toolbarHeight: 70,
        ),
        ),
        ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child:  Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width, // Chiều rộng bằng với màn hình
              height: MediaQuery.of(context).size.height - kToolbarHeight - 20,
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index){
                  return ListTile(
                    leading: Icon(
                      menuIcons[index], // Thay thế bằng icon bạn muốn
                      color: _currentIndex == index
                          ? const Color.fromARGB(255, 28, 28, 29)
                          : Colors.black,
                    ),
                    title: Text(menuItems[index],
                    style: TextStyle(
                      // color: _currentIndex == index ? const Color.fromARGB(255, 28, 28, 29) : Colors.black,
                      color: Colors.black,
                      fontWeight: _currentIndex == index ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => _pages[index]),
                      );
                      });
                    },
                  );
                }
              ),
            ),
          ],
      ),
        )
    );
  }
}