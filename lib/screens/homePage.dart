import 'package:dating/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:dating/screens/messages.dart';
import 'package:dating/screens/indexPage.dart';
import 'package:dating/screens/account_settings.dart';
import 'package:dating/models/user.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/utils/ads_manager.dart';
import 'package:dating/utils/permissions.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dating/widgets/videoCall_widget.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  final startIndex;
  final String genderPreferences;
  final bool second;
  final List<Map<dynamic, dynamic>> preferences;
  final VoidCallback logoutCallback;
  final FirebaseMessaging firebaseMessaging;
  final String userId;
  static const routeName = "HomePage";

  HomePage({this.firebaseMessaging, this.userId, this.logoutCallback, this.startIndex, this.genderPreferences, this.preferences, this.second});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  User user;
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  int selectedPageIndex = 1;
  List<Map<String, Object>> pages;
  List<dynamic> persons;
  List<Map<dynamic, dynamic>> preferences;
  String genderPreferences = "Both";
  // bool isRewardedAdsReady;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed) {
      setIsActive(widget.userId, "Online");
    } else {
      setLastSeen(widget.userId);
    }
  }

  @protected
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  static Future<dynamic> backgroundMessageHandler(Map<String, dynamic> message) async {
      print("AppPushs backgroundMessageHandler: $message");
      await showNotification(message);
      return Future<void>.value();
  }

  @override
  void initState() {
    if (widget.preferences != null && widget.genderPreferences != null) {
      preferences = widget.preferences;
      genderPreferences = widget.genderPreferences;
    }
    selectedPageIndex = widget.startIndex;
    setIsActive(widget.userId, "Online");
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    getUser();
    registerNotification();
    configLocalNotification();
    FirebaseAdMob.instance.initialize(appId: AdsManager.appId);
    persons = [];
  }

  @override
  void dispose() {
    RewardedVideoAd.instance.listener = null;
    WidgetsBinding.instance.removeObserver(this);
    setLastSeen(widget.userId);
    super.dispose();
  }

  getUser() async {
    await getUserProfile(widget.userId).then((value) {
      setState(() {
        user = value;
      });
      widget.firebaseMessaging.getToken().then((token) => {
        setState(() { 
          user.token = token;
        }),
        Firestore.instance
          .collection('users')
          .document(user.userId)
          .updateData({
            'token': token
          })
      });
    });
    await randomCall();
  }

  setGenderPreferences(String gender) {
    setState(() {
      genderPreferences = gender;
    });
  }

  selectPage(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }

  void registerNotification() {
    widget.firebaseMessaging.requestNotificationPermissions();
    // firebaseMessaging.getToken().then((value) {
    //   print("Push messaging token: $value");
    // });
    widget.firebaseMessaging.configure(
      onBackgroundMessage: backgroundMessageHandler,
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        await showNotification(message);
        // flutterLocalNotificationsPlugin.cancelAll();
        return;
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        var data = message["data"];
        if (data.containsKey("senderName") && data.containsKey("senderImageUrl")) {
          flutterLocalNotificationsPlugin.cancelAll();
          deleteNotifications();
          showDialog(
            context: context,
            builder: (_) => Center(
                    child: SizedBox(
                    height: 400,
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
                          backgroundImage: NetworkImage(data["senderImageUrl"]),
                          radius: 60.0,
                        ),
                        SizedBox(height: 25.0),
                        Text("${data["senderName"]} is calling ...", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
                        SizedBox(height: 25.0),
                        Text("${data["senderCountry"]}", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 15.0)),
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
                                flutterLocalNotificationsPlugin.cancelAll();
                                cancelVideoCall(widget.userId);
                                Navigator.pop(context);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.call),
                              iconSize: 25.0,
                              color: Colors.green,
                              onPressed: () {
                                flutterLocalNotificationsPlugin.cancelAll();
                                acceptCall(data["channel"]);
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
              ),
            ),
          );
          // navigateToHome(data);
          // await showNotification(message);
        }
        return;
      },
      onLaunch: (Map<String, dynamic> message)  async {
        print("onLaunch: $message");
        var data = message["data"];
        if (data.containsKey("senderName") && data.containsKey("senderImageUrl")) {
          flutterLocalNotificationsPlugin.cancelAll();
          deleteNotifications();
          // await showNotification(message);
          showDialog(
            context: context,
            builder: (_) => Center(
                    child: SizedBox(
                    height: 400,
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
                          backgroundImage: NetworkImage(data["senderImageUrl"]),
                          radius: 60.0,
                        ),
                        SizedBox(height: 25.0),
                        Text("${data["senderName"]} is calling ...", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
                        SizedBox(height: 25.0),
                        Text("${data["senderCountry"]}", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 15.0)),
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
                                flutterLocalNotificationsPlugin.cancelAll();
                                cancelVideoCall(widget.userId);
                                Navigator.pop(context);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.call),
                              iconSize: 25.0,
                              color: Colors.green,
                              onPressed: () {
                                flutterLocalNotificationsPlugin.cancelAll();
                                acceptCall(data["channel"]);
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
              ),
            ),
          );
          // navigateToHome(data);
        }
        return;
      }
    );
  }

  void configLocalNotification() {
    var initializationSettingAndroid = new AndroidInitializationSettings('flirtme');
    var initializationSettingIos = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingAndroid, initializationSettingIos);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: selectNotification);
  }

  static showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'randomchat.dating.flirtme.dating',
      'FlirtMe',
      'your channel description',
      playSound: true,
      enableLights: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    
    Future.delayed(Duration.zero, () {
      flutterLocalNotificationsPlugin.show(
        0,
        message['notification']['title'].toString(),
        message['notification']['body'].toString(),
        platformChannelSpecifics,
        payload: json.encode(message)
      );
    });
    
    await Firestore.instance  
      .collection('notification')
      .getDocuments()
      .then((value) => {
        for(DocumentSnapshot ds in value.documents) {
          ds.reference.delete()
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    pages = [
      {"page": VideoCalls(flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin, logoutCallback: widget.logoutCallback, firebaseMessaging: widget.firebaseMessaging, userId: widget.userId, user: user, preferences: preferences, genderPreferences: genderPreferences, second: widget.second), "title": ""},
      {"page": Messages(firebaseMessaging: widget.firebaseMessaging, user: user, flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin, logoutCallback: widget.logoutCallback), "title": "Chats"},
      {"page": AccountSetting(user: user, logoutCallback: widget.logoutCallback, preferences: setGenderPreferences, genderPreferences: genderPreferences), "title": "Account"}
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        color: Colors.transparent,
        height:(MediaQuery
            .of(context)
            .size
            .height - MediaQuery
            .of(context)
            .padding
            .top - MediaQuery
            .of(context)
            .padding
            .bottom) * 0.1,
        child: BottomNavigationBar(
            elevation: 0,
            onTap: selectPage,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            backgroundColor: Colors.transparent,
            unselectedItemColor: Colors.black,
            selectedItemColor: Theme.of(context).primaryColor,
            currentIndex: selectedPageIndex,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.phone), title: Text(''),
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.chat), title: Text('')
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), title: Text('')
              )]
        ),
      ),
      body: pages[selectedPageIndex]["page"],
    );
  }

  randomCall() async{
    if(user != null) {
      await getFilterResults(user).then((value) async {
      await getUserDetails(user.userId).then((currentUser) {
        List<Map<dynamic, dynamic>> preference = [];
        value.documents.forEach((element) {
          if((!currentUser.data["contacts"].containsKey(element.documentID) && user.userId != element.documentID) && element.data["active"] == "Online") {
            // ids.add(element.documentID);
            preference.add({
              "userId": element.documentID,
              "gender": element.data["gender"]
            });
          }
        });
        setState(() {
          preferences = preference;
          // persons = ids;
        });
      });
    });
    }
  }
  Future selectNotification(String payload) async {
    var data = Map.from(json.decode(payload));
    // print("Payload: ${data["data"]}");
    navigateToHome(data["data"]);
  }

  Future navigateToHome(Map<String, dynamic> payload) async {
    // debugPrint("payload: $payload");
    deleteNotifications();
    // await showNotification(message);
    showDialog(
      context: context,
      builder: (_) => Center(
              child: SizedBox(
              height: 400,
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
                    backgroundImage: NetworkImage(payload["senderImageUrl"]),
                    radius: 60.0,
                  ),
                  SizedBox(height: 25.0),
                  Text("${payload["senderName"]} is calling ...", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
                  SizedBox(height: 25.0),
                  Text("${payload["senderCountry"]}", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 15.0)),
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
                          flutterLocalNotificationsPlugin.cancelAll();
                          cancelVideoCall(widget.userId);
                          Navigator.pop(context);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.call),
                        iconSize: 25.0,
                        color: Colors.green,
                        onPressed: () {
                          flutterLocalNotificationsPlugin.cancelAll();
                          acceptCall(payload["channel"]);
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
        ),
      ),
    );
    await Firestore.instance  
      .collection('notification')
      .getDocuments()
      .then((value) => {
        for(DocumentSnapshot ds in value.documents) {
          ds.reference.delete()
        }
      });
    // Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(
    //   startIndex: 0,
    //   genderPreferences: genderPreferences,
    //   preferences: preferences,
    //   logoutCallback: widget.logoutCallback,
    //   firebaseMessaging: widget.firebaseMessaging,
    //   userId: widget.userId,
    //   second: widget.second,
    // )));
  }

  void acceptCall(String channel) async {
    await Permissions.cameraAndMicrophonePermissionGranted()?Navigator.push(context, MaterialPageRoute(builder: (context) => VideoCalling(
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      channelName: channel,
      role: ClientRole.Broadcaster,
      receiver: user,
      firebaseMessaging: widget.firebaseMessaging,
      user: user,
      logoutCallback: widget.logoutCallback,
    ))):
    Fluttertoast.showToast(
      msg:"Please give the permission for Camera and Mic",
      gravity: ToastGravity.BOTTOM
    );
  }

}
