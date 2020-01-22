import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_lock/auth.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:smart_lock/constants.dart';
import 'dart:math';

class Registration extends StatefulWidget {
  Registration({this.auth});
  final BaseAuth auth;
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final formKey = GlobalKey<FormState>();

  String _name, _deviceId, _mobileNumber, _authId, _userId, _emailId, _userSecret, _homeId;
  //String _platformImei = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    //String platformImei;
    String idunique;
    var user, email;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      //platformImei = await ImeiPlugin.getImei( shouldShowRequestPermissionRationale: false );
      idunique = await ImeiPlugin.getId();
      user  = await widget.auth.currentUser();
      email = await widget.auth.getEmailId();
    } catch(e) {
      //platformImei = e;
    }
    
    setState(() {
      //_platformImei = platformImei;
      _deviceId = idunique;
      _authId = user;
      _emailId = email;
    });
  }

  void createUserId() async {
    String secret = '';
    String id = '';
    String set = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    var rand = new Random();
    for (int i = 0; i < 16; i++) {
      var temp = rand.nextInt(62);
      secret += set[temp];
    }
    for (int i = 0; i < 15; i++) {
      var temp = rand.nextInt(62);
      id += set[temp];
    }
    _userId = id;
    _userSecret = secret;
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if(form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void sendChirp() {
    createUserId();
    if(validateAndSave()){
      print('Name: $_name');
      print('DeviceId: $_deviceId');
      print('Number: $_mobileNumber');
      print('AuthID: $_authId');
      print('UserID: $_userId');
      print('EmailID: $_emailId');
      print('secret: $_userSecret');
      print('home: $_homeId');
    }
  }

  void goToHome() {}
  
  @override
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
                padding: EdgeInsets.all(10.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: logo() + buildInputs() + buildButtons()
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
        'Registration',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'OpenSans',
          fontSize: 40.0,
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
              onSaved: (input) => _name = input,
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
                hintText: 'Enter your name',
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
              keyboardType: TextInputType.phone,
              validator: (input) => input.length<10 ? 'Invalid Number' : null,
              onSaved: (input) => _mobileNumber = input,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.phone_android,
                  color: Colors.white,
                ),
                hintText: 'Enter your Mobile Number',
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
              enabled: false,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.email,
                  color: Colors.white,
                ),
                hintText: _emailId,
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
        onPressed: sendChirp,
      ),
      SizedBox(height:10.0),
      RaisedButton(
        child: Text('Continue'),
        onPressed: goToHome,
      ),
    ];
  }
}