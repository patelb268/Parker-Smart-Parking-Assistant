import 'package:flutter/material.dart';
import 'package:parker/components/custom_text_field.dart';
import 'package:parker/components/custom_button.dart';
import 'package:parker/constants.dart';
import 'sign_up.dart';
import 'user_home.dart';
import 'admin_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignIn extends StatefulWidget {
  /// Sign In screen
  /// this provides sign in functionality with email and password.

  const SignIn({Key? key}) : super(key: key);
  static String id = 'SignIn'; // for navigation between screen

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // firebase authentication instance for sign in
  final _auth = FirebaseAuth.instance;
  // form label for widget tree
  final _formKey = GlobalKey<FormState>();

  // controller for email text field
  TextEditingController emailController = TextEditingController();
  // controller for password text field
  TextEditingController passwordController = TextEditingController();
  bool isObscure = true; // password visibility toggle

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height; // height of screen
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: h * 0.1,
                  ),
                  const Text(
                    'Hello Again!',
                    textAlign: TextAlign.center,
                    style: kHeaderTextStyle,
                  ),
                  SizedBox(
                    height: h * 0.02,
                  ),
                  const Text(
                    'Welcome back you\'ve\nbeen missed!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kDarkTextColor,
                      fontSize: 20.0,
                      fontFamily: "Horizon",
                    ),
                  ),
                  SizedBox(
                    height: h * 0.05,
                  ),
                  CustomTextField(
                    hintText: 'Enter email',
                    textFieldInput: TextInputType.emailAddress,
                    textController: emailController,
                    customValidator: (value) {
                      // text field validator
                      if (value == null || value.isEmpty) {
                        // for empty field
                        return 'Please enter Email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: h * 0.02,
                  ),
                  CustomTextField(
                    obscureText: isObscure,
                    customValidator: (value) {
                      if (value == null || value.isEmpty) {
                        // for empty field
                        return 'Please enter password';
                      }
                      return null;
                    },
                    iconButton: IconButton(
                      padding: const EdgeInsets.only(right: 15.0),
                      onPressed: () {
                        // password visibility toggle
                        setState(() {
                          isObscure = !isObscure;
                        });
                      },
                      icon: Icon(
                          isObscure ? Icons.visibility : Icons.visibility_off),
                      color: kDarkColor,
                    ),
                    hintText: 'Password',
                    textFieldInput: TextInputType.visiblePassword,
                    textController: passwordController,
                  ),
                  SizedBox(
                    height: h * 0.1,
                  ),
                  CustomButton(
                    buttonHeight: h * 0.06,
                    title: 'Sign In',
                    textSize: 17.0,
                    buttonFunction: () async {
                      // firebase sign in function
                      try {
                        if (_formKey.currentState!.validate()) {
                          await _auth.signInWithEmailAndPassword(
                              email: emailController.text.trim(),
                              password: passwordController.text);
                          if (emailController.text.trim() == 'admin@nexus.co' &&
                              passwordController.text == 'admin123') {
                            // for admin sign in
                            Navigator.pushNamedAndRemoveUntil(
                                context, AdminHome.id, (route) => false);
                          } else {
                            // for user sign in
                            Navigator.pushNamedAndRemoveUntil(
                                context, UserHome.id, (route) => false);
                          }
                        }
                      } on FirebaseAuthException catch (e) {
                        // error msg
                        Fluttertoast.showToast(
                          msg: e.message.toString(),
                          toastLength: Toast.LENGTH_SHORT,
                          timeInSecForIosWeb: 1,
                          backgroundColor: kToastBackColor,
                          textColor: kDarkTextColor,
                          fontSize: 16.0,
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: h * 0.01,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Not a member?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kDarkTextColor,
                          fontSize: 15.0,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.popAndPushNamed(context, SignUp.id);
                        },
                        child: const Text(
                          'Register Now',
                          style: TextStyle(color: kDarkColor),
                        ),
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(horizontal: 3.0)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
