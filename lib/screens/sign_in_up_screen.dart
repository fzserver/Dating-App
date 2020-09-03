import 'package:dating/screens/loginScreen.dart';
import 'package:dating/screens/singup_profile.dart';
import 'package:dating/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:dating/widgets/design.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:dating/utils/functions.dart';

class SignUp extends StatefulWidget {
  static const routeName = 'loginScreen';
  final BaseAuth auth;
  final VoidCallback loginFirstTimeCallback;
  final VoidCallback loginCallback;

  // SignUp({this.auth, this.loginFirstTimeCallback, this.loginCallback, this.logoutCallback});
  SignUp({this.auth, this.loginCallback, this.loginFirstTimeCallback});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
//  final _auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();
  String sex;
  String errorMessage;
  String userId;
  String email;
  String password;
  bool showSpinner;

  @override
  void initState() {
    super.initState();
    userId = "";
    sex = "";
    showSpinner = false;
    errorMessage = "";
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndSubmit() async {
    setState(() {
      errorMessage = "";
      showSpinner = true;
    });
    try {
      widget.loginFirstTimeCallback();
      setState(() {
          showSpinner = false;
        });
    } catch (e) {
        setState(() {
          showSpinner = false;
//          errorMessage = e.message;
          // formKey.currentState.reset();
        });
        Fluttertoast.showToast(
          msg: e.message.toString(),
          gravity: ToastGravity.BOTTOM,
        );
      }
//     if (validateAndSave() && password.length > 5) {
//       try {
//         userId = await widget.auth.signUp(email, password);
//         print("Signed up user: $userId");
//         setState(() {
//           showSpinner = false;
//         });
//         if (userId.length > 0 && userId != null) {
//           // addVideoCalls(userId);
//           widget.loginFirstTimeCallback();
//           // Navigator.push(context, MaterialPageRoute(
//           //   builder: (_) => SignupProfile(
//           //     userId: userId,
//           //     loginCallback: widget.loginCallback,
//           //     // logoutCallback: widget.logoutCallback,
//           //   )
//           // ));
//         }
//       } catch (e) {
//         setState(() {
//           showSpinner = false;
// //          errorMessage = e.message;
//           formKey.currentState.reset();
//         });
//         Fluttertoast.showToast(
//           msg: e.message.toString(),
//           gravity: ToastGravity.BOTTOM,
//         );
//       }
//     } else {
//       Fluttertoast.showToast(
//         msg: "Please fill the required fields correctly",
//         gravity: ToastGravity.BOTTOM
//       );
//     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: ModalProgressHUD(
              inAsyncCall: showSpinner,
              color: Colors.grey.withOpacity(0.85),
              progressIndicator: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              ),
              child: Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Theme.of(context).accentColor, Theme.of(context).primaryColor], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Design('Sign Up', 'assets/images/signup.png'),
                        Positioned.fill(
                          // left: MediaQuery.of(context).size.width * 0.25, 
                          top: MediaQuery.of(context).size.height * 0.55, 
                          // height: MediaQuery.of(context).size.height * 0.05, 
                          // right: MediaQuery.of(context).size.width * 0.25,
                          child: Align(
                            alignment: Alignment.center,
                              child: GoogleSignInButton(
                                  borderRadius: 12.0,
                                  onPressed: validateAndSubmit,
                                  text: "Sign up with Google",
                                ),
                          ),
                        ),
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.31, 
                          top: MediaQuery.of(context).size.height * 0.82, 
                          height: MediaQuery.of(context).size.height * 0.05, 
                          right: MediaQuery.of(context).size.width * 0.25,
                          child: GestureDetector(
                              onTap: () {
                                widget.loginCallback();
                              },
                              child: Text("Already have an account", style: TextStyle(color: Colors.white, fontSize: 16.0))
                            ),
                        ),
                        // Positioned(
                        //   left: MediaQuery.of(context).size.width * 0.02, top: MediaQuery.of(context).size.height * 0.50, height: MediaQuery.of(context).size.height * 0.45 , right: MediaQuery.of(context).size.width * 0.02,
                        //   child: SingleChildScrollView(
                        //     child: Container(
                        //       padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom - MediaQuery.of(context).padding.bottom),
                        //       child: Card(
                        //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        //         color: Color(0xFFC9C9C9),
                        //         child: Padding(
                        //           padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.025),
                        //           child: Form(
                        //             key: formKey,
                        //             autovalidate: true,
                        //             child: Column(
                        //               children: <Widget>[
                        //                 Column(
                        //                   children: <Widget>[
                        //                     Container(
                        //                       height: MediaQuery.of(context).size.height * 0.08,
                        //                       child: TextFormField(
                        //                         onSaved: (value) => email = value.trim(),
                        //                         validator: (value) => value.isEmpty ? "Email can\'t be empty": null,
                        //                         keyboardType: TextInputType.emailAddress,
                        //                         textAlign: TextAlign.center,
                        //                         decoration: InputDecoration(
                        //                             border: OutlineInputBorder(
                        //                                 borderRadius: BorderRadius.circular(8),
                        //                                 borderSide: BorderSide(
                        //                                     width: 0,
                        //                                     style: BorderStyle.none
                        //                                 )
                        //                             ),
                        //                             hintText: 'Email',
                        //                             filled: true,
                        //                             fillColor: Colors.white,
                        //                             hintStyle: TextStyle(
                        //                                 color: Colors.grey
                        //                             ),
                        //                             focusColor: Colors.grey
                        //                         ),
                        //                       ),
                        //                     ),
                        //                     SizedBox(
                        //                       height: MediaQuery.of(context).size.height * 0.02,
                        //                     ),
                        //                     Container(
                        //                       height: MediaQuery.of(context).size.height * 0.08,
                        //                       child: TextFormField(
                        //                         onSaved: (value) => password = value.trim(),
                        //                         validator: (value) {
                        //                           if (value.isEmpty) {
                        //                             return "Password can\'t be empty";
                        //                           } else if (value.length < 6) {
                        //                             return "Password length should atleast 6";
                        //                           } else {
                        //                             return null;
                        //                           }
                        //                         },
                        //                         obscureText: true,
                        //                         textAlign: TextAlign.center,
                        //                         decoration: InputDecoration(
                        //                             border: OutlineInputBorder(
                        //                                 borderRadius: BorderRadius.circular(8),
                        //                                 borderSide: BorderSide(
                        //                                     width: 0,
                        //                                     style: BorderStyle.none
                        //                                 )
                        //                             ),
                        //                             hintText: 'Password',
                        //                             filled: true,
                        //                             fillColor: Colors.white,
                        //                             hintStyle: TextStyle(
                        //                                 color: Colors.grey
                        //                             ),
                        //                             focusColor: Colors.grey
                        //                         ),
                        //                       ),
                        //                     ),
                        //                   ],
                        //                 ),
                        //                 // Row(
                        //                 //   mainAxisAlignment: MainAxisAlignment.center,
                        //                 //   children: <Widget>[
                        //                 //     Text('Gender', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),),
                        //                 //     SizedBox(
                        //                 //       width: MediaQuery.of(context).size.width * 0.11,
                        //                 //     ),
                        //                 //     Text('Male'),
                        //                 //     Radio(
                        //                 //       value: 1,
                        //                 //       groupValue: 0,
                        //                 //       activeColor: Theme.of(context).primaryColor,
                        //                 //       onChanged: (val) {
                        //                 //         setState(() {
                        //                 //           sex = "male";
                        //                 //         });
                        //                 //       },
                        //                 //     ),
                        //                 //     Text('Female'),
                        //                 //     Radio(
                        //                 //       value: 2,
                        //                 //       groupValue: 1,
                        //                 //       activeColor: Theme.of(context).primaryColor,
                        //                 //       onChanged: (val) {
                        //                 //         setState(() {
                        //                 //           sex = "female";
                        //                 //         });
                        //                 //       },
                        //                 //     ),
                        //                 //   ],
                        //                 // ),
                        //                 // Container(
                        //                 //   child: GradientButton(
                        //                 //     increaseWidthBy: double.infinity,
                        //                 //     increaseHeightBy: MediaQuery.of(context).size.height * 0.02,
                        //                 //     child: Text('Sign Up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 35),),
                        //                 //     callback: () async {
                        //                 //       setState(() {
                        //                 //         showSpinner = true;
                        //                 //       });
                        //                 //       validateAndSubmit();
                        //                 //     },
                        //                 //     gradient: Gradients.backToFuture,
                        //                 //     shadowColor: Gradients.backToFuture.colors.last.withOpacity(0.2),
                        //                 //   ),
                        //                 // ),
                        //                 SizedBox(
                        //                   height: 10,
                        //                 ),
                        //                 Row(
                        //                   mainAxisAlignment: MainAxisAlignment.center,
                        //                   children: <Widget>[
                        //                     GestureDetector(
                        //                         onTap: () {
                        //                           widget.loginCallback();
                        //                           // Navigator.push(context, MaterialPageRoute(
                        //                           //   builder: (_) => LoginScreen(
                        //                           //     auth: widget.auth,
                        //                           //     // loginFirstTime: widget.loginFirstTimeCallback,
                        //                           //     loginCallback: widget.loginCallback,
                        //                           //     logoutCallback: widget.logoutCallback
                        //                           //   )
                        //                           // )
                        //                           // );
                        //                         },
                        //                         child: Text('Already have an account?', style: TextStyle(fontSize: 20),))
                        //                   ],
                        //                 )
                        //               ],
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // )
                      ],),
                  ),
                ],
              ),
      ),
    );
  }
}
