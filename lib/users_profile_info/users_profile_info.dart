import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/features/pages/auth/login_screen.dart';
import 'package:chat_app/models/models.dart';
import 'package:chat_app/utils/date_time.dart';
import 'package:chat_app/utils/dialoges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

//Different users profile screens
class UsersProfileScreen extends StatefulWidget {
  final ChatUser user;
  const UsersProfileScreen({super.key, required this.user});

  @override
  State<UsersProfileScreen> createState() => _UsersProfileScreenState();
}

class _UsersProfileScreenState extends State<UsersProfileScreen> {
  String? getImage;
  @override
  Widget build(BuildContext context) {
    // final date = DateTime.fromMillisecondsSinceEpoch(
    //     int.parse(widget.user.createdAt.toString()),
    //     isUtc: true);

    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        print("unfocus");
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Joined on: ",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              MyDateUtil.getLastMessageTime(
                context: context,
                time: widget.user.createdAt.toString(),
                showYear: true,
              ),
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        appBar: AppBar(
          title: Text("Profile Screen"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.03,
                  width: size.width,
                ),
                Stack(
                  children: [
                    getImage != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(size.height * .25),
                            child: Image.file(
                                height: size.height * .22,
                                width: size.width * .35,
                                fit: BoxFit.fill,
                                File(getImage!)),
                          )
                        : ClipRRect(
                            borderRadius:
                                BorderRadius.circular(size.height * .25),
                            child: CachedNetworkImage(
                              height: 150,
                              width: 150,
                              fit: BoxFit.fill,
                              imageUrl: widget.user.image == ""
                                  ? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png"
                                  : widget.user.image.toString(),
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Text(
                  widget.user.email.toString(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Text(
                  widget.user.about.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
