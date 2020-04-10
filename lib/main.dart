import 'package:flutter/material.dart';
import 'package:smart_lock/constants/auth.dart';
import 'package:smart_lock/screens/enter_otp.dart';
import 'package:smart_lock/screens/home_page.dart';
import 'package:smart_lock/screens/login_page.dart';
import 'package:smart_lock/screens/register_home.dart';
import 'package:smart_lock/screens/register_user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Lock',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: 'login',
      //home: LoginPage(auth: Auth()),
      routes: {
        'login': (context) => LoginPage(auth: Auth()),
        'home': (context) => HomePage(auth: Auth()),
        'registerUser': (context) => RegisterUser(auth: Auth()),
        'registerHome': (context) => RegisterHome(auth: Auth()),
        'enterOtp': (context) => EnterOtp(auth: Auth()),
      },
    );
  }
}