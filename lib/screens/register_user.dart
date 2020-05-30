import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_lock/constants/auth.dart';
import 'package:smart_lock/constants/ui_constants.dart';

class RegisterUser extends StatefulWidget {
  RegisterUser({this.auth});
  final BaseAuth auth;
  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final formKey = GlobalKey<FormState>();
  final FirebaseMessaging messaging = FirebaseMessaging();
  String _name, _deviceId, _mobileNumber, _authId, _userId, _emailId;
  Map<String, String> json;

  @override
  void initState() {
    super.initState();
    initPlatformState();
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
      'authId' : _authId,
      'name' : _name,
      'deviceId' : _deviceId,
      'mobileNumber' : _mobileNumber,
      'emailId' : _emailId,
      'userId': _userId
    };
  }

  void goToRegisterHome() async {
    List user = widget.auth.createUserId();
    _userId = user[0];
    if(widget.auth.validateAndSave(formKey)){
      createJson();
      widget.auth.registerUser(_userId, json);
      widget.auth.createToast('User Details Saved');
      Navigator.pushNamed(context, 'registerHome');
    }
  }

  void goToLogin() {
    widget.auth.deleteUser();
    Navigator.pop(context);
    widget.auth.createToast('User Registration Cancelled');
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
            'User Details',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
              fontSize: 50.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> buildInputs() {
    return[
      SizedBox(height: 40.0),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            decoration: kBoxDecorationStyle,
            height: 60.0,
            child: TextFormField(
              validator: (input) => input.length==0 ? 'Name cannot be blank': null,
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
    ];
  }

  List<Widget> buildButtons() {
    return [
      SizedBox(height:20.0),
      RaisedButton(
        child: Text('Continue'),
        onPressed: goToRegisterHome,
      ),
      SizedBox(height:10.0),
      RaisedButton(
        child: Text('Cancel'),
        onPressed: goToLogin,       
      ),
    ];
  }
}