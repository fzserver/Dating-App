import 'package:dating/models/user.dart';
import 'package:flutter/material.dart';
import 'package:dating/utils/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating/widgets/cached_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfile extends StatefulWidget {
  final User user;
  EditProfile({this.user});

  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  String username;
  String imageUrl;
  File pickdImage;
  String country;
  Future<String> countries;
  int age = 18;
  bool name, userAge = false;
  String bio, nameDes, ageDes, bioDes = '';
  bool spinner = false;

  @override
  void initState() {
    age = widget.user.age;
    ageDes = widget.user.age.toString();
    username = nameDes =  widget.user.username;
    imageUrl = widget.user.imageUrl;
    country = widget.user.country;
    getBio();
    super.initState();
  }

  Future getImage() async {
    try {
      var file = await ImagePicker().getImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          pickdImage = File(file.path);
        });
        var url = uploadProfilePic(pickdImage, widget.user.userId);
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 20.0,
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      extendBody: true,
      body: ModalProgressHUD(
              opacity: 0.1,
              color: Colors.red,
              inAsyncCall: spinner,
              child: SingleChildScrollView(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      ageDes = age.toString();
                      nameDes = username;
                      bioDes = "Write about yourself";
                    });
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
                        SizedBox(height: height*0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                           Stack(
                              children: [
                                CachedImage(
                                  imageUrl,
                                  isRound: true,
                                  radius: width*0.3 + height * 0.025,
                                ),
                                // CircleAvatar(
                                //   backgroundImage: NetworkImage(imageUrl),
                                //   radius: width*0.15 + height * 0.015,
                                // ),
                                Positioned(
                                  left: width * 0.19,
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
                        SizedBox(height: 35.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: width * 0.15,),
                            Text("Name", style: TextStyle(color: Colors.redAccent[700].withAlpha(225), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10.0),
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
                                // hintText: widget.user.username,
                                filled: true,
                                fillColor: Colors.transparent,
                                hintStyle: TextStyle(
                                    color: Colors.grey
                                ),
                                focusColor: Colors.grey
                            ),
                          ),
                        ),
                        SizedBox(height: 25.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: width * 0.15,),
                            Text("Age", style: TextStyle(color: Colors.redAccent[700].withAlpha(225), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10.0),
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
                                hintText: widget.user.age.toString(),
                                filled: true,
                                fillColor: Colors.white,
                                hintStyle: TextStyle(
                                    color: Colors.grey
                                ),
                                focusColor: Colors.grey
                            ),
                          ),
                        ),
                        SizedBox(height: 25.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: width * 0.15,),
                            Text("About Me", style: TextStyle(color: Colors.redAccent[700].withAlpha(225), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        SizedBox(
                            height: 40.0,
                            width: width*0.72,
                            child: TextFormField(   
                            onTap: () {
                              setState(() {
                                bioDes = '';
                              });
                            },
                            onChanged: (value) {
                              setState(() {
                                bio = value;
                                bioDes = '';
                              });
                            },
                            keyboardType: TextInputType.text,
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
                                labelText: bioDes,
                                // hintText: bio,
                                filled: true,
                                fillColor: Colors.white,
                                hintStyle: TextStyle(
                                    color: Colors.grey
                                ),
                                focusColor: Colors.grey
                            ),
                          ),
                        ),
                        SizedBox(height: 25.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: width * 0.15,),
                            Text("Country", style: TextStyle(color: Colors.redAccent[700].withAlpha(225), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 10.0),
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
                                  DropdownButtonHideUnderline(
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
                                  );

                            } else {
                              return Container();
                            }
                          },
                        ),
                        SizedBox(height: 35.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            RaisedButton(
                              onPressed: () async {
                                setState(() {
                                  spinner = true;
                                });
                                if ((username != "" && bio != "") && (username.startsWith(RegExp(r'[a-z]|[A-Z]')))) {
                                  updateProfile(
                                  widget.user.userId,
                                    {
                                      "name": username,
                                      "age": age,
                                      "country": country,
                                      "imageUrl": imageUrl
                                    }
                                  );
                                  await Firestore.instance
                                    .collection("users")
                                    .document(widget.user.userId)
                                    .setData({
                                      "about": bio
                                    }, merge: true);
                                    setState(() {
                                      spinner = false;
                                    });
                                  Fluttertoast.showToast(
                                    msg: "Profile updated.",
                                    gravity: ToastGravity.BOTTOM
                                  );
                                } else {
                                  setState(() {
                                    spinner = false;
                                  });
                                  Fluttertoast.showToast(
                                    msg: "Please fill all the details.",
                                    gravity: ToastGravity.BOTTOM
                                  );
                                }
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              color: Theme.of(context).primaryColor,
                              child: Text("Save", style: TextStyle(color: Colors.white)),
                              elevation: 4.0,
                            ),
                            SizedBox(width: 55.0)
                          ]
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
  getBio() async {
    await Firestore.instance  
      .collection("users")
      .document(widget.user.userId)
      .get()
      .then((value) {
        setState(() {
          bio = value.data["about"];
          bioDes = bio==""?"Write about yourself":bio;
        });
      });
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.red;
    paint.style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, size.height * 0.16);
    path.quadraticBezierTo(size.width / 2, size.height / 3, size.width, size.height * 0.16);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    canvas.drawPath(path, paint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

  