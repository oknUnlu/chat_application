import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  getUserByUsername(String username) async {
    // ignore: deprecated_member_use
    return await Firestore.instance
        .collection("users")
        .where("name", isEqualTo: username)
    // ignore: deprecated_member_use
        .getDocuments();
  }

  getUserByUserEmail(String email) async {
    // ignore: deprecated_member_use
    return await Firestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
    // ignore: deprecated_member_use
        .getDocuments();
  }

  uploadUserInfo(userMap) {
    // ignore: deprecated_member_use
    Firestore.instance.collection("users").add(userMap).catchError((e) {
      print(e.toString());
    });
  }

  createChatRoom(String chatRoomId, chatRoomMap) {
    // ignore: deprecated_member_use
    Firestore.instance
        .collection("ChatRoom")
        // ignore: deprecated_member_use
        .document(chatRoomId)
        // ignore: deprecated_member_use
        .setData(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  addConversationMessages(String chatRoomId, messageMap) {
    // ignore: deprecated_member_use
    Firestore.instance
        .collection("ChatRoom")
        // ignore: deprecated_member_use
        .document(chatRoomId)
        .collection("chats")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getConversationMessages(String chatRoomId) async {
    // ignore: deprecated_member_use
    return Firestore.instance
        .collection("ChatRoom")
        // ignore: deprecated_member_use
        .document(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: false)
        .snapshots();
  }

  getChatRooms(String userName) async {
    // ignore: deprecated_member_use
    return Firestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: userName)
        .snapshots();
  }
}
