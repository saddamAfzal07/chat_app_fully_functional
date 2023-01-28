import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/features/pages/auth/login_screen.dart';
import 'package:chat_app/models/models.dart';
import 'package:chat_app/utils/dialoges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class UserProfile extends StatefulWidget {
  final ChatUser user;
  const UserProfile({super.key, required this.user});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _formkey = GlobalKey<FormState>();
  String? getImage;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        print("unfocus");
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          label: Text("Logout"),
          icon: Icon(
            Icons.logout,
          ),
          onPressed: () async {
            print("Logout");
            await Apis.updateActiveStatus(false);
            Apis.ProgressIndicator(context);
            await Apis.auth.signOut();
            await GoogleSignIn().signOut();
            Navigator.pop(context);

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => LoginScreen(),
              ),
              (route) => false,
            );
            Apis.auth = FirebaseAuth.instance;
          },
        ),
        appBar: AppBar(
          title: Text("Profile Screen"),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formkey,
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
                      Positioned(
                        bottom: -5,
                        right: -10,
                        child: MaterialButton(
                          elevation: 5,
                          color: Colors.blue.shade400,
                          shape: CircleBorder(),
                          onPressed: () {
                            bottomSheet();
                          },
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Text(
                    widget.user.email.toString(),
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  TextFormField(
                    onSaved: (value) => widget.user.name = value ?? "",
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : "Field is required",
                    initialValue: widget.user.name.toString(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "Name",
                      hintText: "Enter Your name",
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                    width: size.width,
                  ),
                  TextFormField(
                    onSaved: (value) => widget.user.about = value ?? "",
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : "Field is required",
                    initialValue: widget.user.about.toString(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: "About",
                      hintText: "About Yourself",
                      prefixIcon: Icon(
                        Icons.info,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      minimumSize: Size(
                        size.width * .5,
                        size.height * .06,
                      ),
                    ),
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        _formkey.currentState!.save();
                        print("enter");
                        Apis.updateUserProfile().then((value) {
                          Dialogues.successDialogue(
                              context, "Updated Successfully");
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserProfile(
                                        user: widget.user,
                                      )));
                        });
                      }
                    },
                    icon: Icon(
                      Icons.edit,
                      size: 28,
                    ),
                    label: Text(
                      "UPDATE",
                      style: TextStyle(
                        fontSize: 18,
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

  void bottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  "Pick Profile Picture",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(200, 100),
                        shape: CircleBorder(),

                        // backgroundColor: Colors.white
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          print(image.path);
                          setState(() {});
                          getImage = image.path;
                          Navigator.pop(context);
                          Apis.updateUserProfileImage(File(getImage!));
                        }
                      },
                      child: Image.asset(
                        "assets/images/gallery.png",
                        height: 50,
                        width: 50,
                      ),
                    ),
                    // SizedBox(width: 50),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(200, 100),
                        shape: CircleBorder(),

                        // backgroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          print(image.path);
                          setState(() {});
                          getImage = image.path;
                          Navigator.pop(context);
                          Apis.updateUserProfileImage(File(getImage!));
                        }
                      },
                      child: Image.asset(
                        "assets/images/camera.png",
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
