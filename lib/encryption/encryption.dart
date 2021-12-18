import 'package:encrypt/encrypt.dart';

class Encryption {
  static String decrypt(String base64Data) {
    final key = Key.fromLength(32);
    final iv = IV.fromLength(16);

    final encrypt = Encrypter(
      AES(
        key
      ),
    );

    return encrypt.decrypt64(base64Data, iv: iv);
  }

  static String encrypt(String data) {
    final key = Key.fromLength(32);
    final iv = IV.fromLength(16);

    final encrypt = Encrypter(
      AES(
        key
      ),
    );

    return encrypt.encrypt(data, iv: iv).base64;
  }
}
