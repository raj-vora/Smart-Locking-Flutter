import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:smart_lock/constants/auth.dart';
import 'package:smart_lock/constants/ui_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

class HomePage extends StatefulWidget {
  HomePage({this.auth, this.onSignedOut, this.registerHome});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final VoidCallback registerHome;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _userId, _userName='User', _homeId, _homeName;
  Map<String, String> homes={};
  dynamic homeIds, homeNames;
  final db = Firestore.instance;
  final LocalAuthentication localAuth = LocalAuthentication();
  bool authenticated = false;
  bool _unlockbuttondisabled = false;

  @override
  void initState() {
    super.initState();
    getInfo();
    widget.auth.requestPermissions();
    widget.auth.initChirp();
    _unlockbuttondisabled = false;
  }

  void getInfo() async {
    String loginid, userid, name, phoneid, currentphoneid;
    Map<String,String> homestemp={};
    try {
      Firestore.instance.settings(persistenceEnabled: true);
      bool canCheckBiometrics = await localAuth.canCheckBiometrics;
      if(canCheckBiometrics) {
        var localAuth = LocalAuthentication();
        authenticated = await localAuth.authenticateWithBiometrics(localizedReason: 'Please authenticate to continue');
        if(!authenticated){
          widget.auth.createToast('Device user not authenticated');
          _signOut();
        }
      }
      loginid = await widget.auth.currentUser();
      await db.collection('users').getDocuments().then((snapshot){
        snapshot.documents.forEach((f){
          if(f['authId']==loginid){
            userid = f['userId'];
            name = f['name'];
            phoneid = f['deviceId'];
          }
        });
      });
      currentphoneid = await widget.auth.getDeviceId();
      if(currentphoneid != phoneid){
        widget.auth.createToast('User already logged in on another device');
        _signOut();
      }
      await db.document('users/$userid').collection('homes').getDocuments().then((snapshot) {
        snapshot.documents.forEach((f) {
          homestemp[f.documentID] = f['homeName'];
        });
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      _userId = userid;
      _userName = name;
      if(homestemp.isNotEmpty){
        homes.addAll(homestemp);
        homeIds = homes.keys;
        homeNames = homes.values;
        _homeName = homeNames.first;
      }
    });
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }
  
  void unlockDoor() async{
    String _userSecret;
    Firestore.instance.settings(persistenceEnabled: true);
    homes.forEach((id,name) {
      if(name == _homeName){
        _homeId = id;
      }
    });
    await db.document("users/$_userId/homes/$_homeId").get().then((snapshot){
      _userSecret = snapshot['secret'];
    });
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
                decoration: kBackground,
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: userName() + selectHome() + homeButtons()
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.only(right: 10.0, bottom: 10.0),
        child: FloatingActionButton(
          onPressed: widget.registerHome,
          tooltip: 'Add Home',
          child: Icon(Icons.add, color: Colors.black,),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  List<Widget> userName() {
    return[
      SizedBox(height: 20.0,),
      Column(
      crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Welcome $_userName',
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

  List<Widget> selectHome() {
    if(homes.isNotEmpty){
      return[
        SizedBox(height: 50.0,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Select home:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold
              ),
            ),
            DropdownButton<String>(
              value: _homeName,
              icon: Icon(Icons.home),
              iconSize: 24,
              elevation: 16,
              iconEnabledColor:Colors.black,
              onChanged: (String value) {
                setState(() {
                  _homeName = value;
                });
              },
              items: homeNames
                .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(),
                    ),
                ); 
              }).toList(),
            ),
          ],
        ),
      ];
    }
    return[
      SizedBox(height: 50.0,),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Select home:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0
            ),
          ),
        ],
      )
    ];
  }

  List<Widget> homeButtons() {
    return[
      SizedBox(height: 100,),
      RaisedButton(
        child: Text('Unlock Door'),
        onPressed: _unlockbuttondisabled ? null : unlockDoor,                      
      ),
    ];
  }

}