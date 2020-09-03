import 'dart:async';

import 'package:dating/screens/homePage.dart';
import 'package:dating/screens/loginScreen.dart';
import 'package:dating/screens/singup_profile.dart';
import 'package:dating/utils/functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:dating/models/user.dart';
import 'package:dating/screens/sign_in_up_screen.dart';
import 'package:dating/services/authentication.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity/connectivity.dart';

enum AuthStatus {
  LOGGED_IN_FIRST_TIME,
  SIGN_UP,
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class RootPage extends StatefulWidget {
  final BaseAuth auth;

  RootPage({this.auth});

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  StreamSubscription<ConnectivityResult> connectionSubscription;
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  FirebaseUser currentUser;
  String userId = "";

  @override
  void dispose() {
    connectionSubscription.cancel();
    super.dispose();
  }

  @protected
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connectionSubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) { 
      if(result == ConnectivityResult.none) {
       Fluttertoast.showToast(
         msg: "Unable to connect to the network",
         gravity: ToastGravity.BOTTOM,
       );
      }
    });
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if(user != null) {
          userId = user?.uid;
        }
        authStatus = user?.uid == null?AuthStatus.NOT_LOGGED_IN:AuthStatus.LOGGED_IN;
    });
  });
  }

  void googleSignIn() {
    widget.auth.signInWithGoogle().then((user) {
      checkUser(user.uid).then((value) {
        if(value.exists) {
          setState(() {
            userId = user?.uid.toString();
            authStatus = AuthStatus.LOGGED_IN;
          });
        } else {
          Fluttertoast.showToast(
            msg: "The user does not exists",
            gravity: ToastGravity.BOTTOM
          );
        }
      });
    });
  }

  void googleSignUp() {
    widget.auth.signInWithGoogle().then((user) {
      checkUser(user.uid).then((value) {
        if(value.exists) {
          Fluttertoast.showToast(
            msg: "The user is already exists",
            gravity: ToastGravity.BOTTOM
          );
        } else {
          setState(() {
            currentUser = user;
            userId = user?.uid.toString();
            authStatus = AuthStatus.LOGGED_IN_FIRST_TIME;
          });
        }
      });
    });
  }

   void login() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        userId = user?.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        userId = user?.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
    });
  }

  void loginFirstTime() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        userId = user.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN_FIRST_TIME;
    });
  }

  void signupcallback() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        userId = user?.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.SIGN_UP;
    });
  }

  void googleSignOut() {
    widget.auth.signOutGoogle();
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      userId = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.LOGGED_IN:
        if (userId.length > 0 && userId != null) {
          return new HomePage(
            startIndex: 1,
            firebaseMessaging: firebaseMessaging,
            userId: userId,
            logoutCallback: googleSignOut
          );
        } else
          return buildWaitingScreen();
        break;
      case AuthStatus.SIGN_UP:
        return new SignUp(
          auth: widget.auth,
          loginFirstTimeCallback: googleSignUp,
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.NOT_DETERMINED:
        return buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginScreen(
          auth: widget.auth,
          // loginFirstTime: loginFirstTime,
          loginCallback: googleSignIn,
          logoutCallback: signupcallback
        );
        break;
      case AuthStatus.LOGGED_IN_FIRST_TIME:
        if(userId.length > 0 && userId != null) {
          addVideoCalls(userId);
          firebaseMessaging.getToken().then((value) {
            createUserProfile(getBasicUser(
              currentUser.displayName,
              currentUser.photoUrl,
              currentUser.uid,
              value
            ));
          });
          return new SignupProfile(
            messaging: firebaseMessaging,
            user: currentUser,
            userId: userId,
            loginCallback: login
          );
        } else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }
  }
}
