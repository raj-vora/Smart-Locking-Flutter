import 'dart:convert';
import 'package:crypto/crypto.dart';

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