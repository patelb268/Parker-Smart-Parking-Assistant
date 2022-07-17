import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'sign_in.dart';
import 'sign_up.dart';
import 'package:parker/constants.dart';

class Intro extends StatefulWidget {
  /// Introduction screen for app
  /// this provides welcome msg and button for signIn and signUp

  const Intro({Key? key}) : super(key: key);
  static String id = '/Intro'; // for navigation between screen

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width; // width of screen
    double h = MediaQuery.of(context).size.height; // height of screen
    DateTime _lastExitTime = DateTime.now(); // current date and time
    return WillPopScope(
      onWillPop: () async {
        if (DateTime.now().difference(_lastExitTime) >=
            const Duration(seconds: 2)) {
          Fluttertoast.showToast(
              msg: "Press the back button again to exist the app",
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: kToastBackColor,
              timeInSecForIosWeb: 1,
              textColor: Colors.black54,
              fontSize: 16.0);
          _lastExitTime = DateTime.now();
          return false; // disable back press
        } else {
          return true; //  exit the app
        }
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false, // avoid onscreen keyboard
          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: h * 0.0,
                left: w * 0.0,
                child: Container(
                  height: h * 0.1,
                  width: w,
                  color: Colors.white,
                ),
              ),
              Positioned(
                top: h * 0.04,
                left: w * 0.0,
                child: SizedBox(
                  height: h * 0.12,
                  width: w,
                  child: Container(
                    color: Colors.white,
                    child: Image.asset('assets/images/logo_full.png'),
                  ),
                ),
              ),
              Positioned(
                top: h * 0.15,
                left: w * -0.01,
                child: SizedBox(
                  height: h * 0.36,
                  child: ClipRRect(
                    borderRadius: kIntroImageBorderRadius,
                    child: Image.asset('assets/images/intro_image.jpg'),
                  ),
                ),
              ),
              Positioned(
                top: h * 0.48,
                left: 30.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: h * 0.1,
                      ),
                      const Text(
                        "Pick Your\nPerfect Parking",
                        textAlign: TextAlign.center,
                        style: kHeaderTextStyle,
                      ),
                      SizedBox(
                        height: h * 0.08,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RawMaterialButton(
                            onPressed: () {
                              // redirect to sign_in screen
                              Navigator.pushNamed(context, SignIn.id);
                            },
                            child: Container(
                              height: 60.0,
                              width: 150.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.only(
                                  //Radius.circular(15.0),
                                  topLeft: Radius.circular(15.0),
                                  topRight: Radius.zero,
                                  bottomLeft: Radius.circular(15.0),
                                  bottomRight: Radius.zero,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Sign In',
                                  style: kIntroButtonTextStyle,
                                ),
                              ),
                            ),
                          ),
                          RawMaterialButton(
                            onPressed: () {
                              // redirect to sign_up screen
                              Navigator.pushNamed(context, SignUp.id);
                            },
                            child: Container(
                              height: 60.0,
                              width: 150.0,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.zero,
                                  topRight: Radius.circular(15.0),
                                  bottomLeft: Radius.zero,
                                  bottomRight: Radius.circular(15.0),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Sign Up',
                                  style: kIntroButtonTextStyle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
