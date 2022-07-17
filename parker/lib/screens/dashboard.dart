import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parker/components/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parker/services/api_call.dart';
import 'package:parker/screens/intro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);
  static String id = 'DashBoard';

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  String fullName = '';
  String apiResponse = '';

  // Future sendApiResponse() async {
  //   var apiData = await ApiCall().sendApiData('${_auth.currentUser?.uid}');
  //   if (kDebugMode) {
  //     print(apiData);
  //   }
  // }

  Future getApiResponse() async {
    String apiData = await ApiCall().getApiData('${_auth.currentUser?.uid}');
    setState(() {
      apiResponse = apiData;
    });
  }

  Future<void> printUID() async {
    if (kDebugMode) {
      print(_auth.currentUser?.uid);
    }
  }

  void getUserName() async {
    dynamic dataName =
        await _fireStore.collection('users').doc(_auth.currentUser?.uid).get();
    setState(() {
      fullName = dataName['fName'] + ' ' + dataName['lName'];
    });
  }

  @override
  Widget build(BuildContext context) {
    getUserName();
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                        const Text(
                          'Parker',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PopupMenuButton(
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.black54,
                            ),
                            onSelected: (index) async {
                              if (index == 3) {
                                await _auth.signOut().whenComplete(() =>
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, Intro.id, (route) => false));
                              }
                            },
                            itemBuilder: (context) => <PopupMenuEntry>[
                                  const PopupMenuItem(
                                    value: 0,
                                    child: Text('History'),
                                  ),
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
                    Text(
                      "Hey, $fullName.",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 30.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: h * 0.25,
              left: w * 0.2,
              child: QrImage(
                data: _auth.currentUser!.uid,
                size: w * 0.6,
                errorStateBuilder: (cxt, err) {
                  return const Center(
                    child: Text(
                      "Uh oh! Something went wrong...",
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              width: w * 0.8,
              height: h * 0.15,
              bottom: h * 0.65,
              left: w * 0.06,
              child: Text(
                '$apiResponse ',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 20.0,
                ),
              ),
            ),
            Positioned(
              width: w * 0.8,
              height: h * 0.05,
              bottom: h * 0.12,
              left: w * 0.1,
              child: CustomButton(
                title: 'API Call',
                textSize: 15.0,
                buttonFunction: () async {
                  await getApiResponse();
                },
              ),
            ),
            Positioned(
              width: w * 0.8,
              height: h * 0.05,
              bottom: h * 0.05,
              left: w * 0.1,
              child: CustomButton(
                title: 'Generate QRCode',
                textSize: 15.0,
                buttonFunction: () {
                  printUID();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
