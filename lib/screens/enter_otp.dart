import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:smart_lock/constants/auth.dart';
import 'package:smart_lock/constants/ui_constants.dart';

class EnterOtp extends StatefulWidget {
  EnterOtp({this.auth});
  final BaseAuth auth;
  @override
  _EnterOtpState createState() => _EnterOtpState();
}

class _EnterOtpState extends State<EnterOtp> {

  String otp, primaryUser="Name", _enteredOTP, homeId;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  void verifyOtp() {
    if(widget.auth.validateAndSave(formKey)){
      if(otp==_enteredOTP){
        widget.auth.createToast('OTP verified');
        widget.auth.otpVerified(homeId);
        Navigator.pushNamed(context, 'home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final OtpArguments args = ModalRoute.of(context).settings.arguments;
    primaryUser = args.primaryUser;
    otp = args.otp;
    homeId = args.homeId;
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
    SizedBox(height: 20.0,),
    Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
      Text(
        'OTP has been sent to $primaryUser, enter that OTP here to complete registration',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'OpenSans',
          fontSize: 20.0,
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
            'Enter OTP',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0,),
          Container(
            alignment: Alignment.center,
            decoration: kBoxDecorationStyle,
            height: 60.0,
            child: TextFormField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              validator: (input) => input.length<6 ? 'OTP cannot be less than 6 characters' : null,
              onSaved: (input) => _enteredOTP = input,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'OpenSans',
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14.0),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                ),
                hintText: 'Enter your OTP',
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
        child: Text('Verify OTP'),
        onPressed: verifyOtp,
      ),
    ];
  }
}