import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/features/pages/auth/login_screen.dart';
import 'package:chat_app/features/pages/user/user_profile.dart';
import 'package:chat_app/models/models.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../utils/dialoges.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatUser> usersList = [];
  List<ChatUser> searchingList = [];
  bool search = false;
  @override
  void initState() {
    super.initState();
    Apis.currentUserInfo();
    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (Apis.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          Apis.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          Apis.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () {
          if (search) {
            setState(() {
              search = !search;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async {},
            child: IconButton(
              onPressed: () async {
                _addChatUserDialog();
                // print("Logout");
                // await Apis.auth.signOut();
                // // await GoogleSignIn().signOut();
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(
                //     builder: (BuildContext context) => LoginScreen(),
                //   ),
                //   (route) => false,
                // );
              },
              icon: Icon(
                Icons.add_comment,
              ),
            ),
          ),
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {},
              icon: Icon(
                CupertinoIcons.home,
              ),
            ),
            title: search
                ? TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search email",
                    ),
                    autofocus: true,
                    onChanged: (value) {
                      searchingList.clear();
                      for (var i in usersList) {
                        if (i.name!.toLowerCase().contains(value) ||
                            i.email!.toLowerCase().contains(value)) {
                          searchingList.add(i);
                          setState(() {});
                        }
                      }
                    },
                  )
                : Text(
                    "Chit Chat",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  print("call search");
                  search = !search;
                  setState(() {});
                },
                icon: Icon(
                  search
                      ? CupertinoIcons.clear_circled_solid
                      : CupertinoIcons.search,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          UserProfile(user: Apis.me),
                    ),
                  );
                },
                icon: Icon(Icons.more_vert),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      //get id of only known users
                      stream: Apis.getMyUsers(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {

                          //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return Center(child: CircularProgressIndicator());
                          //if some and all data loaded
                          case ConnectionState.active:
                          case ConnectionState.done:
                            return StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                              stream: Apis.getAllUsers(snapshot.data!.docs
                                      .map((e) => e.id)
                                      .toList() ??
                                  []),
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  //if data is loading
                                  case ConnectionState.waiting:
                                  case ConnectionState.none:
                                    return Center(
                                        child: CircularProgressIndicator());
                                  //if some and all data loaded
                                  case ConnectionState.active:
                                  case ConnectionState.done:
                                    final data = snapshot.data!.docs;
                                    usersList = data
                                        .map((e) => ChatUser.fromJson(e.data()))
                                        .toList();

                                    if (usersList.isNotEmpty) {
                                      return ListView.builder(
                                        itemCount: search
                                            ? searchingList.length
                                            : usersList.length,
                                        itemBuilder: (context, index) {
                                          return ChatUserCard(
                                            user: search
                                                ? searchingList[index]
                                                : usersList[index],
                                          );
                                        },
                                      );
                                    } else {
                                      return Center(
                                          child: Text("No User Found"));
                                    }
                                }
                              },
                            );
                        }
                      })),
            ],
          ),
        ),
      ),
    );
  }

  //dialog for Add user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        //title
        title: Row(
          children: const [
            Icon(
              Icons.person_add,
              color: Colors.blue,
              size: 28,
            ),
            Text('  Add USER')
          ],
        ),

        //content
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => email = value,
          decoration: InputDecoration(
              hintText: "Email Id",
              prefixIcon: Icon(
                Icons.email,
                color: Colors.blue,
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
        ),

        //actions
        actions: [
          //cancel button
          MaterialButton(
              onPressed: () {
                //hide alert dialog
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              )),

          //update button
          MaterialButton(
              onPressed: () async {
                if (email.isNotEmpty) {
                  await Apis.addChatUser(email).then((value) {
                    Navigator.pop(context);
                    if (!value) {
                      Dialogues.errorDialogue(context, "User Not Exist");
                    }
                  });
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ))
        ],
      ),
    );
  }
}
