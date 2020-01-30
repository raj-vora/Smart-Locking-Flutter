import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_lock/constants/auth.dart';
import 'package:smart_lock/constants/ui_constants.dart';
import 'dart:typed_data';
class Registration extends StatefulWidget {
  Registration({this.auth,this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final formKey = GlobalKey<FormState>();
  String _name, _deviceId, _mobileNumber, _authId, _userId, _emailId, _userSecret, _homeId, _homeName;
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
      _deviceId = id[0];
      _authId = id[1];
      _emailId = id[2];
    });
  }

  void createJson() {
    json = <String, String>{
      'userId' : _userId,
      'authId' : _authId,
      'name' : _name,
      'deviceId' : _deviceId,
      'mobileNumber' : _mobileNumber,
      'emailId' : _emailId,
    };
  }

  void registerWithDevice() async {
    List user = widget.auth.createUserId();
    _userId = user[0];
    _userSecret = user[1];
    if(widget.auth.validateAndSave(formKey)){
      createJson();
      Uint8List _chirpData = widget.auth.createChirp(_userId, _userSecret, 'register');
      widget.auth.registerUser(_userId, _userSecret, _homeId, json, _chirpData, _homeName);
    }
  }

  void goToHome() async {
    bool registered = await widget.auth.registerCheck(_homeId, _userId);
    if(registered){
      print('user registered');
      widget.auth.createToast('User registered with device');
      widget.onSignedIn();
    }else{
      print('user not found');
      widget.auth.createToast('Try again');
    }
  }
  
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
            'Registration',
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
              textCapitalization: TextCapitalization.words,
              onSaved: (input) => _name = input,
              autofocus: true,
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
    ];
  }
}