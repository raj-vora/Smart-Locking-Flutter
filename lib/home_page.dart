import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_lock/auth.dart';
import 'package:smart_lock/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:chirp_flutter/chirp_flutter.dart';
import 'package:smart_lock/hashing_secret.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _authId, _userId, _userSecret, _userName, _homeId, _hashedSecret;
  String _appKey = 'a7cbAC032bad0FBbCA0bAE528';
  String _appSecret = 'ac0E3e41c3AfFBE3CED431e5CE4Eee8aC1e793BF353a42bd7E';
  String _appConfig = 'aTEFRnJLaqzx7nF0U9nb4+SLAjabUC3wBgvMu+0K9LOgGneO16xBh/9WxlkwVf3IRX9mtM1e1aLStrd4jHCFpTm6RLMsAU/bTf4OzxhB8trz0UXvjO2kRIXPuUiaLrc5I1Ekm1wpgtVW3S+dy3SPoe1/eWo9kj6JWUNfNZZdcgKwxhyeI/j9NBNTxp/NFdtFSjQRpuDjxZkw1Ttf/cBDDY0X3FlaG+7j3/OaPa/plVtAMe7Enxjt2CQ6Eg10pzei1tP7RoK/A88EH8RDHmEBCklZGMLmU8RsE08Wv3wEywbc5jG06Edc+KudW19xo7Ab/h2ZHcohkVMjbuO5QkmiH2fGaXNR/0rsKc26q/L740Zsfrw2BoI3mhYEWvYQaHz4LQoD+OrtYvtcasuAlpkjYrlhUo/wUrB4TdLOkPLX4JImmaJZGqmGrHS0NBP9GEhj4c3M3qTEX4MZuU/ai/tWGZEs/grtqbwbOKi0fWwroBUJp1Ba2Edh50KnhcoT2jw3OF6yCZSWPotD9ui/OIbNkdvU2M+ZU7X4+wXtP2IGGz57xCRpNjjeYoxygOao/7DIx8fRaznDgETcgFTRmyfgaMtcGcgwQn3xff9N5nLIFhqfiaZ+UMl8LqfNAsIgqJz5rLPFSHNMGNf1PgTOUF48pLAK7pM10fSMKA38ZEihX9soBaRKwT4L0cAN7e2eG74HPC6jHxxqUrQOBZMjS8x7MUCpnQd7SuSglILXpPZfclVEXVVHlYGnKkAt7xK1iJr0/a+TbP2Jh0csVVkS6s7oK1oqo2gv2J6itQ1dHCtphP1jUja4WtXXBCMaV48h0fNUW8f9oQVhnuB7+CeoOwPE6IuWdrtNxDs+hMwainS/dxs=';
  List<String> homes = ['1'];
  final db = Firestore.instance;

  @override
  void initState() {
    super.initState();
    getInfo();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.microphone);
    if (permission.toString() != 'granted') {
      await PermissionHandler().requestPermissions([PermissionGroup.microphone]);
    }
  }

  Future<void> getInfo() async {
    try {
      _authId = await widget.auth.currentUser();
      db.collection('users').where("authId", isEqualTo: _authId).snapshots().listen((data) => data.documents.forEach((f) {
        _userId = f['userId'];
        _userName = f['name'];
      }));
      db.collection('users').document(_userId).collection('homes').getDocuments().then((QuerySnapshot snapshot) {
        snapshot.documents.forEach((f) => homes.add(f.documentID));
      });
      _homeId = homes.first;
      // Init ChirpSDK
      await ChirpSDK.init(_appKey, _appSecret);
      // Set SDK config
      await ChirpSDK.setConfig(_appConfig);
    } catch (e) {
      print(e);
    }
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }
  
  void getUserDetails() async {
    /*temp = db.collection('users').document(_userId).collection('homes').snapshots().listen((snapshot) {
      snapshot.documents.forEach((f) => debugPrint(f.data.toString()));
    });*/
    await db.collection('users').document(_userId).collection('homes').where('homeId', isEqualTo: _homeId).snapshots().listen((data) => data.documents.forEach((f) {
      _userSecret = f['secret'];
    }));
    _hashedSecret = hashSecret(_userSecret);
    String payload = 'n' + _userId + _hashedSecret;
    Uint8List _chirpData = utf8.encode(payload);
    await ChirpSDK.start();
    await ChirpSDK.send(_chirpData);
    print(_chirpData);
    sleep(Duration(seconds: 5));
    Fluttertoast.showToast(
          msg: "Chirp Sent",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 3,
          backgroundColor: Colors.white,
          textColor: Colors.blue,
          fontSize: 16.0
        );
    await ChirpSDK.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Lock'),
        actions: <Widget>[
          FlatButton(
            child: Text('Logout', style: TextStyle(fontSize: 17.0, color: Colors.white,)),
            onPressed: _signOut,
          )
        ],
      ),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('Welcome $_userName', style: TextStyle(fontSize: 20.0),),
                    SizedBox(height: 50,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text('Select home:'),
                        DropdownButton<String>(
                          value: _homeId,
                          icon: Icon(Icons.home),
                          iconSize: 24,
                          elevation: 16,
                          onChanged: (String value) {
                            setState(() {
                              _homeId = value;
                              print(_homeId);
                            });
                          },
                          items: homes
                            .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ); 
                          }).toList(),
                        ),
                      ],
                    ),
                    SizedBox(height: 50,),
                    RaisedButton(
                      child: Text('Unlock Door'),
                      onPressed: getUserDetails,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}