
// import 'dart:html' as f;

import 'package:dating/screens/edit_profile.dart';
import 'package:dating/screens/rootPage.dart';
import 'package:dating/services/authentication.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dating/screens/payment_screen.dart';
import 'package:dating/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/widgets/cached_image.dart';

class AccountSetting extends StatefulWidget {
  final User user;
  final VoidCallback logoutCallback;
  final dynamic preferences;
  final String genderPreferences;
  AccountSetting({this.user, this.logoutCallback, this.preferences, this.genderPreferences});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AccountSettingState();
  }
}

class AccountSettingState extends State<AccountSetting> {
  String notifications = "On";
  User user;

  @protected
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Account Settings"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50.0),
              CachedImage(
                user != null ? user.imageUrl : "https://cdn.iconscout.com/icon/free/png-256/account-profile-avatar-man-circle-round-user-30452.png",
                isRound: true,
                radius: height * 0.16,
              ),
              // CircleAvatar(
              //     backgroundImage: user != null ? NetworkImage(user.imageUrl): AssetImage("assets/images/account.png"),
              //     radius: 75.0
              // ),
              SizedBox(height: 20.0),
              Text(user != null ? user.username : "Name", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 16.0)),
              SizedBox(height: 5.0,),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text("from", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 10.0)),
              //     SizedBox(width: 5.0),
              //     Text(widget.user != null ? widget.user.country : "Country", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 15.0)),
              //   ],
              // ),
              SizedBox(height: 50.0),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(
                    user: user
                  )));
                },
                child: Column(
                          children: [
                            Padding(padding: EdgeInsets.only(top: 18.0),),
                            Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(padding: EdgeInsets.only(left: 15.0),),
                              Text("Coins", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16.0)),
                              Spacer(),
                              Text(user.coins.toString(),style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                              SizedBox(width: 5.0),
                              Icon(
                                Icons.monetization_on,
                                color: Colors.yellow,
                                size: 25.0,
                              ),
                              // CircleAvatar(
                              //   foregroundColor: Colors.white,
                              //   backgroundImage: AssetImage("assets/images/coin.png"),
                              //   radius: 10.0
                              // ),
                              SizedBox(width: 10.0)
                            ],
                          ),
                          SizedBox(height: 18.0),
                        ]
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfile(user: user)));
                },
                title: Text("Edit Profile", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
              ),
              Column(
                children: [
                  Padding(padding: EdgeInsets.only(top: 18.0),),
                  Row(
                    children: [
                      Padding(padding: EdgeInsets.only(left: 15.0),),
                      Text("Gender Preferences", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16.0)),
                      Spacer(),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: widget.genderPreferences,
                          items: <String>['Female', 'Male', 'Both'].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            // setState(() {
                            //   genderPreferences = value;
                            // });
                            widget.preferences(value);
                          },
                        ),
                      ),
                      SizedBox(width: 10.0)
                    ],
                  ),
                  SizedBox(height: 18.0),
                ]
              ),
              Column(
                children: [
                  Padding(padding: EdgeInsets.only(top: 18.0),),
                  Row(
                    children: [
                      Padding(padding: EdgeInsets.only(left: 15.0),),
                      Text("Notifications", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16.0)),
                      Spacer(),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: notifications,
                          items: <String>['On', 'Off'].map((String value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              notifications = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10.0)
                    ],
                  ),
                  SizedBox(height: 18.0),
                ]
              ),
              ListTile(
                onTap: () {
                  widget.logoutCallback();
                  Navigator.pushAndRemoveUntil(context, 
                  MaterialPageRoute(builder: (_) => RootPage(auth: new Auth())), (route) => false);
                },
                title: Text("Log Out", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
              )
            ],
          ),
        ),
      ),
    );
  }

  getDetails() async {
    Firestore.instance  
      .collection("users")
      .document(widget.user.userId)
      .snapshots()
      .listen((event) { 
        var updated = User(
          age: event.data["age"],
          coins: event.data["coins"],
          gender: event.data["gender"],
          imageUrl: event.data["imageUrl"],
          username: event.data["name"],
          onVideoCall: event.data["onVideoCall"],
          token: event.data["token"],
          country: event.data["country"],
          userId: widget.user.userId
        );
        setState(() {
          user = updated;
        });
      });
  }

  // getCoins() async {
  //   Firestore.instance
  //     .collection("users")
  //     .document(widget.user.userId)
  //     .get()
  //     .then((value) {
  //       if(mounted) {
  //         setState(() {
  //           widget.user.coins = value.data["coins"];
  //         });
  //       }
  //     });
  // }

}


// 