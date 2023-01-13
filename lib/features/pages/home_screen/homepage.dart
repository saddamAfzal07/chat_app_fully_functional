import 'dart:convert';

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/features/pages/auth/login_screen.dart';
import 'package:chat_app/features/pages/splash_screen/splash_screen.dart';
import 'package:chat_app/features/user/user_profile.dart';
import 'package:chat_app/models/models.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../chat_screen/chat_screen.dart';

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
                print("Logout");
                await Apis.auth.signOut();
                // await GoogleSignIn().signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => LoginScreen(),
                  ),
                  (route) => false,
                );
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
                child: StreamBuilder(
                  stream: Apis.getAllUsers(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      //if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Center(child: CircularProgressIndicator());
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
                          return Center(child: Text("No User Found"));
                        }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
