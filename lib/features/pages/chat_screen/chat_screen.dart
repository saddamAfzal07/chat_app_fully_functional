import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/models.dart';
import 'package:chat_app/utils/date_time.dart';
import 'package:chat_app/widgets/message_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import '../../../users_profile_info/users_profile_info.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for storing all messages
  List<Message> userChatList = [];
  //for emoji
  bool showEmoji = false;
  //for check if image is uploaded or not
  bool _isUploading = false;

  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (showEmoji) {
          setState(() {
            showEmoji = !showEmoji;
          });
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Color.fromARGB(255, 179, 212, 240),
            appBar: AppBar(
              backgroundColor: Colors.blue.shade100,
              toolbarHeight: 65,
              elevation: 2,
              automaticallyImplyLeading: false,
              flexibleSpace: _appbar(),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: Apis.getAllChats(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          //if data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return Center(child: SizedBox());
                          //if some and all data loaded
                          case ConnectionState.active:
                          case ConnectionState.done:
                            // final data = snapshot.data?.docs;
                            // print(snapshot.data!.docs.first);
                            // userChatList
                            //     .map((e) => Message.fromJson(e.data()))
                            //     .toList();
                            final data = snapshot.data!.docs;
                            userChatList = data
                                .map((e) => Message.fromJson(e.data()))
                                .toList();

                            // print(userChatList);

                            if (userChatList.isNotEmpty) {
                              return ListView.builder(
                                reverse: true,
                                itemCount: userChatList.length,
                                itemBuilder: (context, index) {
                                  return MessageCard(
                                    msg: userChatList[index],
                                  );
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
                  if (_isUploading)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 40,
                      ),
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                          )),
                    ),
                  _textField(),
                  if (showEmoji)
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.6,
                      child: EmojiPicker(
                        textEditingController: _textController,
                        config: Config(
                          columns: 8,
                          emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
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
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        showEmoji = !showEmoji;
                      });
                    },
                    icon: Icon(
                      Icons.emoji_emotions,
                      color: Colors.blue,
                      size: 26,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      onTap: () {
                        if (showEmoji)
                          setState(() {
                            showEmoji = !showEmoji;
                          });
                      },
                      controller: _textController,
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
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image
                      final List<XFile> imagesList =
                          await picker.pickMultiImage(imageQuality: 80);
                      //pick multiple images

                      for (var i in imagesList) {
                        setState(() {
                          _isUploading = true;
                        });
                        Apis.sendChatImage(widget.user, File(i.path));
                        setState(() {
                          _isUploading = false;
                        });
                      }
                    },
                    icon: Icon(
                      Icons.photo,
                      color: Colors.blue,
                      size: 26,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 80);
                      if (image != null) {
                        print(image.path);
                        setState(() {
                          _isUploading = true;
                        });

                        Apis.sendChatImage(widget.user, File(image.path));
                        setState(() {
                          _isUploading = false;
                        });
                      }
                    },
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
        SizedBox(width: 5),
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
          onPressed: () {
            if (_textController.text.isNotEmpty) {
              if (userChatList.isEmpty) {
                Apis.sendFirstMessage(
                    widget.user, _textController.text, Type.text);
                _textController.clear();
              } else {
                Apis.sendMessage(widget.user, _textController.text, Type.text);
                _textController.clear();
              }
            }
          },
          child: Icon(
            Icons.send,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _appbar() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: Apis.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;

          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UsersProfileScreen(
                    user: widget.user,
                  ),
                ),
              );
            },
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
              list.isNotEmpty
                  ? list[0].isOnline!
                      ? "Online"
                      : MyDateUtil.getLastActiveTime(
                          context: context,
                          lastActive: list[0].lastActive.toString(),
                        )
                  : MyDateUtil.getLastActiveTime(
                      context: context,
                      lastActive: widget.user.lastActive.toString(),
                    ),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          );
        });
  }
}
