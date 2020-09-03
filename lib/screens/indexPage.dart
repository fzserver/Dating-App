import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/utils/functions.dart';
import 'package:dating/models/user.dart';
import 'package:dating/utils/permissions.dart';
import 'dart:math';
import 'package:dating/widgets/videoCall_widget.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:dating/screens/homePage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dating/widgets/ripple_animation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

class VideoCalls extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final VoidCallback logoutCallback;
  final bool second;
  final User user;
  final String userId;
  final FirebaseMessaging firebaseMessaging;
  final List<Map<dynamic, dynamic>> preferences;
  final String genderPreferences;
  VideoCalls({this.flutterLocalNotificationsPlugin, this.user, this.userId, this.preferences, this.genderPreferences, this.firebaseMessaging, this.logoutCallback, this.second});
  @override
  _VideoCallsState createState() => _VideoCallsState();
}

class _VideoCallsState extends State<VideoCalls> {
  List<Map<dynamic, dynamic>> filter_users = []; 
  Map<String, dynamic> updates = {"onCall": 0};
  Random random = Random();
  String callId, channelName;
  int timeOutInSecs = 3;
  bool callButton = false;
  bool isRinging = false;
  User receiver;
  int currentUserIndex=0;
  Timer timer;
  var channel;
  var imageUrl = "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRXZ3IntbJ5izhGtL3CiU1sw8hDM4sh3Bxumw&usqp=CAU";

