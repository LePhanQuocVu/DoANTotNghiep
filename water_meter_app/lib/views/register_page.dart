import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:water_meter_app/services/auth_services.dart';

class RegisterPage extends StatelessWidget {
  
  RegisterPage({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthServices authServices = AuthServices();

  // void registerUser(BuildContext context) {
  //   // authServices.signUpUser(context: context, email: _emailController.text, password: _passwordController.text, name: _nameController.text);
  // }

  bool _obscurePassword = true;

  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 100,),
              Text(
                "Đăng kí",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10,),
              Text(
                "Tạo tài khoản",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 35),
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
                  }else if(value == ""){

                  }
                  return null;
                },
              ),
              const SizedBox(height: 10,),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Địa chỉ emal",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                  if(value == null || value.isEmpty){
                    return "Vui lòng nhập email!";
                  }else if(value == ""){

                  }
                  return null;
                },
              ),
              const SizedBox(height: 10,),
              
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: "Mật khẩu",
                  prefixIcon: const Icon(Icons.password_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: (){
                    
                  },
                ),
                border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                )
                 ),
                  validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập mật khẩu.";
                  } else if (value.length < 8) {
                    return "Mật khẩu chứa ít nhất 8 kí tự.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập lại mật khẩu.";
                  } else if (value != _passwordController.text) {
                    return "Không trùng khớp.";
                  }
                  return null;
                },
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                decoration:  InputDecoration(
                  labelText: "Xác nhận mật khẩu",
                  prefixIcon: const Icon(Icons.password_outlined),
                  suffixIcon: IconButton(
                    onPressed: (){
                    },
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ) 
                    ),
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                   enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                ),
                
             
              ),
              const SizedBox(height: 50),
               Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      if(_formkey.currentState?.validate() ?? false) {
                        authServices.signUpUser(context: context, email: _emailController.text, password: _passwordController.text, name: _nameController.text);
                      }
                    },
                     child: const Text("Đăng kí"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Bạn đã có tài khoản"),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                         child: const Text("Đăng nhập"),
                         )
                    ],
                  )
                ],
               )
            ],
          ),
        )
      ),

    );
  }


  @override 
  void dispose(){
     
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }
}