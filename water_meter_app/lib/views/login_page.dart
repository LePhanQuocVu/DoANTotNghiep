import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:water_meter_app/services/auth_services.dart';
import './register_page.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
 
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthServices authServices = AuthServices();
  bool _obscurePassword = true;

  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
          padding:  const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 150,),
               Text(
                "SMART METTER APP",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),
              Text(
                "Đăng nhập vào tài khoản",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 60),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Vui lòng nhập email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Vui lòng điền tên";
                } else if (value == "") {
                  return "";
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
                  labelText: "Nhập mật khẩu?",
                  prefixIcon: const Icon(Icons.password_outlined),
                  suffixIcon: IconButton(
                  onPressed: (){
                     setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                     _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  )),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ), 
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập mật khẩu";
                  } else if (value == "" ) {
                    return "Sai mật khẩu";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 60),
              Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: (){
                      if(_formkey.currentState!.validate()) {
                         authServices.signInUser(context: context, email: _emailController.text, password: _passwordController.text);
                      }
                    } ,
                  child: const Text("Đăng nhập"),
                  ),
                  Row (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Chưa có tài khoản?"),
                      TextButton (
                        onPressed: (){  
                          // Register
                          Navigator.push(context,
                           MaterialPageRoute
                           (builder: (context) {
                            return RegisterPage();
                           },
                          ),
                          );
                        },
                        child: const Text("Đăng kí"),
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
  // @override 
  // void dispose(){
  //   _emailController.dispose();
  //   _passwordController.dispose();
  // }
}