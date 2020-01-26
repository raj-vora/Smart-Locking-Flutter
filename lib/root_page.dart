import 'package:flutter/material.dart';
import 'package:smart_lock/constants/auth.dart';
import 'package:smart_lock/screens/home_page.dart';
import 'package:smart_lock/screens/login_page.dart';
import 'package:smart_lock/screens/registration.dart';
import 'package:local_auth/local_auth.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});
  final BaseAuth auth;
  @override
  _RootPageState createState() => _RootPageState();
}

enum AuthStatus {
  signedIn,
  notSignedIn,
  register
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notSignedIn;
  final LocalAuthentication localAuth = LocalAuthentication();
  bool authenticated = false;

  @override
  void initState() {
    super.initState();
    widget.auth.currentUser().then((userId) {
      setState(() {
        authStatus = userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  void _signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  void _signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  void _register() {
    setState(() {
      authStatus = AuthStatus.register;
    });
  }

  /*void authUser() async {
    List<BiometricType> availableBiometrics =
    await localAuth.getAvailableBiometrics();

    if (Platform.isIOS) {
      if (availableBiometrics.contains(BiometricType.face)) {
          authenticated = await localAuth.authenticateWithBiometrics(
            localizedReason: 'FaceID',
            useErrorDialogs: true,
            stickyAuth: true
          );
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          authenticated = await localAuth.authenticateWithBiometrics(
            localizedReason: 'TouchID',
            useErrorDialogs: true,
            stickyAuth: true
          );
      }
    }else{
      authenticated = await localAuth.authenticateWithBiometrics(
        localizedReason: 'Fingerprint or pin to access the application',
        useErrorDialogs: true,
        stickyAuth: true
      );
    }
  }*/

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
        //if(authenticated) {
          return HomePage(
            auth: widget.auth,
            onSignedOut: _signedOut,
          );
        /*}else{
          return LoginPage(
          auth: widget.auth,
          onSignedIn: _signedIn,
          register: _register,
        );
        }
        break;*/
      case AuthStatus.register:
        return Registration(
          auth: widget.auth,
          onSignedIn: _signedIn,
        );
    }
  }
}