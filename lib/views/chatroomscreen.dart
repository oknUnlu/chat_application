import 'package:chat_application/Encryption/encodingDecoding.dart';
import 'package:chat_application/helper/authenticate.dart';
import 'package:chat_application/helper/constants.dart';
import 'package:chat_application/helper/helperFunctions.dart';
//import 'package:chat_application/helper/registerNotification.dart';
import 'package:chat_application/services/auth.dart';
import 'package:chat_application/services/database.dart';
import 'package:chat_application/views/conversationScreen.dart';
import 'package:chat_application/views/search.dart';
import 'package:chat_application/widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  List<String> roomList = [
    'New Group',
    'Mark all read',
    'Invite friends',
    'Settings',
    'SignOut'
  ];
  Stream chatRoomStream;
  String checkNo;
  //Notifications notifications = new Notifications();

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  /*snapshot.data.documents[index].data()['lastMessage']['read'] ? checkNo = '':
                  notifications.push('New Message', EncodingDecodingService.decryptAndDecode(snapshot.data.documents[index].data()['lastMessage']['content']));*/
                  return ChatRoomTile(
                    snapshot.data.docs[index]['contactUsers'],
                    snapshot.data.docs[index]['chatRoomId'],
                    snapshot.data.docs[index]['lastMessage'],
                  );
                })
            : Container();
      },
    );
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    Constants.userName = (await HelperFunction.getUserNameSharedPreference());
    Constants.myPhoneNumber =
        (await HelperFunction.getUserPhoneSharedPreference());
    Constants.countryCode =
        (await HelperFunction.getUserCountrySharedPreference());

    //registerNotification(Constants.myPhoneNumber);
    databaseMethods.getChatRooms(Constants.myPhoneNumber).then((value) {
      setState(() {
        chatRoomStream = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
            child: Column(
              children: [
                // Container(
                //   height: 40,
                //   width: 40,
                //   decoration: BoxDecoration(
                //       color: Colors.blue,
                //       borderRadius: BorderRadius.circular(40)),
                //   child:
                //   Text("${Constants.userName.substring(0, 1).toUpperCase()}"),
                // ),
                // Text('O', textAlign: TextAlign.left),
                Image.asset(
                  "assets/images/logo.png",
                  height: 40,
                )
              ],
        ))),
        actions: [
          GestureDetector(
            onTap: () {
              //Searching
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Icon(Icons.search)),
          ),
          Container(
              width: 50.0,
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                isExpanded: true,
                icon: Icon(
                  Icons.more_vert_outlined,
                  color: Colors.white,
                  size: 30,
                ),
                style: TextStyle(color: Colors.black),
                onChanged: (String newValue) {
                  setState(() {
                    switch (newValue) {
                      case 'New Group':
                      case 'Mark all read':
                      case 'Invite friends':
                      case 'Settings':
                      case 'Sign Out':
                        authMethods.signOut();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Authenticate()));
                    }
                  });
                },
                items: roomList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
              )))
        ],
      ),
      body: chatRoomList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SearchScreen()));
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class ChatRoomTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;
  final Map<String, dynamic> lastMessage;

  ChatRoomTile(this.userName, this.chatRoomId, this.lastMessage);

  DatabaseMethods databaseMethods = new DatabaseMethods();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          databaseMethods.updateLastMessage(chatRoomId, lastMessage['content'],
              lastMessage['timestamp'], true);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ConversationScreen(chatRoomId)));
        },
        child: Container(
          color: Colors.black,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(40)),
                          child:
                              Text("${userName.substring(0, 1).toUpperCase()}"),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: mediumTextStyle(),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
                                  child: Text(
                                    (lastMessage['content'] != null && lastMessage['content'] != ''
                                        ? EncodingDecodingService.decryptAndDecode(lastMessage['content'])
                                        : 'No Message'),
                                    style: smallTextStyle(),
                                    overflow: TextOverflow.ellipsis,
                                  ))
                            ])
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        lastMessage['timestamp'].toString() != null &&
                                lastMessage['timestamp'] != ''
                            ? Text(getTime(lastMessage['timestamp'].toString()),
                                style: smallTextStyle())
                            : Text('No Time'),
                        SizedBox(height: 7.0),
                        lastMessage['content'] != ''
                            ? lastMessage['read']
                                ? Text('')
                                : Container(
                                    width: 40.0,
                                    height: 20.0,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(30.0)),
                                    alignment: Alignment.center,
                                    child: Text("NEW",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.bold)))
                            : Text(''),
                      ],
                    )
                  ])),
        ));
  }

  String getTime(String timestamp) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    DateFormat format;
    if (dateTime.difference(DateTime.now()).inMilliseconds <= 86400000) {
      format = DateFormat('jm');
    } else {
      format = DateFormat.yMd('en_US');
    }
    return format
        .format(DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp)));
  }
}
