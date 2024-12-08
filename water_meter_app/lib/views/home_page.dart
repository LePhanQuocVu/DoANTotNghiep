// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:water_meter_app/services/auth_services.dart';
import 'package:water_meter_app/views/home.dart';
import 'package:water_meter_app/views/notification_page.dart';
import 'package:water_meter_app/views/profile_page.dart';
import 'package:water_meter_app/views/setting_page.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // danh sách papge
  final List<Widget> _pages = [
    const HomeContentPage(),
    const NotificationPage(),
    const SettingPage()
  ];


  // tiêu đề
  // final List<String> _titles = [
  //   "Trang chủ",
  //   "Thông báo",
  //   "Cài đặt"
  // ];

  final AuthServices authServices = AuthServices();

  @override 
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //    title:  Text(_titles[currentIndex]),
      //   actions: [
      //     Padding(
      //        padding: const EdgeInsets.all(10.0),
      //       child: PopupMenuButton<String>(
      //         onSelected: (value) {
      //             if(value == 'profile') {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(builder: (context) => const ProfilePage()));

      //             }else if(value == 'logout') {
      //               authServices.signOut(context);
      //             }
      //         },
      //         itemBuilder: (BuildContext context) => [
      //           PopupMenuItem(
      //             value: 'profile',
      //             child: Text('Xem profile'),
      //           ),
      //           PopupMenuItem(
      //             value: 'logout',
      //             child: Text('Đăng xuất'),
      //           ),
      //         ],
      //         child: CircleAvatar(
      //           radius: 20,
      //           backgroundImage: AssetImage('assets/images/profile.jpg'
      //           ),
      //           child: Icon(Icons.person),
      //         ),
      //       ),
      //     )
      //   ],
      // ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
       
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // onTabTapped(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Trang chủ"
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Thông báo"
            ),
           BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Cài đặt"
            ),
        ],
      ),
    );
  }
}