import 'dart:ui';

import 'package:dating/widgets/videoCall_widget.dart';
import 'package:dating/utils/functions.dart';
import 'package:dating/utils/permissions.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:dating/models/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:dating/screens/user_chats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/models/chats.dart';
import 'package:dating/widgets/search_widget.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:dating/utils/ads_manager.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dating/widgets/cached_image.dart';

class Messages extends StatefulWidget {
  final User user;
  final VoidCallback logoutCallback;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FirebaseMessaging firebaseMessaging;

  Messages({this.user, this.firebaseMessaging, this.flutterLocalNotificationsPlugin, this.logoutCallback});

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  bool isRewardedAdsReady;
  Map<String, dynamic> updates = {'onCall': 0};
  var channel;
  User receiver;
  bool isRinging = false;
  int noOfAds = 1;
  int coins = 0;

  @protected
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getUpdates();
    super.initState();
    isRewardedAdsReady = true;
    loadRewardedAds();
    RewardedVideoAd.instance.listener = onRewardedAdEvent;
  }

  @override
  void dispose() {
    RewardedVideoAd.instance.listener = null;
    super.dispose();    
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            iconSize: 25.0,
            color: Colors.white,
            onPressed: () {
              showSearch(context: context, delegate: DataSearch(user: widget.user));
            },
          )
        ],
      ),
      body:  (updates["onCall"] == 1 && widget.user.onVideoCall == 0) ? getAlertBox() : Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
