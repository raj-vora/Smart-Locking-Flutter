import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_lock/auth.dart';
import 'package:smart_lock/constants.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.auth, this.onSignedIn, this.register});
  final BaseAuth auth;
  final VoidCallback onSignedIn, register;
  @override
  _LoginPageState createState() => _LoginPageState();
}

enum FormType{
  login,
  register
}

class _LoginPageState extends State<LoginPage> {
  
  final formKey = GlobalKey<FormState>();
  String _email, _password;
  FormType _formType = FormType.login;
  
  bool validateAndSave() {
    final form = formKey.currentState;
    if(form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    if(validateAndSave()) {
      try{
        if(_formType == FormType.login) {
          String userId = await widget.auth.signInWithEmailAndPassword(_email, _password);
          print('Signed in: $userId');
          widget.onSignedIn();
        } else{
          String userId = await widget.auth.createUserWithEmailAndPassword(_email, _password);
          print('Registered user: $userId');
          widget.register();
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
                    children: logo() + buildInputs() + buildSubmitButtons()
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
          fontSize: 40.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 10.0),
      ],
    ),
    ];
  }

  List<Widget> buildInputs() {
    return[
      Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Email',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
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
    SizedBox(height: 20.0,),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Password',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
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
        SizedBox(height: 20.0,),
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