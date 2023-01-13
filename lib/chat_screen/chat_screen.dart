import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 65,
          elevation: 2,
          automaticallyImplyLeading: false,
          flexibleSpace: _appbar(),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: Apis.getAllChats(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    //if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                    // return Center(child: CircularProgressIndicator());
                    //if some and all data loaded
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final List userChatList = ["hi", "hello"];
                      final data = snapshot.data?.docs;
                      print(jsonEncode(data?[0].data()));
                      if (userChatList.isNotEmpty) {
                        return ListView.builder(
                          itemCount: userChatList.length,
                          itemBuilder: (context, index) {
                            return Text(userChatList[index]);
                          },
                        );
                      } else {
                        return Center(
                            child: Text(
                          "Say Hi..👋",
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ));
                      }
                  }
                },
              ),
            ),
            _textField(),
          ],
        ),
      ),
    );
  }

  Widget _textField() {
    return Row(
      children: [
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.emoji_emotions,
                      color: Colors.blue,
                      size: 26,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type something...",
                        hintStyle: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.photo,
                      color: Colors.blue,
                      size: 26,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.blue,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        MaterialButton(
          minWidth: 0,
          elevation: 5,
          padding: EdgeInsets.only(
            left: 15,
            right: 10,
            top: 10,
            bottom: 10,
          ),
          color: Colors.green,
          shape: CircleBorder(),
          onPressed: () {},
          child: Icon(
            Icons.send,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _appbar() {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: CachedNetworkImage(
          height: 50,
          width: 50,
          imageUrl: widget.user.image == ""
              ? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png"
              : widget.user.image.toString(),
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
      title: Text(
        widget.user.name.toString(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        "not available",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