  @protected
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    // randomCall();
    super.initState();
    if(widget.genderPreferences != null && widget.preferences != null) {
      if(widget.genderPreferences != "Both") {
        filter_users = widget.preferences.where((element) => element["gender"] == widget.genderPreferences.toLowerCase()).toList();
      } else {
        setState(() { 
          filter_users = widget.preferences;
        });
      }
    }
    getUpdates();
    timerUpdate();
    // updateVideoCallInfo(widget.userId);
  }

  timerUpdate() async {
    timer = Timer(const Duration(seconds: 1), () async {
      if(mounted) {
        setState(() {
          timeOutInSecs--;
        });
      }
      if (timeOutInSecs != 0) {
        timerUpdate();
      } else {
        if(mounted) {
          if (widget.second == null) {
             setState(() {
              callButton = true;
            });
          } else if (widget.second != null && widget.second) {
            callUser();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Video Calls"),
      ),
      body: (updates["onCall"] == 1 && widget.user.onVideoCall == 0) ? getAlertBox() : Container(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Stack(
              children: [
                    Align(
                      alignment: Alignment.center,
                      child: callButton?RippleAnimation(
                        color: Theme.of(context).primaryColor,
                        onPressed: () async {
                          callUser();
                        },
                        //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomePage(
                        //     startIndex: 1,
                        //     logoutCallback: widget.logoutCallback,
                        //     firebaseMessaging: widget.firebaseMessaging,
                        //     userId: widget.user.userId,
                        //   )), (route) => false);
                        // }
                      ):CircularProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void playRingtone() async {
    if (isRinging) {
      if(await Vibration.hasVibrator()) {
        Vibration.vibrate();
      }
    }
    // if (await Vibration.hasVibrator()) {
    //   Vibration.vibrate();
    // }
  }

  void stopRingtone() {
    Vibration.cancel();
    // if (await Vibration.hasVibrator()) {
    //   Vibration.cancel();
    // }
  }

  Widget getAlertBox() {
    updateUserDetails();
    if (receiver != null) {
      playRingtone();
      return Center(
          child: SizedBox(
          height: 335.0,
            child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25),
                    ),
            ),
            content: Column(
              children: [
                SizedBox(height: 10.0),
                CircleAvatar(
                  backgroundImage: NetworkImage(receiver.imageUrl),
                  radius: 60.0,
                ),
                SizedBox(height: 25.0),
                Text("${receiver.username} is calling ...", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
                SizedBox(height: 25.0),
                Text("${receiver.country}", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 15.0)),
                SizedBox(height: 25.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.call_end),
                      iconSize: 25.0,
                      color: Colors.red,
                      onPressed: () {
                        setState(() {
                          isRinging = false;
                        });
                        stopRingtone();
                        cancelVideoCall(widget.user.userId);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.call),
                      iconSize: 25.0,
                      color: Colors.green,
                      onPressed: () {
                        setState(() {
                          isRinging = false;
                        });
                        stopRingtone();
                        acceptCall();
                      },
                    )
                  ],
                ),
              ]
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  void acceptCall() async {
    await Permissions.cameraAndMicrophonePermissionGranted()?Navigator.push(context, MaterialPageRoute(builder: (context) => VideoCalling(
      flutterLocalNotificationsPlugin: widget.flutterLocalNotificationsPlugin,
      channelName: channel,
      role: ClientRole.Broadcaster,
      receiver: widget.user,
      firebaseMessaging: widget.firebaseMessaging,
      user: widget.user,
      logoutCallback: widget.logoutCallback,
    ))):
    Fluttertoast.showToast(
      msg:"Please give the permission for Camera and Mic",
      gravity: ToastGravity.BOTTOM
    );
  }

  getRandomUsers() async {
    if(mounted) {
      if (filter_users.length > 0) {
        setState(() {
          var index = random.nextInt(filter_users.length);
          callId = filter_users[index]["userId"];
          channelName = randomString(filter_users.length+1);
          currentUserIndex = index;
        });
      } else {
        Fluttertoast.showToast(
          msg: "No users are online",
          gravity: ToastGravity.BOTTOM
        );
      }
    }
  }

  // randomCall() {
  //   if(widget.user != null) {
  //     getFilterResults(widget.user).then((value) {
  //     getUserDetails(widget.user.userId).then((currentUser) {
  //       var ids = [];
  //       value.documents.forEach((element) {
  //         if(!currentUser.data["contacts"].containsKey(element.documentID)) {
  //             ids.add(element.documentID);
  //         }
  //       });
  //       if(mounted) {
  //         setState(() {
  //           callId = ids[random.nextInt(ids.length)];
  //           channelName = randomString(ids.length+1);
  //         });
  //       }
  //     });
  //   });
  //   }
  // }

  Future<void> updateUserDetails() async {
     await getUserProfile(updates["userId"]).then((value) {
       if(mounted) {
         setState(() {
          receiver = value;
        });
       }
    });
    if (mounted) {
       setState(() {
        channel = updates["channel"];
      });
    }
  }

  Future<void> getUpdates() async {
    if(!mounted) {
      return;
    } else {
      Firestore.instance
      .collection("video_calls")
      .document(widget.userId)
      .snapshots()
      .listen((value) => {
        setState(() {
          updates = value.data["call"];
          if (updates["onCall"] == 1) {
            isRinging = true;
          } else {
            isRinging = false;
          }
        })
      });
    }
  }

  String randomString(int length) {
   var rand = new Random();
   var codeUnits = new List.generate(
      length, 
      (index){
         return rand.nextInt(33)+89;
      }
   );
   
   return new String.fromCharCodes(codeUnits);
  }

  void callUser() async {
    await getRandomUsers();
    if (channelName != null && filter_users.length > 0) {
      await getUserProfile(callId).then((value) {
        setState(() {
          receiver = value;
        });
      });
      filter_users.removeAt(currentUserIndex);
      await Permissions.cameraAndMicrophonePermissionGranted()?Navigator.push(context, MaterialPageRoute(builder: (context) => VideoCalling(
        flutterLocalNotificationsPlugin: widget.flutterLocalNotificationsPlugin,
        channelName: channelName,
        role: ClientRole.Broadcaster,
        receiver: receiver,
        user: widget.user,
        firebaseMessaging: widget.firebaseMessaging,
        preferences: filter_users,
        genderPreferences: widget.genderPreferences,
        logoutCallback: widget.logoutCallback,
      ))):
      Fluttertoast.showToast(
        msg:"Please give the permission for Camera and Mic",
        gravity: ToastGravity.BOTTOM
      );
    } else {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomePage(
        startIndex: 1,
        preferences: widget.preferences,
        genderPreferences: widget.genderPreferences,
        logoutCallback: widget.logoutCallback,
        firebaseMessaging: widget.firebaseMessaging,
        userId: widget.user.userId,
      )), (route) => false);
    }
  }

}

// callButton?RippleAnimation(
//                         color: Theme.of(context).primaryColor,
//                         onPressed: () async {
//                           await getRandomUsers();
//                           if (channelName != null) {
//                             await getUserProfile(callId).then((value) {
//                               setState(() {
//                                 receiver = value;
//                               });
//                             });
//                             await Permissions.cameraAndMicrophonePermissionGranted()?Navigator.push(context, MaterialPageRoute(builder: (context) => VideoCalling(
//                               channelName: channelName,
//                               role: ClientRole.Broadcaster,
//                               receiver: receiver,
//                               user: widget.user,
//                               firebaseMessaging: widget.firebaseMessaging,
//                               logoutCallback: widget.logoutCallback,
//                             ))):
//                             Fluttertoast.showToast(
//                               msg:"Please give the permission for Camera and Mic",
//                               gravity: ToastGravity.BOTTOM
//                             );
//                           }
//                         }
//                       ):
// Text("Loading Contacts ...", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20.0, fontWeight: FontWeight.w500))