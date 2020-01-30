import 'package:flutter/material.dart';
import 'package:smart_lock/constants/auth.dart';
import 'package:smart_lock/screens/home_page.dart';
import 'package:smart_lock/screens/login_page.dart';
import 'package:smart_lock/screens/register_home.dart';
import 'package:smart_lock/screens/registration_page.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});
  final BaseAuth auth;
  @override
  _RootPageState createState() => _RootPageState();
}

//DISPLAY PAGES BASED ON AUTHSTATUS
enum AuthStatus {
  signedIn,
  notSignedIn,
  register,
  registerHome
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notSignedIn;

  @override
  void initState() {
    super.initState();
    widget.auth.currentUser().then((userId) {
      setState(() {
        authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  //RETURN HERE FROM LOGIN PAGE
  void _signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  //RETURN HERE FROM HOME PAGE ON SIGNING OUT
  void _signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  //GO TO REGISTER PAGE FROM LOGIN FOR NEW USER
  void _register() {
    setState(() {
      authStatus = AuthStatus.register;
    });
  }

  void _registerHome() {
    setState(() {
      authStatus = AuthStatus.registerHome;
    });
  }

  //RENDER RELEVANT PAGE BASED ON AUTHSTATUS
  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return LoginPage(
          auth: widget.auth,
          onSignedIn: _signedIn,
          register: _register,
        );
      case AuthStatus.signedIn:
        return HomePage(
          auth: widget.auth,
          onSignedOut: _signedOut,
          registerHome: _registerHome,
        );
      case AuthStatus.register:
        return Registration(
          auth: widget.auth,
          onSignedIn: _signedIn,
        );
      case AuthStatus.registerHome:
        return RegisterHome(
          auth: widget.auth,
          onSignedIn: _signedIn
        );
    }
  }
}