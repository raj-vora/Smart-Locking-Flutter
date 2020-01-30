import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:chirp_flutter/chirp_flutter.dart';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

abstract class BaseAuth {
  //FIREBASE FUNCTIONS
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<String> currentUser();
  Future<String> getEmailId();
  Future<void> resetPassword(String _emailId);
  Future<void> signOut();
  
  //FORM VALIDATION FUNCTION
  bool validateAndSave(formKey);
  
  //CHIRP FUNCTIONS
  Future<void> requestPermissions();
  Future<void> initChirp();
  Uint8List createChirp(String _userId, String _userSecret, String mode);
  Future<void> sendChirp(Uint8List _chirpData);
  
  //REGISTRATION FUNCTION
  Future<List> initRegistration();
  Future<String> getDeviceId();
  List createUserId();
  void registerUser(String _userId, String _userSecret, String _homeId, Map<String, String> json, Uint8List _chirpData, String _homeName);
  Future<bool> registerCheck(String _homeId, String _userId);
  
  //BOTTOM TOAST
  void createToast(String message);
  
  //HASHING FUNCTION
  String hashSecret (String _userSecret);
}

class Auth implements BaseAuth{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final db = Firestore.instance;

  //FIREBASE FUNCTIONS
  Future<String> signInWithEmailAndPassword(String email, String password) async {
    FirebaseUser user;
    try {
    user = (await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user;
    }on PlatformException{
      createToast('User does\'t exist');
    }
    return user.uid;
  }

  Future<String> createUserWithEmailAndPassword(String email, String password) async {
    FirebaseUser user = (await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user;
    return user.uid;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }

  Future<String> getEmailId() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.email;
  }

  Future<void> resetPassword(String _emailId) async {
    await _firebaseAuth.sendPasswordResetEmail(email: _emailId);
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  //CHIRP FUNCTIONS
  Future<void> requestPermissions() async {
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.microphone);
    if (permission.toString() != 'granted') {
      await PermissionHandler().requestPermissions([PermissionGroup.microphone]);
    }
  }

  Future<void> initChirp() async {
    String _appKey = 'a7cbAC032bad0FBbCA0bAE528';
    String _appSecret = 'ac0E3e41c3AfFBE3CED431e5CE4Eee8aC1e793BF353a42bd7E';
    String _appConfig = 'aTEFRnJLaqzx7nF0U9nb4+SLAjabUC3wBgvMu+0K9LOgGneO16xBh/9WxlkwVf3IRX9mtM1e1aLStrd4jHCFpTm6RLMsAU/bTf4OzxhB8trz0UXvjO2kRIXPuUiaLrc5I1Ekm1wpgtVW3S+dy3SPoe1/eWo9kj6JWUNfNZZdcgKwxhyeI/j9NBNTxp/NFdtFSjQRpuDjxZkw1Ttf/cBDDY0X3FlaG+7j3/OaPa/plVtAMe7Enxjt2CQ6Eg10pzei1tP7RoK/A88EH8RDHmEBCklZGMLmU8RsE08Wv3wEywbc5jG06Edc+KudW19xo7Ab/h2ZHcohkVMjbuO5QkmiH2fGaXNR/0rsKc26q/L740Zsfrw2BoI3mhYEWvYQaHz4LQoD+OrtYvtcasuAlpkjYrlhUo/wUrB4TdLOkPLX4JImmaJZGqmGrHS0NBP9GEhj4c3M3qTEX4MZuU/ai/tWGZEs/grtqbwbOKi0fWwroBUJp1Ba2Edh50KnhcoT2jw3OF6yCZSWPotD9ui/OIbNkdvU2M+ZU7X4+wXtP2IGGz57xCRpNjjeYoxygOao/7DIx8fRaznDgETcgFTRmyfgaMtcGcgwQn3xff9N5nLIFhqfiaZ+UMl8LqfNAsIgqJz5rLPFSHNMGNf1PgTOUF48pLAK7pM10fSMKA38ZEihX9soBaRKwT4L0cAN7e2eG74HPC6jHxxqUrQOBZMjS8x7MUCpnQd7SuSglILXpPZfclVEXVVHlYGnKkAt7xK1iJr0/a+TbP2Jh0csVVkS6s7oK1oqo2gv2J6itQ1dHCtphP1jUja4WtXXBCMaV48h0fNUW8f9oQVhnuB7+CeoOwPE6IuWdrtNxDs+hMwainS/dxs=';
    // Init ChirpSDK
      await ChirpSDK.init(_appKey, _appSecret);
      // Set SDK config
      await ChirpSDK.setConfig(_appConfig);
  }

  Uint8List createChirp(String _userId, String _userSecret, String mode) {
    String hashedSecret = hashSecret(_userSecret);
    String payload;
    if(mode == 'register'){
    payload ='r' + _userId + hashedSecret;
    }else{
      payload ='n' + _userId + hashedSecret;
    }
    Uint8List _chirpData = utf8.encode(payload);
    return _chirpData;
  }

  Future<void> sendChirp(Uint8List _chirpData) async {
    await ChirpSDK.start();
    await ChirpSDK.send(_chirpData);
    sleep(Duration(seconds: 5));
    createToast('Chirp Sent');
    await ChirpSDK.stop();
  }

  //REGISTRATION FUNCTIONS
  Future<List> initRegistration() async{
    Firestore.instance.settings(persistenceEnabled: true);
    String idunique, user, email;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      //platformImei = await ImeiPlugin.getImei( shouldShowRequestPermissionRationale: false );
      idunique = await getDeviceId();
      user  = await currentUser();
      email = await getEmailId();
    } catch(e) {
      print(e);
    }
    return [idunique, user, email];
  }

