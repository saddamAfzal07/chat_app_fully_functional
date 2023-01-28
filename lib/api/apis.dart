import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

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

  //for getting firebase token
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
      }
      log("push token==>> ${t}");
    });
    // for handling foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
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
        //call token
        getFirebaseMessagingToken();
        //for setting user status to active
        updateActiveStatus(true);
        log('My Data: ${value.data()}');
      } else {
        await createNewUser().then((value) => currentUserInfo());
      }
    });
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
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

//Send and Receive messages
//chats(collection)==>conversationId(doc)==>message(collection)==>message(doc)

//useful for getting conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //get All messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllChats(
      ChatUser user) {
    return firestore
        .collection("chats/${getConversationId(user.id.toString())}/messages/")
        .orderBy("sent", descending: true)
        .snapshots();
  }

  //Send Push Notifications
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    print("Enter into push notification");
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };

      var res =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAAWcfORIg:APA91bEHuCTH44kjOQl-qu3HynC1yHBvqVBhY3RgClWFqrdJOHbIoAq0H1CKRHZKZc5bdG3HUOYfVrGTir0azKgraMmlo9REq7iLdNRA7j_xiVUo8FKJKk5X5mqFPEVGuu-gn2q_FZwN'
              },
              body: jsonEncode(body));

      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  //send message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    print("Enter into send messages");
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(
        formId: user.uid,
        msg: msg,
        read: "",
        sent: time,
        toId: chatUser.id,
        type: type);
    final ref = firestore.collection(
        "chats/${getConversationId(chatUser.id.toString())}/messages/");
    await ref.doc(time).set(message.toJson()).then((value) {
      print("Messgage send===>>>>");
      sendPushNotification(chatUser, type == Type.text ? msg : "Image");
    });
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection(
            "chats/${getConversationId(message.formId.toString())}/messages/")
        .doc(message.sent)
        .update({"read": DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //getting last msg of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMsg(ChatUser user) {
    print("Get last msg===>>>");
    return firestore
        .collection("chats/${getConversationId(user.id.toString())}/messages/")
        .orderBy("sent", descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split(".").last;
    final ref = storage.ref().child(
        "Images/${getConversationId(chatUser.id.toString())}${DateTime.now().millisecondsSinceEpoch}}.$ext");
    await ref.putFile(file).then((p0) {
      log("Data transfered");
    });
    final imageUrl = await ref.getDownloadURL();

    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection(
            'chats/${getConversationId(message.toId.toString())}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg.toString()).delete();
    }
  }
}
