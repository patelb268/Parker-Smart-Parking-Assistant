import 'package:flutter/material.dart';
import 'package:parker/components/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parker/constants.dart';
import 'package:parker/services/api_call.dart';
import 'package:parker/screens/intro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserHome extends StatefulWidget {
  /// user home screen
  /// this provides qrcode generator and logout for user

  const UserHome({Key? key}) : super(key: key);
  static String id = 'DashBoard';

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome>
    with SingleTickerProviderStateMixin {
  // firebase authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // firebase database instance
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  String fullName = '';
  String userMessage = '';
  String userParkingNumber = '';
  String userParkingPath = '';
  String userTotalPay = '';
  List<String> apiResponse = [' ', ' '];

  // for qr code animation
  late AnimationController animController;
  late Animation offset;

  void getAnimValue() {
    /// for QR code Animation

    animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
    );
    offset = Tween(begin: 1.0, end: 0.45).animate(animController);
  }

  Future getApiResponse() async {
    /// get request for API server and store response.

    String apiData =
        await ApiCall().getApiData('/check?id=${_auth.currentUser?.uid}');

    setState(() {
      // animation QR code
      apiResponse = apiData.split('-');
      animController.reverse(from: 0.45);
    });
  }

  void getUserMessage() {
    /// beautify API response

    if (apiResponse[0] == 'Enter') {
      userMessage = 'You can enter\nYour Parking Number:';
      userParkingNumber = apiResponse[1];
      userParkingPath = apiResponse[2];
    } else if (apiResponse[0] == 'Exit') {
      userMessage = 'Good bye!!\nSee you soon.\nYour need to pay:';
      userTotalPay = '\$' + apiResponse[1];
    } else {
      userMessage = 'Something is not right. \nTry again.';
    }
  }

  void getUserName() async {
    /// get current user's full name form firebase.

    dynamic dataName =
        await _fireStore.collection('users').doc(_auth.currentUser?.uid).get();
    setState(() {
      fullName = dataName['fName'] + ' ' + dataName['lName'];
    });
  }

  @override
  void initState() {
    // get current user's name on initialization

    getAnimValue();
    getUserName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width; // width of screen
    double h = MediaQuery.of(context).size.height; // height of screen
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
                  // app bar
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
                              if (index == 3) {
                                // sign out redirect to intro screen
                                await _auth.signOut().whenComplete(() =>
                                    Navigator.restorablePopAndPushNamed(
                                        context, Intro.id));
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
                      height: h * 0.05,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "Hey, $fullName.",
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: kDarkTextColor,
                          fontSize: 30.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: h * 0.4,
              left: w * -0.05,
              child: SizedBox(
                // height: h * 0.,
                width: w * 1.08,
                child: Image.asset(
                  'assets/images/home_image.jpg',
                  color: const Color.fromRGBO(255, 255, 255, 0.15),
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
            ),
            Positioned(
              width: w * 0.8,
              height: h * 0.15,
              top: h * 0.25,
              left: w * 0.06,
              child: Text(
                '$userMessage ',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 25.0,
                ),
              ),
            ),
            Positioned(
              width: w * 0.8,
              height: h * 0.1,
              top: h * 0.34,
              left: w * 0.06,
              child: Text(
                userParkingNumber,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 55.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              width: w * 0.8,
              height: h * 0.40,
              top: (userParkingPath == '') ? h * 0.38 : h * 0.43,
              left: w * 0.06,
              child: Text(
                (userParkingPath == '') ? userTotalPay : userParkingPath,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              top: offset.value == 1.0 ? h * 1 : h * offset.value,
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
              height: h * 0.05,
              bottom: h * 0.05,
              left: w * 0.1,
              child: CustomButton(
                title: 'Generate QRCode',
                textSize: 15.0,
                buttonFunction: () async {
                  // http get request on button press

                  userParkingPath = '';
                  userTotalPay = '';
                  userParkingNumber = '';
                  userMessage = '';
                  animController.forward();
                  animController.addListener(() {
                    setState(() {});
                  });

                  await getApiResponse().whenComplete(() => getUserMessage());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }
}
