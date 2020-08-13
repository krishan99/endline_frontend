
import 'package:business_app/business_app/services/services.dart';
import 'package:business_app/services/services.dart';
import 'package:business_app/utils.dart';
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
  AllQueuesInfo qinfo;

  ModelData() {
    this.user = User();
    this.qinfo = AllQueuesInfo();
  }
}

class User extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

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
    final map = await BusinessAppServer.signIn(token: token);
    this._businessName = map["name"];
    this._businessDescription = map["description"];
    this.email = email;
    BusinessAppServer.connectSocket();
    notifyListeners();
  }

  Future<void> updateUserData({String name, String description}) async {
    assert(isLoggedIn);
    await BusinessAppServer.updateUserData(name: name ?? "", description: description ?? "");
    this._businessName = name;
    this._businessDescription = description;
    notifyListeners();
  }

  Future<void> createAccountOnServer({@required String email, String name, String description}) async {
    final token = await getToken();
    await BusinessAppServer.signUp(token: token, name: name, description: description);
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
      switch (error.code) {
        case "ERROR_INVALID_EMAIL":
          return InvalidEmailException();
        case "ERROR_WRONG_PASSWORD":
          return InvalidPasswordException();
        case "ERROR_EMAIL_ALREADY_IN_USE":
          return EmailAlreadyInUseException();
        case "ERROR_USER_NOT_FOUND":
          return UserNotFoundException();
        case "ERROR_USER_DISABLED":
          return UserDisabledException();
        case "ERROR_TOO_MANY_REQUESTS":
          return TooManyRequestsException();
        case "ERROR_OPERATION_NOT_ALLOWED":
          return OperationNotAllowedException();
        default:
          return CustomException("An undefined error happened. code: ${error.code}");
      }
      } else {
        return CustomException(error.toString());
    }
  }

  Future<void> sendPasswordResetLink({@required String email}) async {
    if (!Utils.isValidEmail(email)) {
      throw CustomException("Not a valid email address.");
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (error) {
      throw getFirebaseException(error);
    }
  }

  Future<AuthResult> signInOnFirebase({
    @required String email,
    @required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (error) {
      throw getFirebaseException(error);
    }
  }

  Future<void> signIn({
      @required String email,
      @required String password,
      String businessName,
      String description
    }) async {
    final result = await signInOnFirebase(email: email, password: password);
    return notifyServerOfSignIn(result.user.email);
  }

  Future<void> signInSilently() async {
      await googleSignIn.signInSilently(suppressErrors: true);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    BusinessAppServer.signOut();
  }

  User() {
    _auth.onAuthStateChanged.listen((fUser) async {
      this._firebaseUser = fUser;
      print("AUTH STATE CHANGED: ${this.isLoggedIn}");
    });
  }
}
