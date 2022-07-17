import 'package:flutter/material.dart';
import 'package:parker/components/custom_button.dart';
import 'package:parker/components/custom_text_field.dart';
import 'sign_in.dart';
import 'user_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parker/constants.dart';

class SignUp extends StatefulWidget {
  /// sing up screen
  /// this provides sign up with email and password

  const SignUp({Key? key}) : super(key: key);
  static String id = 'SignUp';

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // firebase instance for sign up
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // firebase cloud store instance for table 'users'
  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');
  // form label for widget tree
  final _formKey = GlobalKey<FormState>();

  // field controller for first name
  TextEditingController fNameController = TextEditingController();
  // field controller for last name
  TextEditingController lNameController = TextEditingController();
  // field controller for email
  TextEditingController emailController = TextEditingController();
  // field controller for password
  TextEditingController passwordController = TextEditingController();
  // field controller for confirm password
  TextEditingController passwordConfirmController = TextEditingController();
  // confirm password visibility toggle
  bool isObscureConfirm = true;
  // password visibility toggle
  bool isObscure = true;

  Future<void> addUser(CollectionReference users) async {
    /// add user information into firebase cloud store

    if (_auth.currentUser?.uid != null) {
      return await users
          .doc(_auth.currentUser?.uid)
          .set({
            'fName': fNameController.text,
            'lName': lNameController.text,
            'email': emailController.text,
            'password': passwordController.text,
            'cardNumber': ' ',
            'cvv': '000',
            'expMonth': 01,
            'expYear': 26,
            'entered': false,
            'entryTime': DateTime.now().millisecondsSinceEpoch,
          })
          .then((value) => print("User Added"))
          .catchError(
              (error) => print("Failed to add user: $error")); //add error case
    }
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height; // height of screen
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Form(
              key: _formKey, // form label
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: h * 0.1,
                  ),
                  const Text(
                    'Hello!',
                    textAlign: TextAlign.center,
                    style: kHeaderTextStyle,
                  ),
                  SizedBox(
                    height: h * 0.01,
                  ),
                  const Text(
                    'Signup to get started',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kDarkTextColor,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(
                    height: h * 0.05,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          hintText: 'FName',
                          rightPadding: 5.0,
                          textFieldInput: TextInputType.name,
                          textController: fNameController,
                          customValidator: (value) {
                            if (value == null || value.isEmpty) {
                              // empty field
                              return 'Enter First Name';
                            }
                            return null;
                          },
                        ),
                      ),
                      Expanded(
                        child: CustomTextField(
                          hintText: 'LName',
                          leftPadding: 5.0,
                          textFieldInput: TextInputType.name,
                          textController: lNameController,
                          customValidator: (value) {
                            if (value == null || value.isEmpty) {
                              // empty field
                              return 'Enter Last Name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: h * 0.02,
                  ),
                  CustomTextField(
                    hintText: 'Enter email',
                    textFieldInput: TextInputType.emailAddress,
                    textController: emailController,
                    customValidator: (value) {
                      if (value == null || value.isEmpty) {
                        // empty field
                        return 'Enter Email Address';
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
                        // empty field
                        return 'Please enter password';
                      }
                      if (value.toString().length <= 6) {
                        // password length <= 6
                        return 'Password is to week';
                      }
                      return null;
                    },
                    iconButton: IconButton(
                      padding: const EdgeInsets.only(right: 15.0),
                      onPressed: () {
                        // visibility toggle
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
                    height: h * 0.02,
                  ),
                  CustomTextField(
                    obscureText: isObscureConfirm,
                    customValidator: (value) {
                      if (value == null || value.isEmpty) {
                        // empty field
                        return 'Please enter password';
                      }
                      if (value.toString().length <= 6) {
                        // password length <= 6
                        return 'Password is to week';
                      }
                      if (value.toString() != passwordController.text) {
                        // password
                        return 'Password do not match';
                      }

                      return null;
                    },
                    iconButton: IconButton(
                      padding: const EdgeInsets.only(right: 15.0),
                      onPressed: () {
                        // toggle visibility
                        setState(() {
                          isObscureConfirm = !isObscureConfirm;
                        });
                      },
                      icon: Icon(isObscureConfirm
                          ? Icons.visibility
                          : Icons.visibility_off),
                      color: kDarkColor,
                    ),
                    hintText: 'Confirm Password',
                    textFieldInput: TextInputType.visiblePassword,
                    textController: passwordConfirmController,
                  ),
                  SizedBox(
                    height: h * 0.04,
                  ),
                  CustomButton(
                    buttonHeight: h * 0.06,
                    title: 'Sign Up',
                    textSize: 17.0,
                    buttonFunction: () async {
                      // firebase sign up functionality
                      try {
                        if (_formKey.currentState!.validate()) {
                          await _auth
                              .createUserWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text)
                              .whenComplete(
                                () => addUser(_users),
                              );
                          // user sing up then redirect to user_home screen
                          Navigator.restorablePushNamedAndRemoveUntil(
                              context, UserHome.id, (route) => false);
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
                        'Already have an Account?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kDarkTextColor,
                          fontSize: 15.0,
                          fontFamily: "Horizon",
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.popAndPushNamed(context, SignIn.id);
                        },
                        child: const Text(
                          'Sign In    ',
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
}
