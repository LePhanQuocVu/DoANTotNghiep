import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'package:water_meter_app/providers/user_provider.dart';
import 'package:water_meter_app/services/user_services.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  bool _isEditing = false; // Điều khiển việc hiển thị animation để chỉnh sửa thông tin

  // Test display infor

  // String name = "Nguyễn Văn A";
  // String email = "nguyen@example.com";
  // String phone = "0123456789";
  // String address = "Hà Nội, Việt Nam";

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  
  final _formkey = GlobalKey<FormState>();
  
  final UserServices userService = UserServices();

   
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
     _nameController = TextEditingController(text: userProvider.user.name ?? " ");
     _emailController = TextEditingController(text: userProvider.user.email ?? " ");
     _phoneController = TextEditingController(text: userProvider.user.phone ?? " ");
     _addressController = TextEditingController(text: userProvider.user.address ?? " ");
  }
  @override 
  void dispose(){
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Widget _UpdateInfor({
     required String name,
    required String email,
     String? phone,
     String? address,
    required bool isUpdated,
  }) {

     return AnimatedPositioned(
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
      bottom: isUpdated ? 0 : - MediaQuery.of(context).size.height * 0.7, // Ẩn dưới màn hình khi không chỉnh sửa và kéo lên khi chỉnh sửa
      left: 0,
      right: 0,
      child: SingleChildScrollView(
        child:  AnimatedOpacity(
        opacity: isUpdated ? 1 : 0, // Thay đổi độ mờ để ẩn/hiện
        duration: Duration(seconds: 1),
        child: AnimatedContainer(
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(16),
          width: isUpdated ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 0.1,
          height: isUpdated ? MediaQuery.of(context).size.height * 0.7 : 0, // Thay đổi độ cao để chiếm 3/4 màn hình
          decoration: BoxDecoration(
            color: isUpdated ? const Color.fromARGB(255, 194, 196, 194) : Colors.blueAccent, // Animation thay đổi màu sắc
            borderRadius: BorderRadius.circular(12),
          ),
          child: Form(
            //padding: const EdgeInsets.only(left: 60),
            key: _formkey,
            child: SingleChildScrollView(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  children:  [
                    Text('Cập nhật thông tin',
                    style: TextStyle(
                      fontSize: 30,
                    ),)
                  ],
                ),
                SizedBox(height: 20,),
                TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: "Tên người dùng",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if(value == null || value.isEmpty){
                    return "Vui lòng nhập tên!";
                  }else {
                    return null;
                  }
                },
              ),
              SizedBox(height: 10,),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if(value == null || value.isEmpty){
                    return "Vui lòng địa chỉ email";
                  }else {
                    return null;
                  }
                },
              ),
              SizedBox(height: 20,),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Số điện thoại",
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
                SizedBox(height: 20,),
              TextFormField(
                controller: _addressController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Địa chỉ",
                  prefixIcon: const Icon(Icons.location_city),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                        // UPDATE INFORMATION here
                      if(_formkey.currentState?.validate() ?? false) {
                        //userService.updateUser(context: context, email: _emailController.text, name: _nameController.text, phone: _phoneController.text, address: _addressController.text);
                      }
                      });
                    },
                    child: const Text("Lưu",
                    style: TextStyle(
                      fontSize: 18,
                    ),),
                ),
                  ],
                ),
              ],
            ),
            )
          ), 
        ),
      ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {

    final _userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar:  PreferredSize(
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
            Text(
              'Thông tin người dùng ',
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
               children: [
            // Avatar và phần Edit
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:  AssetImage("assets/images/profile.jpg"),
                    ),
                    Positioned(
                      top: 80,
                      left: -8,
                      child: GestureDetector(
                        onTap: () {
                          // Logic để thay đổi ảnh đại diện
                          print("Chỉnh sửa ảnh đại diện");
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                Container(
                  width: 300,
                  height: 200,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.black,
                          ),
                          SizedBox(width: 20,),
                          Text('${_userProvider.user.name}'),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.mail,
                            color: Colors.black,
                          ),
                          SizedBox(width: 20,),
                          Text('${_userProvider.user.email}'),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone,
                            color: Colors.black,
                          ),
                          SizedBox(width: 20,),
                          
                          // Text('${_userProvider.user.ho}')
                          Text('${_userProvider.user.phone ?? "Chưa cập nhật"}'),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_city,
                            color: Colors.black,
                          ),
                          SizedBox(width: 20,),
                           Text('${_userProvider.user.address ?? "Chưa cập nhật"}'),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Nút cập nhật thông tin
                SizedBox(
                  child:   ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                  child: Text(_isEditing ? "Hủy chỉnh sửa" : "Cập nhật thông tin",
                  style: TextStyle(
                    fontSize: 18,
                    ),
                  ),
                ), 
                )
              
                ],
              ),
          ),
          if (_isEditing)
          GestureDetector(
            onTap: () {
              setState(() {
                _isEditing = false; // Ẩn form khi nhấn vào phần làm mờ
              });
            },
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),// Hiệu ứng làm mờ
              child: Container(
                color: Colors.black.withOpacity(0.1), // Lớp mờ tối
              ),
            ),
          ),
          
          _UpdateInfor(
            name: _userProvider.user.name,
            email: _userProvider.user.email,
            phone: _userProvider.user.phone,
            address: _userProvider.user.address,
            isUpdated: _isEditing),
        ],
      ),
    );
  }
 
}
