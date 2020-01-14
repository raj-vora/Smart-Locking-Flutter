import 'package:flutter/material.dart';
import 'package:smart_lock/auth.dart';
import 'package:smart_lock/root_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Locking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RootPage(auth: Auth()),
    );
  }
}