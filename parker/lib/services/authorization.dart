import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _auth = FirebaseAuth.instance;
final CollectionReference _users =
    FirebaseFirestore.instance.collection('users');

class Authorization {
  /// class for sign in and sign up using firebase

  Future<bool> signIn({required String email, required String password}) async {
    /// sign in with email and password
    /// if admin then return true
    /// else return false

    await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (email == 'admin@nexus.co' && password == 'admin123') {
      return true;
    } else {
      return false;
    }
  }

  Future signUp(
      {required String email,
      required String password,
      required String fName,
      required String lName}) async {
    /// sign up with email and password
    /// add user in user table in database
    /// if error occurs then return error
    /// else return null

    return await _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) async => await _users.doc(value.user?.uid).set({
              'fName': fName,
              'lName': lName,
              'email': email,
              'password': password,
              'cardNumber': ' ',
              'cvv': '000',
              'expMonth': 01,
              'expYear': 26,
              'entered': false,
              'entryTime': DateTime.now().millisecondsSinceEpoch,
            }))
        .catchError((onError) => onError.toString());
  }
}
