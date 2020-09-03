import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:async';
import 'package:dating/widgets/cached_image.dart';
import 'package:dating/models/user.dart';
import 'package:random_string/random_string.dart';
import 'package:dating/utils/functions.dart';
import 'package:dating/screens/homePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class VideoCalling extends StatefulWidget {
  /// non-modifiable channel name of the page
  final List<Map<dynamic, dynamic>> preferences;
  final String genderPreferences;
  final VoidCallback logoutCallback;
  final String channelName;
  final User receiver, user;
  final FirebaseMessaging firebaseMessaging;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  /// non-modifiable client role of the page
  final ClientRole role;

  /// Creates a call page with given channel name.
  const VideoCalling({Key key, @required this.channelName, @required this.role, @required this.receiver, @required this.user, @required this.firebaseMessaging, this.logoutCallback, this.preferences, this.genderPreferences, this.flutterLocalNotificationsPlugin}) : super(key: key);

  @override
  VideoCallingState createState() => VideoCallingState();
}

class VideoCallingState extends State<VideoCalling> {
  final String appId = "58bf16e08f01405aa246e5d48843984c";
  static final _users = <int>[];
  final _infoStrings = <String>[];
  int time = 15;
  int coins = 0;
  bool isStarted = false;
  bool muted = false;
  Timer timers;

  @protected
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  timer() async {
    timers = Timer(const Duration(seconds: 1), () async {
      setState(() {
        time--;
      });
      if (time != 0) {
        timer();
      } else {
        if (isStarted == false) {
          widget.flutterLocalNotificationsPlugin.cancelAll();
          await updateProfile(widget.user.userId, {"onVideoCall": 0});
          await cancelVideoCall(widget.receiver.userId);
          Fluttertoast.showToast(
            msg: "Didn't connect",
            gravity: ToastGravity.BOTTOM
          );
          if (widget.logoutCallback != null && widget.preferences != null) {
            navigatorToHome(true);
          }
           else {
             Navigator.pop(context);
           }
          
        }
      }
    });
  }

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    cancelVideoCall(widget.receiver.userId);
    timers.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk

    updateProfile(widget.user.userId, {"onVideoCall": 1});
    if (widget.receiver.userId != widget.user.userId) {
      notify(widget.receiver);
      callUser(widget.receiver.userId, widget.user.userId, widget.channelName);
      addUserToContacts(widget.user.userId, widget.receiver.userId, widget.receiver.username);
    }
    getCoins();
    initialize();
    if (widget.user.userId != widget.receiver.userId) {
      timer();
    }
  }

  initialize() async {
    if (appId.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    AgoraRtcEngine.enableWebSdkInteroperability(true);
    AgoraRtcEngine.setParameters('{\"che.video.lowBitRateStreamParameter\"' + ':{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}');
    // VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    // configuration.dimensions = Size(1920, 1080);
    // await AgoraRtcEngine.setVideoEncoderConfiguration(configuration);
    AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    AgoraRtcEngine.create(appId);
    AgoraRtcEngine.enableVideo();
    AgoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    AgoraRtcEngine.setClientRole(widget.role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onUserMuteAudio = (int uid, bool muted) {
      if (muted) {
        Fluttertoast.showToast(
          msg: "User has been muted",
          gravity: ToastGravity.BOTTOM
        );
      } else {
        Fluttertoast.showToast(
          msg: "User has been unmuted",
          gravity: ToastGravity.BOTTOM
        );
      }
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      _onCallEnd(context);
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      updateUserCoins();
      setState(() {
        isStarted = true;
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      _onCallEnd(context);
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(AgoraRenderWidget(0, local: true, preview: true));
    }
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    // final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height;
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[
            Expanded(
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 25.0),
                      CachedImage(
                        // "https://avatarfiles.alphacoders.com/126/126244.jpg",
                        widget.receiver.imageUrl,
                        isRound: true,
                        radius: 100.0,
                      ),
                      SizedBox(height: 10.0),
                      Text("Connecting ...", style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w600))
                    ],
                  ),
                ),
            ),
            _videoView(views[0]),
            ],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[1]]),
            _expandedVideoRow([views[0]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    if (widget.role == ClientRole.Audience) return Container();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  void _onCallEnd(BuildContext context) async {
    await updateProfile(widget.user.userId, {"onVideoCall": 0});
    await cancelVideoCall(widget.receiver.userId);
    if (widget.logoutCallback != null) {
      navigatorToHome(false);
    } else {
      Navigator.pop(context);
    }
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade600,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            _toolbar(),
          ],
        ),
      ),
    );
  }

  Future<void> getCoins() async {
    await Firestore.instance
      .collection("users")
      .document(widget.user.userId)
      .get()
      .then((value) {
        setState(() {
          coins = value.data["coins"];
        });
      });
  }

  Future<void> setCallingDuration() async {
    Timer(const Duration(seconds: 5), () {
      setState(() {
        coins -= 10;
      });
    });
  }

  Future<void> updateUserCoins() async {
    // await getCoins();
    if (coins > 50 && widget.receiver.coins > 50) {
      // setCallingDuration();
      if (widget.user.userId != widget.receiver.userId) {
        if(mounted) {
          setState(() {
            coins = coins - 50;
          });
        }
        await Firestore.instance
                .collection("users")
                .document(widget.user.userId)
                .updateData({
                  "coins": coins
                });
        await Firestore.instance  
          .collection("users")
          .document(widget.receiver.userId)
          .updateData({
            "coins": widget.receiver.coins - 50
          });
      }
      // updateUserCoins();
    } else {
      _onCallEnd(context);
      // await updateProfile(widget.user.userId, {"onVideoCall": 0});
      // await cancelVideoCall(widget.receiver.userId);
      Fluttertoast.showToast(
        msg: "You have no coins left in your account you must have atleast 50 coins in your account, Please buy more coins to send more messages and get more video calls",
        gravity: ToastGravity.BOTTOM
      );
      // Navigator.pop(context);
    }
  }

  void notify(User receiver) async {
    await Firestore.instance
        .collection("notification")
        .document(randomString(10))
        .setData({
          'content': '${receiver.username} is calling you',
          'receiverToken': receiver.token,
          'title': "You have a notification from ${widget.user.username}",
          'senderName': widget.user.username,
          'senderImageUrl': receiver.imageUrl,
          'senderCountry': receiver.country,
          'channel': widget.channelName
        });
  }

  void navigatorToHome(bool second) {
    if (second) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomePage(
        startIndex: 0,
        second: true,
        preferences: widget.preferences,
        genderPreferences: widget.genderPreferences,
        logoutCallback: widget.logoutCallback,
        firebaseMessaging: widget.firebaseMessaging,
        userId: widget.user.userId,
      )), (route) => false);
    } else {
       Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomePage(
          startIndex: 0,
          preferences: widget.preferences,
          genderPreferences: widget.genderPreferences,
          logoutCallback: widget.logoutCallback,
          firebaseMessaging: widget.firebaseMessaging,
          userId: widget.user.userId,
        )), (route) => false);
    }
  }

}

// Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child:_videoView(views[1]),
//             ),  //_expandedVideoRow([views[1]])
//             // Positioned(
//             //     top: height * 0.63,
//             //     left: width * 0.65,
//             //     child: ClipRRect(
//             //       borderRadius: BorderRadius.circular(10.0),
//             //       child: Container(
//             //       width: width * 0.3,
//             //       height: height * 0.22,
//             //       child: _videoView(views[1]),
//             //       ),
//             //     ), //_expandedVideoRow([views[0]])
//             // ),