//                  borderRadius: BorderRadius.only(
//                    topLeft: Radius.circular(30.0),
//                    topRight: Radius.circular(30.0),
//                  ),
                ),
                child: Column(
                children: [
                  FavoriteContacts(
                      user: widget.user,
                  ),
                  RecentContacts(
                      flutterLocalNotificationsPlugin: widget.flutterLocalNotificationsPlugin,
                      user: widget.user,
                      firebaseMessaging: widget.firebaseMessaging,
                  )
                ],
                ),
            )
          )
        ],
        ),
    );
  }

  Widget FavoriteContacts({User user}) {

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Favorite Contacts",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0
                  ),
                )
              ],
            ),
          ),
          Container(
            height: 120.0,
            child: user != null?StreamBuilder(
              stream: Firestore.instance
                        .collection("users")
                        .document(user.userId)
                        .snapshots(),
              builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        ),
                      );
                      break;
                  default:
                  if (snapshot.data["favourite"].length > 0) {
                    return ListView.builder(
                        padding: EdgeInsets.only(left: 10.0),
                        scrollDirection: Axis.horizontal,
                        itemCount: isRewardedAdsReady ? snapshot.data["favourite"].length + 1 : snapshot.data["favourite"].length,
                        itemBuilder: (BuildContext context, int index) {
                          if (isRewardedAdsReady && index == snapshot.data["favourite"].length) {
                            return GestureDetector(
                              onTap: () {
                                if (noOfAds != 0) {
                                  RewardedVideoAd.instance.show();
                                  noOfAds-=1;
                                } else {
                                  Fluttertoast.showToast(
                                    msg: "You have finished your per day ad limit",
                                    gravity: ToastGravity.BOTTOM
                                  );
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 35.0,
                                      backgroundImage: NetworkImage("https://homagames.com/wp-content/uploads/sites/8/2018/10/loop-box-01-01-01-970x650.png"),
                                    ),
                                    SizedBox(height: 6.0,),
                                    Text(
                                      "Earn Coins",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return StreamBuilder(
                              stream: Firestore.instance
                                  .collection("users")
                                  .document(snapshot.data["favourite"].keys.toList()[index])
                                  .snapshots(),
                              builder: (context, snaps) {
                                switch(snaps.connectionState) {
                                  case ConnectionState.waiting:
                                    return Container();
                                    break;
                                  default:
                                    return GestureDetector(
                                      onTap: () => {
                                        Navigator.push(context, MaterialPageRoute(
                                            builder: (_) => ChatScreen(
                                              flutterLocalNotificationsPlugin: widget.flutterLocalNotificationsPlugin,
                                              block: snapshot.data["favourite"][snapshot.data["favourite"].keys.toList()[index]]["block"],
                                              firebaseMessaging: widget.firebaseMessaging,
                                              senderId: snapshot.data["favourite"].keys.toList()[index],
                                              user: user,
                                              status: snaps.data["active"]??"Online",
                                              sender: User(
                                                  username: snaps.data["name"]??"",
                                                  imageUrl: snaps.data["imageUrl"],
                                                  coins: snaps.data["coins"],
                                                  country: snaps.data["country"],
                                                  age: snaps.data["age"],
                                                  onVideoCall: snaps.data["onVideoCall"],
                                                  token: snaps.data["token"]
                                              ),
                                            )
                                        ))
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Column(
                                          children: [
                                            CachedImage(
                                              snaps.data["imageUrl"],
                                              isRound: true,
                                              radius: 70.0,
                                            ),
                                            // CircleAvatar(
                                            //   radius: 35.0,
                                            //   backgroundImage: NetworkImage(snaps.data["imageUrl"]),
                                            // ),
                                            SizedBox(height: 6.0,),
                                            Text(
                                              snaps.data["name"]??"",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w600
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                            }}
                            );
                          }
                        });
                  } else {
                  return ListView.builder(
                    itemCount: 1,
                    padding: EdgeInsets.only(left: 10.0),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          if (noOfAds != 0) {
                            RewardedVideoAd.instance.show();
                            noOfAds-=1;
                          } else {
                            Fluttertoast.showToast(
                              msg: "You have finished your per day ad limit",
                              gravity: ToastGravity.BOTTOM
                            );
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 35.0,
                                backgroundImage: NetworkImage("https://homagames.com/wp-content/uploads/sites/8/2018/10/loop-box-01-01-01-970x650.png"),
                              ),
                              SizedBox(height: 6.0,),
                              Text(
                                "Earn Coins",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                  }
                } 
              } 
            ):Container(),
          )
        ],
      ),
    );
  }

  loadRewardedAds() {
    RewardedVideoAd.instance.load(
      targetingInfo: MobileAdTargetingInfo(),
      adUnitId: AdsManager.rewardedAdsUnitId
    );
  }

  void onRewardedAdEvent(RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
    switch (event) {
      case RewardedVideoAdEvent.loaded:
        setState(() {
          isRewardedAdsReady = true;
        });
        break;
      case RewardedVideoAdEvent.closed:
        setState(() {
          isRewardedAdsReady = true;
        });
        loadRewardedAds();
        break;
      case RewardedVideoAdEvent.failedToLoad:
        setState(() {
          isRewardedAdsReady = false;
        });
        // print("Failed to load a rewarded ad");
        break;
      case RewardedVideoAdEvent.rewarded:
        getRewardCoins(rewardAmount);
        Fluttertoast.showToast(
            msg: "You have been rewarded with $rewardAmount coins.",
            gravity: ToastGravity.BOTTOM
          );
        // Navigator.pop(context);
        break;
      default:
    }
  }

  Future<void> getRewardCoins(int rewardAmount) async {
    if (widget.user != null) {
      await Firestore.instance
      .collection("users")
      .document(widget.user.userId)
      .get()
      .then((value) {
        updateCoins(rewardAmount, value.data["coins"], widget.user.userId);
      });
      }
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
    if (widget.user != null) {
      if(!mounted) {
      return;
    } else {
      Firestore.instance  
        .collection('video_calls')
        .document(widget.user.userId)
        .snapshots()
        .listen((value)=>{
          setState(() {
            updates = value.data["call"];
            if (updates['onCall'] == 1) {
              isRinging = true;
            } else {
              isRinging = false;
            }
          })
        });
    }
    }
  }
    
}


// class FavoriteContacts extends StatelessWidget {
//   final List<Sender> favorites;
//   final User user;

//   FavoriteContacts({this.user, this.favorites});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 10.0),
//       child: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Favorite Contacts",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18.0,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.0
//                   ),
//                 )
//               ],
//             ),
//           ),
//           Container(
//             height: 120.0,
//             child: user != null?StreamBuilder(
//               stream: Firestore.instance
//                         .collection("users")
//                         .document(user.userId)
//                         .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.data["favourite"].length > 0) {
//                   return ListView.builder(
//                   padding: EdgeInsets.only(left: 10.0),
//                   scrollDirection: Axis.horizontal,
//                   itemCount: snapshot.data["favourite"].length,
//                   itemBuilder: (BuildContext context, int index) {
//                     return StreamBuilder(
//                       stream: Firestore.instance
//                                 .collection("users")
//                                 .document(snapshot.data["favourite"].keys.toList()[index])
//                                 .snapshots(),
//                       builder: (context, snaps) {
//                         switch(snaps.connectionState) {
//                           case ConnectionState.waiting:
//                             return Center(child: Text("Loading ...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)));
//                           default:
//                             return GestureDetector(
//                       onTap: () => {
//                         Navigator.push(context, MaterialPageRoute(
//                           builder: (_) => ChatScreen(
//                             senderId: snapshot.data["favourite"].keys.toList()[index],
//                             user: user,
//                             status: snaps.data["active"]??"Online",
//                             sender: Sender(
//                               name: snaps.data["name"]??"",
//                               imageUrl: snaps.data["imageUrl"]
//                             ),
//                           )
//                         ))
//                       },
//                       child: Padding(
//                         padding: EdgeInsets.all(10.0),
//                         child: Column(
//                           children: [
//                             CircleAvatar(
//                               radius: 35.0,
//                               backgroundImage: NetworkImage(snaps.data["imageUrl"]),
//                             ),
//                             SizedBox(height: 6.0,),
//                             Text(
//                               snaps.data["name"]??"",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16.0,
//                                 fontWeight: FontWeight.w600
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     );
//                         }
//                       },
//                     );
//                   });
//                 } else {
//                   return Center(
//                     child: Text("You haven't chat anyone yet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
//                   );
//                 }
//               },
//             ):Container(),
//           )
//         ],
//       ),
//     );
//   }

