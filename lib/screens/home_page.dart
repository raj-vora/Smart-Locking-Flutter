import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_lock/constants/auth.dart';
import 'package:smart_lock/constants/ui_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'dart:convert';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _authId, _userId, _userSecret, _userName, _homeId, _deviceId, _currentDeviceId;
  List<String> homes = ['1'];
  final db = Firestore.instance;

  @override
  void initState() {
    super.initState();
    getInfo();
    sleep(Duration(milliseconds: 500));
    widget.auth.requestPermissions();
    widget.auth.initChirp();
  }

  Future<void> getInfo() async {
    try {
      _authId = await widget.auth.currentUser();
      db.collection('users').where("authId", isEqualTo: _authId).snapshots().listen((data) => data.documents.forEach((f) {
        _userId = f['userId'];
        _userName = f['name'];
        _deviceId = f['deviceId'];
      }));
      _currentDeviceId = await widget.auth.getDeviceId();
      if(_deviceId == _currentDeviceId){
        widget.auth.createToast('User already logged in on another device');
        await widget.auth.signOut();
        widget.onSignedOut();
      }
      db.collection('users').document(_userId).collection('homes').getDocuments().then((QuerySnapshot snapshot) {
        snapshot.documents.forEach((f) => homes.add(f.documentID));
      });
      print(homes);
      _homeId = homes.first;
      
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
  
  void unlockDoor() {
    /*temp = db.collection('users').document(_userId).collection('homes').snapshots().listen((snapshot) {
      snapshot.documents.forEach((f) => debugPrint(f.data.toString()));
    });*/
    db.collection('users').document(_userId).collection('homes').where('homeId', isEqualTo: _homeId).snapshots().listen((data) => data.documents.forEach((f) {
      _userSecret = f['secret'];
    }));
    sleep(Duration(milliseconds: 500));
    Uint8List _chirpData = widget.auth.createChirp(_userId, _userSecret, 'normal');
    widget.auth.sendChirp(_chirpData);
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
                      onPressed: unlockDoor,
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