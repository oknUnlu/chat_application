import 'package:chat_application/helper/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  uploadUserInfo(userMap) {
    FirebaseFirestore.instance.collection('users').add(userMap).catchError((e) {
      print(e.toString());
    });
  }

  createChatRoom(String chatRoomId, chatRoomMap) {
    // ignore: deprecated_member_use
    FirebaseFirestore.instance
        .collection("ChatRoom")
        // ignore: deprecated_member_use
        .doc(chatRoomId)
        // ignore: deprecated_member_use
        .set(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getChatRooms(String phoneNumber) async {
    // ignore: deprecated_member_use
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("phones", arrayContains: phoneNumber)
        .snapshots();
  }

  getChatRoomsId(String phoneNumber) async {
    // ignore: deprecated_member_use
     /*await FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("phones", arrayContains: phoneNumber)
        .get()
        .then(
          (QuerySnapshot snapshot) => snapshot.docs.forEach((f) {
            return f.reference.id;
          }),
        ); */

    await FirebaseFirestore.instance.collection('ChatRoom').
    where("phones", arrayContains: phoneNumber).get().then((event) {
      if (event.docs.isNotEmpty) {
        Map<String, dynamic> documentData = event.docs.single.data(); //if it is a single document
      }
    }).catchError((e) => print("error fetching data: $e"));
    var test;

     print(test);
    /*var document = await FirebaseFirestore.instance.collection('ChatRoom').
    where("phones", arrayContains: phoneNumber)
    var test = document.get();
    print(test);*/
  }

  addConversationMessages(String chatRoomId, messageMap) {
    // ignore: deprecated_member_use
    FirebaseFirestore.instance
        .collection("ChatRoom")
        // ignore: deprecated_member_use
        .doc(chatRoomId)
        .collection("chats")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getConversationMessages(String chatRoomId) async {
    // ignore: deprecated_member_use
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        // ignore: deprecated_member_use
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }

  updateLastMessage(
      String chatRoomId, String message, String date, bool read) async {
    // ignore: deprecated_member_use
    FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).update({
      'lastMessage.content': message, //last message
      'lastMessage.read': read, //is it read ?
      'lastMessage.timestamp': date, //last message time
    });
  }

  Future<void> updateDataFirestore(
      String collectionPath, String path, Map<String, String> dataNeedUpdate) {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(path)
        .update(dataNeedUpdate);
  }
}