  Future<String> getDeviceId() async{
  String deviceId = await ImeiPlugin.getId();
  return deviceId;
  }

  List createUserId() {
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
    return [id, secret];
  }

  void registerUser(String _userId, String _userSecret, String _homeId, Map<String, String> json, Uint8List _chirpData, String _homeName) async{
    try {
      await db.collection('users').document(_userId).setData(json);
      await db.document('users/$_userId/homes/$_homeId').setData({
        'secret':_userSecret,
        'homeId':_homeId,
        'homeName': _homeName
      });
      await db.document('homes/$_homeId/occupants/$_userId').setData({
        'secret':_userSecret,
        'userId':_userId
      });
      sendChirp(_chirpData);
    }catch (e) {
      print(e);
    }
  }

  Future<bool> registerCheck(String _homeId, String _userId) async {
    Firestore.instance.settings(persistenceEnabled: true);
    List occupants=[];
    sleep(Duration(seconds: 1)); 
    await db.collection('homes').document(_homeId).collection('occupants').getDocuments().then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => occupants.add(f.documentID));
    });
    print(occupants);
    if(occupants.contains(_userId)){
    return true;
    }
    return false;
  }

  //FORM VALIDATION FOR REGISTRATION AND LOGIN PAGES
  bool validateAndSave(formKey) {
    final form = formKey.currentState;
      if(form.validate()) {
        form.save();
        print('Form Saved');
        return true;
      }
      return false;
  }

  //BOTTOM TOAST
  void createToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 1,
      backgroundColor: Colors.white,
      textColor: Colors.black,
      fontSize: 16.0
    );
  }

  //CREATE HASHED USERSECRET
  String hashSecret (String _userSecret) {
    var temp = new DateTime.now().millisecondsSinceEpoch;
    double time = temp/100000;
    String timestamp = time.toString();
    var key = utf8.encode(timestamp);
    var secret = utf8.encode(_userSecret);
    var hmacSha1 = new Hmac(sha1, key); // HMAC-SHA1
    var digest = hmacSha1.convert(secret);
    return digest.toString().substring(1,16);
  }
}