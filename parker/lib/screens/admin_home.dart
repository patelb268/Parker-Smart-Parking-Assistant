import 'package:flutter/material.dart';
import 'package:parker/components/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parker/constants.dart';
import 'package:parker/screens/intro.dart';
import 'qr_scanner.dart';

class AdminHome extends StatefulWidget {
  /// admin home screen
  /// this provides scanner for entry and exit as well as logout

  const AdminHome({Key? key}) : super(key: key);
  static String id = 'AdminHome'; // navigation

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  // firebase authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width; // width of screen
    double h = MediaQuery.of(context).size.height; // height of screen
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false, // avoid on screen keyboard
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              height: h * 0.5,
              decoration: const BoxDecoration(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: h * 0.02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: h * 0.055,
                          width: w * 0.31,
                          child: Image.asset('assets/images/logo_full.png'),
                        ),
                        PopupMenuButton(
                            icon: const Icon(
                              Icons.menu,
                              color: kDarkTextColor,
                            ),
                            onSelected: (index) async {
                              // sign out and go to intro screen
                              if (index == 3) {
                                await _auth.signOut().whenComplete(() =>
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, Intro.id, (route) => false));
                              }
                            },
                            itemBuilder: (context) => <PopupMenuEntry>[
                                  const PopupMenuItem(
                                    value: 1,
                                    child: Text('Account'),
                                  ),
                                  const PopupMenuItem(
                                    value: 2,
                                    child: Text('Setting'),
                                  ),
                                  const PopupMenuItem(
                                    value: 3,
                                    child: Text('Log out'),
                                  ),
                                ]),
                      ],
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Hello, Admin.",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: kDarkTextColor,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: h * 0.3,
              left: w * -0.05,
              child: SizedBox(
                width: w * 1.08,
                child: Image.asset(
                  'assets/images/home_image.jpg',
                  color: const Color.fromRGBO(255, 255, 255, 0.25),
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
            ),
            Positioned(
              width: w * 0.8,
              height: h * 0.05,
              bottom: h * 0.12,
              left: w * 0.1,
              child: CustomButton(
                title: 'Entry QRScanner',
                textSize: 15.0,
                buttonFunction: () {
                  // Scanner button for entry
                  QrScanner.userStatus = 'entry';
                  Navigator.pushNamed(context, QrScanner.id);
                },
              ),
            ),
            Positioned(
              width: w * 0.8,
              height: h * 0.05,
              bottom: h * 0.05,
              left: w * 0.1,
              child: CustomButton(
                title: 'Exit QRScanner',
                textSize: 15.0,
                buttonFunction: () {
                  // scanner button for exit
                  QrScanner.userStatus = 'exit';
                  Navigator.pushNamed(
                    context,
                    QrScanner.id,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
