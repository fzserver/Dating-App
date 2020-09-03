import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


abstract class BaseAuth {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password);
  Future<FirebaseUser> getCurrentUser();
  Future<void> sendEmailVerification();
  Future<FirebaseUser> signInWithGoogle();
  Future<void> signOutGoogle();
  Future<void> signOut();
  Future<bool> isEmailVerified();
}

class Auth implements BaseAuth {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    AuthResult result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
    );
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<String> signUp(String email, String password) async {
    AuthResult result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password
    );
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOutGoogle() async {
    await firebaseAuth.signOut();
    await googleSignIn.signOut();
  }

  Future<FirebaseUser> signInWithGoogle() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken, 
      idToken: googleSignInAuthentication.idToken
    );
    AuthResult authResult = await firebaseAuth.signInWithCredential(credential);
    assert(!authResult.user.isAnonymous);
    assert(await authResult.user.getIdToken() != null);
    FirebaseUser currentUser = await firebaseAuth.currentUser();
    assert(authResult.user.uid == currentUser.uid);
    return authResult.user;
  }

  Future<void> signOut() async {
    return firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

}