import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Apis {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;
  static void ProgressIndicator(context) async {
    return showDialog(
        context: context,
        builder: (_) => Center(
              child: CircularProgressIndicator(),
            ));
  }

  //Check if user exists or not
  static Future<bool> userExists() async {
    return (await firestore
            .collection("users")
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  //for create new user
  static Future<void> createNewUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        id: user.uid,
        about: "hello ",
        email: user.email,
        name: user.displayName ?? "Haris Rauf",
        createdAt: time,
        image: user.photoURL ??
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTegQdwQ7gAPaO0avqMOsUv7Ucqjrt5U9P1Vsac_rE&s",
        isOnline: false,
        lastActive: time,
        pushToken: "");
    return await firestore
        .collection("users")
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  //Getting all users details
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection("users")
        .where(
          "id",
          isNotEqualTo: user.uid,
        )
        .snapshots();
  }

  static late ChatUser me;
  //Getting current user info
  static Future<void> currentUserInfo() async {
    await firestore.collection("users").doc(user.uid).get().then((value) async {
      if (value.exists) {
        me = ChatUser.fromJson(value.data()!);
      } else {
        await createNewUser().then((value) => currentUserInfo());
      }
    });
  }

  //update user data
  static Future<void> updateUserProfile() async {
    await firestore.collection("users").doc(user.uid).update({
      "name": me.name,
      "about": me.about,
    });
  }

//updateUser profile Image
  static Future<void> updateUserProfileImage(File file) async {
    final ext = file.path.split(".").last;
    final ref = storage.ref().child("profileImage/${user.uid}.$ext");
    await ref.putFile(file).then((p0) {
      log("Data transfered");
    });
    me.image = await ref.getDownloadURL();

    await firestore.collection("users").doc(user.uid).update({
      "image": me.image,
    });
  }

  //get chat model
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllChats() {
    return firestore.collection("messages").snapshots();
  }
}
