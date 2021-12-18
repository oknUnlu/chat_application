import 'dart:convert';
import 'package:chat_application/Encryption/encryption.dart';

class EncodingDecodingService {
  static String encodeAndEncrypt(String data) {
    if(data != null) {
      String encodedString = jsonEncode(data);
      return Encryption.encrypt(encodedString);
    }else{
      return null;
    }
  }

  static String decryptAndDecode(String data) {
    // ignore: unnecessary_null_comparison
    if(data != null) {
      String decryptedString = Encryption.decrypt(data);
      return jsonDecode(decryptedString);
    }else{
      return null;
    }
  }
}
