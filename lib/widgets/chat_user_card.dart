import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/features/pages/chat_screen/chat_screen.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/date_time.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(user: widget.user),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.blue.shade100,
        elevation: 10,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: Apis.getLastMsg(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            print("snapshot==>>${snapshot.data?.docs}");
            print("data==>>${data}");
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

            print("List ==>${list}");
            if (list.isNotEmpty) {
              print("Enter in to not list null");
              _message = list[0];
            }
            ;
            print("message==>>${_message}");

            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CachedNetworkImage(
                  imageUrl: widget.user.image == ""
                      ? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png"
                      : widget.user.image.toString(),
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              title: Text(widget.user.name.toString()),
              subtitle: _message?.type == Type.image
                  ? Row(
                      children: [
                        Text("Image:"),
                        Icon(
                          Icons.photo,
                          color: Colors.green,
                        ),
                      ],
                    )
                  : Text(
                      _message != null
                          ? _message!.msg.toString()
                          : widget.user.about.toString(),
                    ),
              trailing: _message == null
                  ? null
                  : _message!.read!.isEmpty && _message!.formId != Apis.user.uid
                      ? Container(
                          height: 15,
                          width: 15,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        )
                      : Text(
                          MyDateUtil.getLastMessageTime(
                              context: context,
                              time: _message!.sent.toString()),
                        ),
            );
          },
        ),
      ),
    );
  }
}
