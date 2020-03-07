import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_lock/constants/auth.dart';
import 'package:smart_lock/constants/ui_constants.dart';

class RegisterHome extends StatefulWidget {
  RegisterHome({this.auth});
  final BaseAuth auth;
  @override
  _RegisterHomeState createState() => _RegisterHomeState();
}

class _RegisterHomeState extends State<RegisterHome> {
  final formKey = GlobalKey<FormState>();
  String _name, _userId,_userSecret, _homeId, _homeName;
  Map<String, String> json;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    widget.auth.requestPermissions();
    widget.auth.initChirp();
  }

  Future<void> initPlatformState() async {
    List id = await widget.auth.initRegistration();
    setState(() {
      _name = id[3];
      _userId = id[5];
    });
  }

  void registerWithDevice() async {
    List user = widget.auth.createUserId();
    _userSecret = user[1];
    if(widget.auth.validateAndSave(formKey)){
      Uint8List _chirpData = widget.auth.createChirp(_userId, _userSecret, 'register');
      widget.auth.registerHome(_userId, _userSecret, _homeId,_homeName, _chirpData);
    }
  }

  void goToHome() async {
    bool registered = await widget.auth.registerCheck(_homeId, _userId);
    if(registered){
      print('User registered');
      widget.auth.createToast('User registered with device');
      Navigator.pop(context);
    }else{
      print('User not found');
      widget.auth.createToast('Try again');
    }
  }

  void cancelRegister() {
    Navigator.pop(context);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: kBackground,
                padding: EdgeInsets.only(left: 10.0,right: 10.0,top: 10.0),
                child: Form(
                  key: formKey,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: logo() + buildInputs() + buildButtons()
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  List<Widget> logo() {
    return [
      Column(
      crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Register New Home',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> buildInputs() {
    return[
      SizedBox(height: 10.0),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: 60.0,
            child: TextFormField(
              enabled: false,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                Icons.person,
                color: Colors.white,
                ),
                hintText: _name,
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 20.0,),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: 60.0,
            child: TextFormField(
              onSaved: (input) => _homeName = input,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                hintText: 'Enter home name',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 20.0,),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: 60.0,
            child: TextFormField(
              onSaved: (input) => _homeId = input,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                hintText: 'Enter home ID',
                hintStyle: kHintTextStyle,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> buildButtons() {
    return [
      SizedBox(height:20.0),
      RaisedButton(
        child: Text('Register with device'),
        onPressed: registerWithDevice,
      ),
      SizedBox(height:10.0),
      RaisedButton(
        child: Text('Continue'),
        onPressed: goToHome,        
      ),
      SizedBox(height:10.0),
      RaisedButton(
        child: Text('Cancel'),
        onPressed: cancelRegister,        
      ),
    ];
  }
}