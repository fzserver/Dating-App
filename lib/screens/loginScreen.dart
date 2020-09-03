import 'package:dating/screens/sign_in_up_screen.dart';
import 'package:dating/services/authentication.dart';
import 'package:dating/widgets/design.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dating/screens/homePage.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';


class LoginScreen extends StatefulWidget {

  static const routeName = 'LoginScreen';
  final BaseAuth auth;
  // final dynamic loginFirstTime;
  final VoidCallback loginCallback;
  final VoidCallback logoutCallback;

  // LoginScreen({this.auth, this.loginFirstTime, this.loginCallback, this.logoutCallback});
  LoginScreen({this.auth, this.loginCallback, this.logoutCallback});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  String email;
  String errorMessage;
  String userId;
  String password;
  bool showSpinner;

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
      widget.loginCallback();
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
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  void initState() {
    userId = "";
    errorMessage = "";
    showSpinner = false;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Theme.of(context).accentColor, Theme.of(context).primaryColor], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Design('Sign In', 'assets/images/login.png'),
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
                                  text: "Sign in with Google",
                                ),
                        ),
                        ),
                      Positioned(
                        left: MediaQuery.of(context).size.width * 0.31, 
                        top: MediaQuery.of(context).size.height * 0.82, 
                        height: MediaQuery.of(context).size.height * 0.05, 
                        // right: MediaQuery.of(context).size.width * 0.25,
                        child: GestureDetector(
                            onTap: () {
                              widget.logoutCallback();
                            },
                            child: Text("Don\'t have an account?", style: TextStyle(color: Colors.white, fontSize: 16.0))
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
                    //                       onSaved: (value) => password = value.trim(),
                    //                       validator: (value) {
                    //                         if (value.isEmpty) {
                    //                             return "Password can\'t be empty";
                    //                         } else if (value.length < 6) {
                    //                           return "Password length should atleast 6";
                    //                         } else {
                    //                           return null;
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
                    //                 SizedBox(
                    //                   height: MediaQuery.of(context).size.height * 0.03,
                    //                 ),
                    //                 Container(
                    //                   child: GradientButton(
                    //                     increaseWidthBy: double.infinity,
                    //                     increaseHeightBy: MediaQuery.of(context).size.height * 0.02,
                    //                     child: Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 35),),
                    //                     callback: (){
                    //                       setState(() {
                    //                         showSpinner = true;
                    //                       });
                    //                       validateAndSubmit();
                    //                       setState(() {
                    //                         showSpinner = false;
                    //                       });
                    //                     },
                    //                     gradient: Gradients.backToFuture,
                    //                     shadowColor: Gradients.backToFuture.colors.last.withOpacity(0.2),
                    //                   ),
                    //                 ),
                    //                 SizedBox(
                    //                   height: 10,
                    //                 ),
                    //                 Row(
                    //                   mainAxisAlignment: MainAxisAlignment.center,
                    //                   children: <Widget>[
                    //                     // GestureDetector(
                    //                     //     onTap: () {},
                    //                     //     child: Text('Forget Password.', style: TextStyle(fontSize: 13),)),
                    //                     SizedBox(
                    //                       width: 7,
                    //                     ),
                    //                     GestureDetector(
                    //                         onTap: () {
                    //                           widget.logoutCallback();
                    //                           // Navigator.push(context, MaterialPageRoute(builder: (_) => SignUp(
                    //                           //   auth: widget.auth,
                    //                           //   // loginFirstTimeCallback: widget.loginFirstTime,
                    //                           //   loginCallback: widget.loginCallback,
                    //                           //   logoutCallback: widget.logoutCallback,
                    //                           // )));
                    //                         },
                    //                         child: Text('Don\'t have an account?', style: TextStyle(fontSize: 18),))
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
        )
    );
  }
}
