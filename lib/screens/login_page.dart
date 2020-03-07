import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  
  @override
  void initState() {
    super.initState();
  }

  final formKey = GlobalKey<FormState>();
  String _email, _password;
  FormType _formType = FormType.login;
  
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
          Navigator.pushNamed(context, 'register');
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
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                decoration: kBackground,
                padding: EdgeInsets.only(left: 10.0,right: 10.0,top: 10.0),
                child: Form(
                  key: formKey,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: logo() + buildInputs() + buildSubmitButtons()
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
        'Smart Lock',
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
      SizedBox(height: 40.0,),
      Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
      ],
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
            obscureText: true,
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
            ),
          ),
        ),
      ],
    ),
    ];
  }

  List<Widget> buildSubmitButtons() {
    if(_formType == FormType.login){
      return [
        Column(
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
      ];
    } else{
      return [
        SizedBox(height: 20.0,),
        RaisedButton(
          child: Text('Register', style: TextStyle(fontSize: 20.0)),
          onPressed: validateAndSubmit,
        ),
        
        FlatButton(
          child: Text('Already a user? Login', style: TextStyle(fontSize: 15.0, color: Colors.white)),
          onPressed: moveToLogin,
        )
      ];
    }
  }
}