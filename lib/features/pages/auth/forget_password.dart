import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final _formkey = GlobalKey<FormState>();
  var emailcontroller = TextEditingController();

  Future resetPassword() async {
    print("check");
    try {
      print("try");
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailcontroller.text);
      print(emailcontroller.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Password sent to that email"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
    } on FirebaseAuthException catch (e) {
      print("exception===>");
      print(e);
      print("No user found for taht email");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("No user found for that email"),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailcontroller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Forgot Screen'),
        centerTitle: true,
        backgroundColor: Color(0xff3c83f1),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Form(
            key: _formkey,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    // height: MediaQuery.of(context).size.height * 0.4,
                    // width: MediaQuery.of(context).size.width,
                    child: Image.asset("assets/images/emailsent.png"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: emailcontroller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.black),
                      prefixIcon: Icon(Icons.email),
                    ),
                    // onChanged: (String value) {
                    //   email = value;
                    // },
                    validator:
                        RequiredValidator(errorText: "Email is required"),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        primary: Colors.white,
                        backgroundColor: Color(0xFF4167b2),
                      ),
                      onPressed: () async {
                        if (_formkey.currentState!.validate()) {
                          resetPassword();
                        }
                      },
                      child: Text(
                        "Reset Password",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
