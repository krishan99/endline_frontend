
import 'package:business_app/business_app/services/services.dart';
import 'package:business_app/services/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:business_app/business_app/models/queues.dart';

//When this file gets to big, split into multiple files.

abstract class ComplexEnum<T> {
  final T _value;
  const ComplexEnum(this._value);
  T get value => _value;
}

class ModelData {
  User user;
  BusinessAppServer server;
  AllQueuesInfo qinfo;

  ModelData() {
    this.server = BusinessAppServer();
    this.user = User(server: server);
    this.qinfo = AllQueuesInfo(server: server);
  }
}

class User extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final BusinessAppServer server;

  String _businessName;
  String _businessDescription;

  FirebaseUser _firebaseUser;
  String email;

  bool get isLoggedIn {
    return _firebaseUser != null;
  }

  String get businessName {
    return _businessName;
  }

  String get businessDescription {
    return _businessDescription;
  }

  Future<String> getToken() async {
    IdTokenResult tokenResult = await _firebaseUser.getIdToken();
    return tokenResult.token.toString();
  }

  Future<void> notifyServerOfSignIn(String email) async {
    final token = await getToken();
    final map = await server.signIn(token: token);
    this._businessName = map["name"];
    this._businessDescription = map["description"];
    this.email = email;
    server.connectSocket();
    notifyListeners();
  }

  Future<void> updateUserData({String name, String description}) async {
    assert(isLoggedIn);
    await server.updateUserData(name: name ?? "", description: description ?? "");
    this._businessName = name;
    this._businessDescription = description;
    notifyListeners();
  }

  Future<void> createAccountOnServer({@required String email, String name, String description}) async {
    final token = await getToken();
    await server.signUp(token: token, name: name, description: description);
    await notifyServerOfSignIn(email);
  }

  Future<AuthResult> signWithGoogleOnFirebase() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    try {
      return await _auth.signInWithCredential(credential);
    } catch (error) {
      throw getFirebaseException(error);
    }
  }

  Future<void> signInWithGoogle() async {
    final result = await signWithGoogleOnFirebase();
    await notifyServerOfSignIn(result.user.email);
  }

  Future<void> signUpWithGoogle({String name, String description}) async {
    final result = await signWithGoogleOnFirebase();
    await createAccountOnServer(email: result.user.email, name: name, description: description);
  }

  Future<void> signUp({String name, String description, @required String email, @required String password}) async {
    AuthResult result;

    try {
      result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (error) {
      throw getFirebaseException(error);
    }

    await createAccountOnServer(email: result.user.email, name: name, description: description);
  }

  Exception getFirebaseException(dynamic error) {
    if (error is PlatformException) {
        return FirebaseServerException(getFirebaseErrorMessage(firebaseErrorCode: error.code));
      } else {
        return CustomException(error.toString());
    }
  }

  String getFirebaseErrorMessage({@required String firebaseErrorCode}) {
    switch (firebaseErrorCode) {
        case "ERROR_INVALID_EMAIL":
          return "Your email address appears to be malformed.";
        case "ERROR_WRONG_PASSWORD":
          return "Your password is wrong.";
        case "ERROR_USER_NOT_FOUND":
          return "User with this email doesn't exist.";
        case "ERROR_USER_DISABLED":
          return "User with this email has been disabled.";
        case "ERROR_TOO_MANY_REQUESTS":
          return "Too many requests. Try again later.";
        case "ERROR_OPERATION_NOT_ALLOWED":
          return "Signing in with Email and Password is not enabled.";
        default:
          return "An undefined error happened. code: $firebaseErrorCode";
      }
  }

  Future<void> signIn({
      @required String email,
      @required String password,
      String businessName,
      String description
    }) async {

    AuthResult result;

    try {
      result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (error) {
      throw getFirebaseException(error);
    }

    return notifyServerOfSignIn(result.user.email);
  }

  Future<void> signInSilently() async {
      await googleSignIn.signInSilently(suppressErrors: true);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    //TODO: Sign out from server? Idk if this is needed.
  }

  User({@required this.server}) {
    _auth.onAuthStateChanged.listen((fUser) async {
      this._firebaseUser = fUser;
      print("AUTH STATE CHANGED: ${this.isLoggedIn}");
    });
  }
}
