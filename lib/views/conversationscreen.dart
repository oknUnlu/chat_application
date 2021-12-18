import 'package:chat_application/Encryption/encodingDecoding.dart';
import 'package:chat_application/helper/constants.dart';
import 'package:chat_application/services/database.dart';
import 'package:chat_application/widgets/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConversationScreen extends StatefulWidget {
  final String chatRoomId;

  ConversationScreen(this.chatRoomId);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController messageController = new TextEditingController();
  Stream chatMessageStream;
  //Notifications notifications = new Notifications();
  bool showNotification = true;

  // ignore: non_constant_identifier_names
  Widget ChatMessageList() {
    return StreamBuilder(
        stream: chatMessageStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Container(
                  child: SingleChildScrollView(
                      reverse: true,
                      child: Column(children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.80,
                            child: ListView.builder(
                                reverse: true,
                                itemCount: snapshot.data.docs.length,
                                itemBuilder: (context, index) {
                                  return MessageTile(
                                      EncodingDecodingService.decryptAndDecode(snapshot.data.docs[index]['message']),
                                      snapshot.data.docs[index]['sendBy'] == Constants.myPhoneNumber);
                                })),
                        Padding(
                            padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom +
                                    MediaQuery.of(context).size.height * 0.10))
                      ])))
              : Container();
        });
  }

  sendMessage() async {
    if (messageController.text.isNotEmpty) {
      String encryptedData = EncodingDecodingService.encodeAndEncrypt(messageController.text);
      String date = DateTime.now().millisecondsSinceEpoch.toString();
      Map<String, dynamic> messageMap = {
        "message": encryptedData,
        "sendBy": Constants.myPhoneNumber,
        "time": date
      };

      //showNotification ? notifications.push('New Message', messageController.text) : showNotification = false;
      databaseMethods.addConversationMessages(widget.chatRoomId, messageMap);
      databaseMethods.updateLastMessage(widget.chatRoomId,encryptedData, date, false);
      messageController.text = "";
    }
  }

  // ignore: missing_return
  Future onSelectNotification(String payload) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return NewScreen(
        payload: payload,
      );
    }));
  }

  @override
  void initState() {
    databaseMethods.getConversationMessages(widget.chatRoomId).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
    showNotification = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarMain(context),
        body: Container(
          child: Stack(
            children: [
              ChatMessageList(),
              Container(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Color(0x54FFFFFF),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextField(
                        controller: messageController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            hintText: "Message...",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none),
                      )),
                      GestureDetector(
                        onTap: () {
                          sendMessage();
                        },
                        child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  const Color(0x35FFFFFF),
                                  const Color(0x35FFFFFF)
                                ]),
                                borderRadius: BorderRadius.circular(40)),
                            padding: EdgeInsets.all(12),
                            child: Image.asset("assets/images/send.png")),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;

  MessageTile(this.message, this.isSendByMe);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: isSendByMe ? 0 : 24, right: isSendByMe ? 24 : 0),
      margin: EdgeInsets.symmetric(vertical: 8),
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: isSendByMe
                    ? [const Color(0xff007EF4), const Color(0xff2A75BC)]
                    : [const Color(0x1AFFFFFF), const Color(0x1AFFFFFF)]),
            borderRadius: isSendByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23))
                : BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23))),
        child: Text(
          message,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
// ignore: must_be_immutable
class NewScreen extends StatelessWidget {
  String payload;

  NewScreen({
    this.payload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(payload),
      ),
    );
  }
}
