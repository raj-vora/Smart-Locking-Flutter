import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_lock/auth.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:smart_lock/constants.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:chirp_flutter/chirp_flutter.dart';
import 'package:smart_lock/hashing_secret.dart';
import 'dart:convert';

class Registration extends StatefulWidget {
  Registration({this.auth});
  final BaseAuth auth;
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final formKey = GlobalKey<FormState>();
  final db = Firestore.instance;
  String _name, _deviceId, _mobileNumber, _authId, _userId, _emailId, _userSecret, _homeId;
  String _appKey = 'a7cbAC032bad0FBbCA0bAE528';
  String _appSecret = 'ac0E3e41c3AfFBE3CED431e5CE4Eee8aC1e793BF353a42bd7E';
  String _appConfig = 'aTEFRnJLaqzx7nF0U9nb4+SLAjabUC3wBgvMu+0K9LOgGneO16xBh/9WxlkwVf3IRX9mtM1e1aLStrd4jHCFpTm6RLMsAU/bTf4OzxhB8trz0UXvjO2kRIXPuUiaLrc5I1Ekm1wpgtVW3S+dy3SPoe1/eWo9kj6JWUNfNZZdcgKwxhyeI/j9NBNTxp/NFdtFSjQRpuDjxZkw1Ttf/cBDDY0X3FlaG+7j3/OaPa/plVtAMe7Enxjt2CQ6Eg10pzei1tP7RoK/A88EH8RDHmEBCklZGMLmU8RsE08Wv3wEywbc5jG06Edc+KudW19xo7Ab/h2ZHcohkVMjbuO5QkmiH2fGaXNR/0rsKc26q/L740Zsfrw2BoI3mhYEWvYQaHz4LQoD+OrtYvtcasuAlpkjYrlhUo/wUrB4TdLOkPLX4JImmaJZGqmGrHS0NBP9GEhj4c3M3qTEX4MZuU/ai/tWGZEs/grtqbwbOKi0fWwroBUJp1Ba2Edh50KnhcoT2jw3OF6yCZSWPotD9ui/OIbNkdvU2M+ZU7X4+wXtP2IGGz57xCRpNjjeYoxygOao/7DIx8fRaznDgETcgFTRmyfgaMtcGcgwQn3xff9N5nLIFhqfiaZ+UMl8LqfNAsIgqJz5rLPFSHNMGNf1PgTOUF48pLAK7pM10fSMKA38ZEihX9soBaRKwT4L0cAN7e2eG74HPC6jHxxqUrQOBZMjS8x7MUCpnQd7SuSglILXpPZfclVEXVVHlYGnKkAt7xK1iJr0/a+TbP2Jh0csVVkS6s7oK1oqo2gv2J6itQ1dHCtphP1jUja4WtXXBCMaV48h0fNUW8f9oQVhnuB7+CeoOwPE6IuWdrtNxDs+hMwainS/dxs=';

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.microphone);
    if (permission.toString() != 'granted') {
      await PermissionHandler().requestPermissions([PermissionGroup.microphone]);
    }
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
      // Init ChirpSDK
      await ChirpSDK.init(_appKey, _appSecret);
      // Set SDK config
      await ChirpSDK.setConfig(_appConfig);
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

  void sendChirp() async {
    createUserId();
    String hashedSecret = hashSecret(_userSecret);
    String payload ='r' + _userId + hashedSecret;
    Uint8List _chirpData = utf8.encode(payload);
    var json = {
      'userId' : _userId,
      'authId' : _authId,
      'userSecret' : _userSecret,
      'name' : _name,
      'deviceId' : _deviceId,
      'mobileNumber' : _mobileNumber,
      'emailId' : _emailId,
      'homeId' : _homeId
    };
    if(validateAndSave()){
      try {
        await db.collection('users').add(json).then((documentReference) {
          print(documentReference.documentID);
        }).catchError((e) {print(e);});
        await ChirpSDK.start();
        await ChirpSDK.send(_chirpData);
        print(_chirpData);
        Fluttertoast.showToast(
          msg: "Chirp Sent",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 3,
          backgroundColor: Colors.white,
          textColor: Colors.blue,
          fontSize: 16.0
        );
      }
      catch (e) {
        print(e);
      }
    }
  }

  void goToHome() async {
    await ChirpSDK.stop();
    Fluttertoast.showToast(
          msg: "SDK Stopped",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 3,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0
        );
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