// }

class RecentContacts extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final User user;
  final FirebaseMessaging firebaseMessaging;

  RecentContacts({this.user, this.firebaseMessaging, this.flutterLocalNotificationsPlugin});


  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          child: user != null?StreamBuilder(
            stream: Firestore.instance
                .collection("users")
                .document(user.userId)
                .snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    ),
                  );
                  break;
                default:
                  if (snapshot.data["contacts"].length > 0) {
                    return ListView.builder(
                      itemCount: snapshot.data["contacts"].length,
                      itemBuilder: (BuildContext context, int index) {
                        return StreamBuilder(
                            stream: Firestore.instance
                                .collection("users")
                                .document(snapshot.data["contacts"].keys.toList()[index])
                                .snapshots(),
                            builder: (context, snaps) {
                              switch(snaps.connectionState) {
                                case ConnectionState.waiting:
                                  return Container();
                                  break;
                                default:
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChatScreen(
                                            flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
                                            block: snapshot.data["contacts"][snapshot.data["contacts"].keys.toList()[index]]["block"],
                                            firebaseMessaging: firebaseMessaging,
                                            senderId: snapshot.data["contacts"].keys.toList()[index],
                                            user: user,
                                            status: snaps.data["active"]??"Online",
                                            sender: User(
                                                  username: snaps.data["name"]??"",
                                                  imageUrl: snaps.data["imageUrl"],
                                                  coins: snaps.data["coins"],
                                                  country: snaps.data["country"],
                                                  age: snaps.data["age"],
                                                  onVideoCall: snaps.data["onVideoCall"],
                                                  token: snaps.data["token"]
                                              ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(top: 5.0, bottom: 5.0, right: 20.0, left: 20.0),
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFEFEE),
                                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              CachedImage(
                                                snaps.data["imageUrl"],
                                                isRound: true,
                                                radius: 50.0,
                                              ),
                                              // CircleAvatar(
                                              //   radius: 30.0,
                                              //   backgroundImage: NetworkImage(snaps.data["imageUrl"]),
                                              //   // backgroundImage: NetworkImage("https://cdn.icon-icons.com/icons2/1736/PNG/512/4043260-avatar-male-man-portrait_113269.png"),
                                              // ),
                                              SizedBox(width: 10.0),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    snaps.data["name"]??"",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 15.0,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5.0),
                                                  Container(
                                                    width: MediaQuery.of(context).size.width * 0.45,
                                                    child: Text(
                                                      snaps.data["active"]??"Online",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15.0,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          // Column(
                                          //   children: <Widget>[
                                          //     Text(
                                          //       "1:02 pm",
                                          //       style: TextStyle(
                                          //         color: Colors.grey,
                                          //         fontSize: 15.0,
                                          //         fontWeight: FontWeight.bold,
                                          //       ),
                                          //     ),
                                          //     SizedBox(height: 5.0),
                                          //     false
                                          //         ? Container(
                                          //       width: 40.0,
                                          //       height: 20.0,
                                          //       decoration: BoxDecoration(
                                          //         color: Theme.of(context).primaryColor,
                                          //         borderRadius: BorderRadius.circular(30.0),
                                          //       ),
                                          //       alignment: Alignment.center,
                                          //       child: Text(
                                          //         'NEW',
                                          //         style: TextStyle(
                                          //           color: Colors.white,
                                          //           fontSize: 12.0,
                                          //           fontWeight: FontWeight.bold,
                                          //         ),
                                          //       ),
                                          //     )
                                          //         : Text(''),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    ),
                                  );
                              }
                            }
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text("You haven't chat anyone yet", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                    );
                  }               
              }
            },
          ):Container(
          ),
        ),
      ),
    );
  }

}

// if (noOfAds != 0) {
//                                   RewardedVideoAd.instance.show();
//                                   noOfAds-=1;
//                                 } else {
//                                   Fluttertoast.showToast(
//                                     msg: "You have finished your per day ad limit",
//                                     gravity: ToastGravity.BOTTOM
//                                   );
//                                 }
// Center(
//                         child: Text("You haven't chat anyone yet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
//                       );