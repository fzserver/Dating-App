import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:dating/utils/functions.dart';
import 'package:dating/models/user.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class SignupProfile extends StatefulWidget {

  final FirebaseUser user;
  final String userId;
  final dynamic loginCallback;
  final FirebaseMessaging messaging;

  SignupProfile({this.messaging, this.user, this.userId, this.loginCallback});

  @override
  SignupProfileState createState() => SignupProfileState();
}
class SignupProfileState extends State<SignupProfile> {
  final formKey = GlobalKey<FormState>();
  File pickdImage;
  Future<String> countries;
  bool radio = false;
  bool proceed, spinner = false;
  String username, sex, messagingToken = "";
  int selectedRadio = 0;
  String country = "India";
  String imageUrl = "https://i.ya-webdesign.com/images/funny-png-avatar-2.png";
  int age = 18;
  String nameDes, ageDes = '';
  User user;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.messaging.getToken().then((value) {
      assert(value != null);
      setState(() {
        messagingToken = value;
      });
    });
    ageDes = "Add your age";
    nameDes = widget.user.displayName;
    imageUrl = widget.user.photoUrl;
    username = widget.user.displayName;
  }

  // bool validateAndSave() {
  //   final form = formKey.currentState;
  //   if (form.validate() && radio) {
  //     form.save();
  //     return true;
  //   }
  //   return false;
  // }

  Future getImage() async {
    try {
      var file = await ImagePicker().getImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          pickdImage = File(file.path);
        });
        var url = uploadProfilePic(pickdImage, widget.userId);
        url.then((value) {
          setState(() {
            imageUrl = value;
          });
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    countries = loadCountries(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      extendBody: true,
      body: ModalProgressHUD(
              opacity: 0.1,
              color: Colors.red,
              inAsyncCall: spinner,
              child: SingleChildScrollView(
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: Stack(
                    children: [
                      // Positioned(
                      //   left: 30,
                      //   child: Image.asset('assets/images/Line5.png',)),
                      CustomPaint(
                          painter: CurvePainter(),
                          child: Container(
                    // decoration: BoxDecoration(
                    //   gradient: LinearGradient(
                    //     colors: [
                    //       Theme.of(context).accentColor,
                    //       Theme.of(context).primaryColor
                    //     ]
                    //   )
                    // ),
                    child: SafeArea(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        SizedBox(height: height*0.09),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(imageUrl),
                                  radius: width*0.15 + height * 0.015,
                                ),
                                Positioned(
                                  left: width * 0.2,
                                  top: height * 0.05 + width * 0.13,
                                  child: RawMaterialButton(
                                    onPressed: () {
                                      getImage();
                                    },
                                    shape: CircleBorder(),
                                    child: Icon(Icons.mode_edit, color: Colors.red),
                                    fillColor: Colors.white,
                                  )
                                )
                              ]
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.09),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: width * 0.15,),
                            Text("Name", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        SizedBox(height: height * 0.015),
                        SizedBox(
                            height: 40.0,
                            width: width*0.72,
                            child: TextFormField( 
                            onTap: () {
                              setState(() {
                                nameDes = '';
                              });
                            },
                            onChanged: (value) {
                              setState(() {
                                username = value;
                                nameDes = '';
                              });
                            }, 
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.justify,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical:1, horizontal: 12.0),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor
                                  )
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.white,
                                        width: 0,
                                        style: BorderStyle.none
                                    )
                                ),
                                labelText: nameDes,
                                // hintText: widget.user.displayName,
                                filled: true,
                                fillColor: Colors.transparent,
                                hintStyle: TextStyle(
                                    color: Colors.grey
                                ),
                                focusColor: Colors.grey
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.035),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: width * 0.15,),
                            Text("Age", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        SizedBox(height: height * 0.015),
                        SizedBox(
                            height: 40.0,
                            width: width*0.72,
                            child: TextFormField(  
                            onTap: () {
                              setState(() {
                                ageDes = '';
                              });
                            },  
                            onChanged: (value) {
                              setState(() {
                                age = int.parse(value);
                                ageDes = '';
                              });
                            },
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.justify,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical:1, horizontal: 12.0),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor
                                  )
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey,
                                        width: 0,
                                        style: BorderStyle.none
                                    )
                                ),
                                labelText: ageDes,
                                hintText: "Add your age",
                                filled: true,
                                fillColor: Colors.white,
                                hintStyle: TextStyle(
                                    color: Colors.grey
                                ),
                                focusColor: Colors.grey
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.035),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: width * 0.15,),
                            Text("Country", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        SizedBox(height: height * 0.015),
                        FutureBuilder(
                          future: countries,
                          builder: (BuildContext context, AsyncSnapshot snap) {
                            if (snap.hasData) {
                              List<DropdownMenuItem<String>> items = [];
                              snap.data.split("\n").forEach((value) {
                                items.add(DropdownMenuItem(
                                  value: value.toString(),
                                  child: Text(value.toString()),
                                ));
                              });

                              return 
                                  Padding(
                                    padding: EdgeInsets.only(left: width * 0.015),
                                    child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      elevation: 0,
                                      value: country,
                                      items: items,
                                      onChanged: (String value) {
                                        setState(() {
                                          country = value;
                                        });
                                      }
                              ),
                                    ),
                                  );

                            } else {
                              return Container();
                            }
                          },
                        ),
                        SizedBox(height: height * 0.035),
                        Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: width * 0.04),
                          child: Text('Gender', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),)),
                        SizedBox(
                          width: width * 0.19,
                        ),
                        Text('Male', style: TextStyle(color: Colors.black)),
                        Radio(
                          value: 1,
                          groupValue: selectedRadio,
                          activeColor: Colors.black,
                          onChanged: (val) {
                            setState(() {
                              radio = true;
                              selectedRadio = val;
                              sex = "male";
                            });
                          },
                        ),
                        SizedBox(width: width * 0.033),
                        Text('Female', style: TextStyle(color: Colors.black)),
                        Radio(
                          value: 2,
                          groupValue: selectedRadio,
                          activeColor: Colors.black,
                          onChanged: (val) {
                            setState(() {
                              radio = true;
                              selectedRadio = val;
                              sex = "female";
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.035),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                            padding: EdgeInsets.symmetric(vertical: height * 0.001, horizontal: width * 0.05),
                            child: RawMaterialButton(
                            fillColor: Colors.red.shade400,
                            elevation: 2.0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            onPressed: () {
                              setState(() {
                                spinner = true;
                              });
                              var user = User(
                                userId: widget.userId,
                                username: username,
                                country: country,
                                age: age,
                                imageUrl: imageUrl,
                                gender: sex,
                                onVideoCall: 0,
                                token: messagingToken,
                                coins: 100
                              );
                              if ((radio && sex != "") && username.startsWith(RegExp(r'[a-z]|[A-Z]'))) {
                                createUserProfile(user);
                                setState(() {
                                  spinner = false;
                                });
                                widget.loginCallback();
                              } else {
                                setState(() {
                                  spinner = false;
                                });
                                Fluttertoast.showToast(
                                  msg: "Please fill all the details",
                                  gravity: ToastGravity.BOTTOM
                                );
                              }
                            },
                            child: Text("NEXT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    )
                    ],
                  ),
                ),
              ),
                      ),
              ]
            ),
          ),
        ),
      ),
    );
  }
  
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    // Colors.redAccent[700].withAlpha(225)
    paint.color = Colors.red;
    paint.style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, size.height * 0.22);
    path.quadraticBezierTo(size.width / 2, size.height / 2.5, size.width, size.height * 0.22);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    canvas.drawPath(path, paint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


  
// @override
//   Widget build(BuildContext context) {
//     var width = MediaQuery.of(context).size.width;
//     var height = MediaQuery.of(context).size.height;
//     countries = loadCountries(context);

//     return Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Colors.red[400],
//               Colors.red[200],
//               Colors.red[400]
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight
//           )
//         ),
//       alignment: Alignment.center,
//       child: SafeArea(
//         child: Form(
//             key: formKey,
//             child: Stack(
//             children: [
//               Positioned(
//               left: 30,
//               child: Image.asset('assets/images/Line5.png',)),
//               Positioned(
//                 left: width * 0.3,
//                 top: height * 0.15,
//                 child: Column(
//                   children: [
//                     GestureDetector(
//                         onTap: () {
//                           getImage();
//                         },
//                         child: CircleAvatar(
//                           backgroundImage: pickdImage == null ? NetworkImage(imageUrl) : FileImage(pickdImage),
//                           radius: 75,
//                         ),
//                     ),
//                   ],
//                 ),
//               ),
//               Positioned(
//                 left: width * 0.15,
//                 top: height * 0.37,
//                   child: Material(
//                     borderRadius: BorderRadius.circular(8),
//                       child: SizedBox(
//                       height: 45.0,
//                       width: width*0.75,
//                       child: TextFormField(  
//                       // validator: (value) {
//                       //   if (value.isEmpty) {
//                       //     return "Profile name can't be empty";
//                       //   } else if (!value.startsWith(RegExp(r'[a-z]|[A-Z]'))) {
//                       //     return "Name should starts with alphabet character";
//                       //   } else {
//                       //     return null;
//                       //   }
//                       // },
//                       keyboardType: TextInputType.text,
//                       textAlign: TextAlign.justify,
//                       decoration: InputDecoration(
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide(
//                                   color: Colors.red,
//                               )
//                           ),
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide(
//                               )
//                           ),
//                           labelText: nameDes,
//                           // hintText: widget.user.displayName,
//                           fillColor: Colors.white,
//                           labelStyle: TextStyle(
//                             color: Colors.black26
//                           ),
//                           hintStyle: TextStyle(
//                               color: Colors.grey
//                           ),
//                           focusColor: Colors.grey
//                       ),
//                       onChanged: (value) {
//                         setState(() {
//                           username = value.trim();
//                           nameDes='';
//                         });
//                       },
//                       onTap: () {
//                         setState(() {
//                           nameDes = '';
//                         });
//                       },
//                     ),
//                 ),
//                   ),
//                 ),
//                 Positioned(
//                   left: width * 0.15,
//                   top: height * 0.45,
//                   child: Material(
//                     borderRadius: BorderRadius.circular(8),
//                     child: SizedBox(
//                       height: 45.0,
//                       width: width*0.75,
//                       child: TextFormField(    
//                       validator: (value) => value.isEmpty?"Please add your age":null,
//                       keyboardType: TextInputType.number,
//                       textAlign: TextAlign.justify,
//                       decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: BorderSide(
//                                   color: Colors.red,
//                                   width: 0,
//                                   style: BorderStyle.none
//                               )
//                           ),
//                           labelText: 'Your Age',
//                           // filled: true,
//                           fillColor: Colors.white,
//                           labelStyle: TextStyle(
//                             color: Colors.black26
//                           ),
//                           hintStyle: TextStyle(
//                               color: Colors.grey
//                           ),
//                           focusColor: Colors.grey
//                       ),
//                       onChanged: (value) {
//                         setState(() {
//                           age = int.parse(value);
//                         });
//                       },
//                     ),
//                   ),
//                   ),
//                 ),
//                 Positioned(
//                   left: width * 0.15,
//                   top: height * 0.53,
//                   child: Material(
//                     borderRadius: BorderRadius.circular(8),
//                       child: SizedBox(
//                         height:45.0,
//                         width: width * 0.75,
//                         child: FutureBuilder(
//                         future: countries,
//                         builder: (BuildContext context, AsyncSnapshot snap) {
//                           if (snap.hasData) {
//                             List<DropdownMenuItem<String>> items = [];
//                             snap.data.split("\n").forEach((value) {
//                               items.add(DropdownMenuItem(
//                                 value: value.toString(),
//                                 child: Padding(padding: EdgeInsets.only(left: 8.0), child: Text(value.toString())),
//                               ));
//                             });

//                             return 
//                                 DropdownButtonHideUnderline(
//                                   child: DropdownButtonFormField<String>(
//                                   value: "India",
//                                   items: items,
//                                   onChanged: (String value) {
//                                     // setValues(value, country);
//                                     setState(() {
//                                       country = value;
//                                     });
//                                   }
//                             ),
//                                 );

//                           } else {
//                             return Container();
//                           }
//                         },
//                     ),
//                       ),
//                   ),
//                 ),
//                 Positioned(
//                   right: width * 0.033,
//                   bottom: height * 0.023,
//                   child: Material(
//                       color: Colors.transparent,
//                       borderRadius: BorderRadius.circular(16),
//                       child: InkWell(
//                       onTap: () {
//                         setState(() {
//                           showSpinner = true;
//                         });
//                         var user = User(
//                           userId: widget.userId,
//                           username: username,
//                           country: country,
//                           age: age,
//                           imageUrl: imageUrl,
//                           gender: sex,
//                           onVideoCall: 0,
//                           token: messagingToken,
//                           coins: 100
//                         );
//                         if ((validateAndSave() && sex != "") && username.startsWith(RegExp(r'[a-z]|[A-Z]'))) {
//                           createUserProfile(user);
//                           setState(() {
//                             showSpinner = false;
//                           });
//                           widget.loginCallback();
//                         } else {
//                           setState(() {
//                             showSpinner = false;
//                           });
//                           Fluttertoast.showToast(
//                             msg: "Please fill all the details",
//                             gravity: ToastGravity.BOTTOM
//                           );
//                         }
//                       },
//                       child: Padding(padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0), child: Text("NEXT", style: TextStyle(color: Colors.white, fontSize: 20.0))),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: height * 0.60,
//                   left: width * 0.15,
//                   child: Material(
//                       color: Colors.transparent,
//                       child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         Text('Gender', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),),
//                         SizedBox(
//                           width: width * 0.21,
//                         ),
//                         Text('Male', style: TextStyle(color: Colors.black)),
//                         Radio(
//                           value: 1,
//                           groupValue: selectedRadio,
//                           activeColor: Colors.black,
//                           onChanged: (val) {
//                             setState(() {
//                               radio = true;
//                               selectedRadio = val;
//                               sex = "male";
//                             });
//                           },
//                         ),
//                         SizedBox(width: width * 0.033),
//                         Text('Female', style: TextStyle(color: Colors.black)),
//                         Radio(
//                           value: 2,
//                           groupValue: selectedRadio,
//                           activeColor: Colors.black,
//                           onChanged: (val) {
//                             setState(() {
//                               radio = true;
//                               selectedRadio = val;
//                               sex = "female";
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }