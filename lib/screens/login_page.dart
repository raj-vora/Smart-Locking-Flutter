import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_lock/components/logo.dart';
import 'package:smart_lock/constants/auth.dart';
import 'package:smart_lock/constants/ui_constants.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.auth});
  final BaseAuth auth;
  @override
  _LoginPageState createState() => _LoginPageState();
}

enum FormType{
  login,
  register
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseMessaging messaging = FirebaseMessaging();
  final formKey = GlobalKey<FormState>();
  String _email, _password;
  FormType _formType = FormType.login;
  bool passwordVisible;
  
  @override
  void initState() {
    super.initState();
    passwordVisible = false;
    messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        var homeId = message['data']['homeId'];
        var userId = message['data']['userId'];
        print("onMessage: $homeId");
        print("onMessage: $userId");
      },
      onLaunch: (Map<String, dynamic> message) async {
        var homeId = message['data']['homeId'];
        var userId = message['data']['userId'];
        print("onLaunch: $homeId");
        print("onLaunch: $userId");
      },
      onResume: (Map<String, dynamic> message) async {
        var homeId = message['data']['homeId'];
        var userId = message['data']['userId'];
        print("onResume: $homeId");
        print("onResume: $userId");
      },
    );
  }
  
  void validateAndSubmit() async {
    if(widget.auth.validateAndSave(formKey)) {
      try{
        if(_formType == FormType.login) {
          String userId = await widget.auth.signInWithEmailAndPassword(_email, _password);
          print('Signed in: $userId');
          Navigator.pushNamed(context, 'home');
        } else{
          String userId = await widget.auth.createUserWithEmailAndPassword(_email, _password);
          print('Registered user: $userId');
          Navigator.pushNamed(context, 'registerUser');
        }
      }
      catch(e) {
        print('Error: $e');
      }
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

  void forgotPassword() {
    final form = formKey.currentState;
    form.save();
    widget.auth.resetPassword(_email);
    widget.auth.createToast('Password Reset Mail Sent');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: kBackground,
        padding: EdgeInsets.only(left: 10.0,right: 10.0,top: 10.0),
        child: Form(
          key: formKey,
          child: Center(
            child: ListView(
              children: <Widget>[
                Logo,
                SizedBox(height: 40.0,),
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0,),
                Container(
                  alignment: Alignment.centerLeft,
                  decoration: kBoxDecorationStyle,
                  height: 60.0,
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    validator: (input) => !input.contains('@') ? 'Please enter a valid email' : null,
                    onSaved: (input) => _email = input,
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
                      hintText: 'Enter your Email',
                      hintStyle: kHintTextStyle,
                    ),
                  ),
                ),
              SizedBox(height: 30.0,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.0,),
                  Container(
                    alignment: Alignment.centerLeft,
                    decoration: kBoxDecorationStyle,
                    height: 60.0,
                    child: TextFormField(
                      obscureText: passwordVisible,
                      validator: (input) => input.length<8 ? 'Password cannot be less than 8 characters' : null,
                      onSaved: (input) => _password = input,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'OpenSans',
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 14.0),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.white,
                        ),
                        hintText: 'Enter your Password',
                        hintStyle: kHintTextStyle,
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                            color: Colors.white
                          ), 
                          onPressed: () {
                            setState(() {passwordVisible = !passwordVisible;});
                          }
                        )
                      ),
                    ),
                  ),
                ],
              ),
              _formType == FormType.login 
              ? Column(
                children: <Widget>[Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      child: Text('Forgot Password?', style: TextStyle(fontSize: 15.0, color: Colors.white)),
                      onPressed: forgotPassword,  
                    ),
                  ],
                ),
                RaisedButton(
                  child: Text('Login', style: TextStyle(fontSize: 20.0)),
                  onPressed: validateAndSubmit,
                ),
                FlatButton(
                  child: Text('New User? Create an Account', style: TextStyle(fontSize: 15.0, color: Colors.white)),
                  onPressed: moveToRegister,
                )
                ]
                )
                : Column(children: <Widget>[
                  SizedBox(height: 20.0,),
                  RaisedButton(
                    child: Text('Register', style: TextStyle(fontSize: 20.0)),
                    onPressed: validateAndSubmit,
                  ),
                  FlatButton(
                    child: Text('Already a user? Login', style: TextStyle(fontSize: 15.0, color: Colors.white)),
                    onPressed: moveToLogin,
                  )
                ]
                ),  
              ]
            ),
          ),
        ),
      )
    );
  }
}