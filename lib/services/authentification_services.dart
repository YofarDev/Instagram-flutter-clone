import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/res/strings.dart';
import 'package:instagram_clone/services/user_services.dart';

class AuthenticationService {
  final fb.FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<fb.User> get authStateChanges => _firebaseAuth.idTokenChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String> signIn(
      {String email, String password, GlobalKey<ScaffoldState> key}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return "Signed in";
    } on fb.FirebaseAuthException catch (e) {
      String errorMessage;
      print(e.code);
      switch (e.code) {
        case "invalid-email":
          errorMessage = AppStrings.errorEmailFormat;
          break;
        case "wrong-password":
          errorMessage = AppStrings.errorSignInWrongPassword;
          break;
        case "user-not-found":
          errorMessage = AppStrings.errorSignInNoUser;
          break;

        case "ERROR_USER_DISABLED":
          errorMessage = "User with this email has been disabled.";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          errorMessage = "Too many requests. Try again later.";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;

        default:
          errorMessage = "An undefined Error happened.";
      }
      if (errorMessage.isNotEmpty)
        key.currentState.showSnackBar(SnackBar(content: Text(errorMessage)));

      return e.message;
    }
  }

  Future<String> signUp(
      {String email, String username, String password, String picture, GlobalKey<ScaffoldState> key}) async {
    key.currentState.showSnackBar(SnackBar(
      content: Text(
        AppStrings.processing,
      ),
    ));
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      UserServices.addUser(
        User.newUser(email: email, name: username, username: username, picture:picture)
      );
      return "Signed up";
    } on fb.FirebaseAuthException catch (e) {
      if (e.message == "The email address is badly formatted.")
        key.currentState
            .showSnackBar(SnackBar(content: Text(AppStrings.errorEmailFormat)));
      else
        key.currentState.showSnackBar(SnackBar(
          content: Text(
            AppStrings.errorTryAgain,
          ),
        ));
      return e.message;
    }
  }
}