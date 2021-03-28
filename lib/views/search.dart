import 'package:flutter/material.dart';
import 'package:chat_application/helper/constants.dart';
import 'package:chat_application/services/database.dart';
import 'package:chat_application/views/conversationscreen.dart';
import 'package:chat_application/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

const iOSLocalizedLabels = false;

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Contact> _contacts;
  List<Contact> contactsFiltered;
  Map<String, Color> contactsColorMap = new Map();
  TextEditingController searchController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getPermissions();
  }

  getPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      getAllContacts();
      searchController.addListener(() {
        filterContacts();
      });
    }
  }

  getAllContacts() async {
    final sContacts = Set<String>();
    List colors = [
      Colors.green,
      Colors.indigo,
      Colors.yellow,
      Colors.orange,
    ];
    int colorIndex = 0;
    // Load without thumbnails initially.
    List<Contact> contacts = (await ContactsService.getContacts(
            withThumbnails: false, iOSLocalizedLabels: iOSLocalizedLabels))
        .toList();

    setState(() {
      _contacts = contacts
          .where((contact) => sContacts.add(contact.displayName))
          .toSet()
          .toList();
    });

    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in _contacts) {
      Color baseColor = colors[colorIndex];
      contactsColorMap[contact.displayName] = baseColor;
      colorIndex++;
      if (colorIndex == colors.length) {
        colorIndex = 0;
      }
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        setState(() => contact.avatar = avatar);
      });
    }
  }

  filterContacts() {
    List<Contact> contacts = [];
    contacts.addAll(_contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact.displayName.toLowerCase();
        bool nameMatches = contactName.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }
        if (searchTermFlatten.isEmpty) {
          return false;
        }
        var phone = contact.phones.firstWhere((phn) {
          String phnFlattened = flattenPhoneNumber(phn.value);
          return phnFlattened.contains(searchTermFlatten);
        }, orElse: () => null);
        return phone != null;
      });
    }
    setState(() {
      contactsFiltered = contacts;
    });
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

//------------------------------------------------------------------------------
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchTextEditingController =
      new TextEditingController();
  QuerySnapshot searchSnapshot;

  /*Widget searchList() {
    return searchSnapshot != null
        ? ListView.builder(
            // ignore: deprecated_member_use
            itemCount: searchSnapshot.documents.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return SearchTile(
                // ignore: deprecated_member_use
                userName: searchSnapshot.documents[index].data()["name"],
                // ignore: deprecated_member_use
                userEmail: searchSnapshot.documents[index].data()["email"],
                // ignore: deprecated_member_use
                userPhone: searchSnapshot.documents[index].data()["phone"],
              );
            })
        : Container();
  }*/

  initiateSearch(BuildContext context) {
    databaseMethods
        .getUserByUsername(searchTextEditingController.text)
        .then((val) {
      setState(() {
        searchSnapshot = val;
      });
    });
  }

  // create chat room, send user to conversation screen,  push replacement
  createChatRoomAndStartConversation({String userName}) {
    if (userName != Constants.myName) {
      String chatRoomId = getChatRoomId(userName, Constants.myName);

      List<String> users = [userName, Constants.myName];
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatroomId": chatRoomId
      };
      DatabaseMethods().createChatRoom(chatRoomId, chatRoomMap);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ConversationScreen(chatRoomId)));
    } else {
      print("You cannot send message to yourself");
    }
  }

  // ignore: non_constant_identifier_names
  Widget SearchTile({String userName, String userEmail, String userPhone}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: mediumTextStyle(),
              ),
              Text(
                userEmail,
                style: mediumTextStyle(),
              ),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              createChatRoomAndStartConversation(userName: userName);
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Message",
                style: mediumTextStyle(),
              ),
            ),
          ),
        ],
      ),
    );
  }

//------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBarMain(context),
      body: Container(
          padding: EdgeInsets.all(20),
          child: Column(children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                  labelText: 'Search',
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(
                          color: Theme.of(context).primaryColor)),
                  prefixIcon: Icon(Icons.search,
                      color: Theme.of(context).primaryColor)),
            ),
            Expanded(
              child: SafeArea(
                child: _contacts != null
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: isSearching == true
                            ? contactsFiltered.length
                            : _contacts.length,
                        itemBuilder: (BuildContext context, int index) {
                          Contact c = isSearching == true
                              ? contactsFiltered[index]
                              : _contacts[index];
                          var baseColor =
                              contactsColorMap[c.displayName] as dynamic;

                          Color color1 = baseColor[800];
                          Color color2 = baseColor[400];
                          return ListTile(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ContactDetailsPage(
                                        c,
                                        onContactDeviceSave:
                                            contactOnDeviceHasBeenUpdated,
                                      )));
                            },
                            leading: (c.avatar != null && c.avatar.length > 0)
                                ? CircleAvatar(
                                    backgroundImage: MemoryImage(c.avatar))
                                : Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                            colors: [
                                              color1,
                                              color2,
                                            ],
                                            begin: Alignment.bottomLeft,
                                            end: Alignment.topRight)),
                                    child: CircleAvatar(
                                        child: Text(c.initials(),
                                            style:
                                                TextStyle(color: Colors.white)),
                                        backgroundColor: Colors.transparent)),
                            title: Text(c.displayName ?? ""),
                          );
                        },
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            )
          ])),
      /*appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: [
            Container(
              color: Color(0x54FFFFFF),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        controller: searchTextEditingController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            hintText: "Search Username",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none),
                      )),
                  GestureDetector(
                    onTap: () {
                      initiateSearch();
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
                        child: Image.asset("assets/images/search_white.png")),
                  )
                ],
              ),
            ),
            searchList()
          ],
        ),
      ),*/
    );
  }

  void contactOnDeviceHasBeenUpdated(Contact contact) {
    this.setState(() {
      var id = _contacts.indexWhere((c) => c.identifier == contact.identifier);
      _contacts[id] = contact;
    });
  }
}

class ContactDetailsPage extends StatelessWidget {
  ContactDetailsPage(this._contact, {this.onContactDeviceSave});

  final Contact _contact;
  final Function(Contact) onContactDeviceSave;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_contact.displayName ?? ""),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: new Text(
                "Name",
                style:
                    new TextStyle(fontWeight: FontWeight.w500, fontSize: 17.0),
              ),
              trailing: Text(_contact.givenName ?? ""),
            ),
            new Divider(
              color: Colors.black87,
            ),
            ListTile(
              title: new Text(
                "Middle Name",
                style:
                    new TextStyle(fontWeight: FontWeight.w500, fontSize: 17.0),
              ),
              trailing: Text(_contact.middleName ?? ""),
            ),
            new Divider(
              color: Colors.black87,
            ),
            ListTile(
              title: new Text(
                "Family Name",
                style:
                    new TextStyle(fontWeight: FontWeight.w500, fontSize: 17.0),
              ),
              trailing: Text(_contact.familyName ?? ""),
            ),
            new Divider(
              color: Colors.black87,
            ),
            ListTile(
              title: new Text(
                "Birthday",
                style:
                    new TextStyle(fontWeight: FontWeight.w500, fontSize: 17.0),
              ),
              /*trailing: Text(_contact.birthday != null
                  ? DateFormat('dd-MM-yyyy').format(_contact.birthday)
                  : ""),*/
            ),
            new Divider(
              color: Colors.black87,
            ),
            ListTile(
              title: new Text(
                "Company",
                style:
                    new TextStyle(fontWeight: FontWeight.w500, fontSize: 17.0),
              ),
              trailing: Text(_contact.company ?? ""),
            ),
            new Divider(
              color: Colors.black87,
            ),
            ListTile(
              title: new Text(
                "Job",
                style:
                    new TextStyle(fontWeight: FontWeight.w500, fontSize: 17.0),
              ),
              trailing: Text(_contact.jobTitle ?? ""),
            ),
            new Divider(
              color: Colors.black87,
            ),
            AddressesTile(_contact.postalAddresses),
            new Divider(
              color: Colors.black87,
            ),
            ItemsTile("Phones", _contact.phones),
            new Divider(
              color: Colors.black87,
            ),
            ItemsTile("Emails", _contact.emails),
            new Divider(
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}

class AddressesTile extends StatelessWidget {
  AddressesTile(this._addresses);

  final Iterable<PostalAddress> _addresses;

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          title: new Text(
            "Addresses",
            style: new TextStyle(fontWeight: FontWeight.w500, fontSize: 17.0),
          ),
        ),
        Column(
          children: _addresses
              .map((a) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text("Street"),
                          trailing: Text(a.street ?? ""),
                        ),
                        new Divider(
                          color: Colors.black87,
                        ),
                        ListTile(
                          title: Text("Postcode"),
                          trailing: Text(a.postcode ?? ""),
                        ),
                        new Divider(
                          color: Colors.black87,
                        ),
                        ListTile(
                          title: Text("City"),
                          trailing: Text(a.city ?? ""),
                        ),
                        new Divider(
                          color: Colors.black87,
                        ),
                        ListTile(
                          title: Text("Region"),
                          trailing: Text(a.region ?? ""),
                        ),
                        new Divider(
                          color: Colors.black87,
                        ),
                        ListTile(
                          title: Text("Country"),
                          trailing: Text(a.country ?? ""),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class ItemsTile extends StatelessWidget {
  ItemsTile(this._title, this._items);

  final Iterable<Item> _items;
  final String _title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
            title: new Text(
          _title,
          style: new TextStyle(fontWeight: FontWeight.w500, fontSize: 17.0),
        )),
        Column(
          children: _items
              .map(
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListTile(
                    title: Text(i.label.toUpperCase() ?? ""),
                    trailing: Text(i.value ?? ""),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}
