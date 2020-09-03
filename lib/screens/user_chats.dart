import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/models/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:dating/utils/permissions.dart';
import 'package:flutter/material.dart';
import 'package:dating/models/chats.dart';
import 'package:flutter/rendering.dart';
import 'package:dating/utils/functions.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dating/widgets/profileImageWidget.dart';
import 'package:dating/widgets/videoCall_widget.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:dating/utils/constants.dart';
import 'package:dating/widgets/cached_image.dart';
import 'package:dating/screens/payment_screen.dart';

class ChatScreen extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final bool block;
  final String senderId;
  final User sender;
  final User user;
  final FirebaseMessaging firebaseMessaging;
  final String status;
//
  ChatScreen(
      {this.senderId,
      this.user,
      this.sender,
      this.status,
      this.firebaseMessaging,
      this.block,
      this.flutterLocalNotificationsPlugin});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool block = false;
  String status;
  Map<int, dynamic> favourites = {};
  final FocusNode focusNode = FocusNode();
  final ScrollController controller = ScrollController();
  final messageTextController = TextEditingController();
  final db = Firestore.instance.collection("chats");
  int noOfChats = 0;
  static int myCoin;
  int coins, receiverCoins = 0;
  User receiver;
  String chatId;
  String messageText = "";
  bool isShowStickers;
  List<Widget> bottomButton;
  List<String> stickers, stickerCoins;

  @protected
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    myCoin = widget.user.coins;
    status = widget.status;
    initializeStickers();
    super.initState();
    focusNode.addListener(onFocusChange);
    block = widget.block;
    isShowStickers = false;
    chatId = getChatId(widget.user.userId, widget.senderId);
    addUserToContacts(
        widget.user.userId, widget.senderId, widget.sender.username);
    addUserToContacts(
        widget.senderId, widget.user.userId, widget.user.username);
    update();
    setIsActive(widget.user.userId, "Online");
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowStickers = false;
      });
    }
  }

  void getSticker() {
    focusNode.unfocus();
    setState(() {
      isShowStickers = !isShowStickers;
    });
  }

  Future<bool> onBackPress() {
    setIsActive(widget.user.userId, "Online");
    if (isShowStickers) {
      setState(() {
        isShowStickers = false;
      });
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    updateUserProfile(widget.user.userId, "favourite", favourites);
    return WillPopScope(
      onWillPop: onBackPress,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Container(
                padding: EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      iconSize: 20.0,
                      color: Colors.white,
                      onPressed: () {
                        setIsActive(widget.user.userId, "Online");
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(
                      width: 2.0,
                    ),
                    InkWell(
                      customBorder: CircleBorder(),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ProfileImageWidget(sender: widget.sender);
                            });
                      },
                      child: CachedImage(
                        widget.sender.imageUrl,
                        isRound: true,
                        radius: 40.0,
                      ),
                      // child: CircleAvatar(
                      //   backgroundImage: NetworkImage(widget.sender.imageUrl),
                      //   radius: 25.0,
                      // ),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.sender.username,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                          SizedBox(
                            height: 6.0,
                          ),
                          Text(
                            status,
                            style:
                                TextStyle(fontSize: 12.0, color: Colors.white),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            elevation: 0.0,
            backgroundColor: Theme.of(context).primaryColor,
            actions: [
              IconButton(
                icon: Icon(Icons.videocam),
                iconSize: 25.0,
                color: Colors.white,
                onPressed: () async {
                  await updateUserDetails();
                  await Permissions.cameraAndMicrophonePermissionGranted()
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VideoCalling(
                                  flutterLocalNotificationsPlugin:
                                      widget.flutterLocalNotificationsPlugin,
                                  channelName: widget.senderId,
                                  firebaseMessaging: widget.firebaseMessaging,
                                  role: ClientRole.Broadcaster,
                                  receiver: receiver,
                                  user: widget.user)))
                      : Fluttertoast.showToast(
                          msg: "Please give the permission for Camera and Mic",
                          gravity: ToastGravity.BOTTOM);
                },
              ),
              PopupMenuButton<bool>(
                child: Padding(
                    padding: EdgeInsets.only(right: width * 0.04),
                    child:
                        Icon(Icons.more_vert, size: 25.0, color: Colors.white)),
                onSelected: (value) async {
                  setState(() {
                    block = !block;
                  });
                  await blockOrUnblock(widget.senderId, widget.user.userId,
                      widget.sender.username, block);
                },
                itemBuilder: (context) {
                  return <PopupMenuEntry<bool>>[
                    PopupMenuItem(
                      child: Container(
                          width: width * 0.25,
                          child: !block
                              ? Text("Block User",
                                  style: TextStyle(fontSize: 16.0))
                              : Text("Unblock User",
                                  style: TextStyle(fontSize: 16.0))),
                      value: true,
                    )
                  ];
                },
              )
            ],
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            setIsActive(widget.user.userId, "Online");
          },
          child: Column(
            children: [
              Expanded(
                  child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: StreamBuilder(
                    stream: Firestore.instance
                        .collection("chats")
                        .document(chatId)
                        .collection(chatId)
                        .orderBy("timestamp", descending: true)
                        .snapshots(),
                    builder: (context, snapshots) {
                      switch (snapshots.connectionState) {
                        case ConnectionState.waiting:
                          return Center(
                              child: Text("Loading ...",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w500)));
                        default:
                          if (snapshots.hasData) {
                            return ListView.builder(
                              controller: controller,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: snapshots.data.documents.length,
                              reverse: true,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 20.0),
                              itemBuilder: (BuildContext context, int index) {
                                return MessageBubble(
                                  stickers: stickers,
                                  type: snapshots.data.documents[index]["type"],
                                  time: snapshots.data.documents[index]["time"],
                                  text: snapshots.data.documents[index]
                                      ["content"],
                                  isMe: snapshots.data.documents[index]
                                          ["from"] ==
                                      widget.user.userId,
                                );
                              },
                            );
                          } else {
                            return Container(color: Colors.white);
                          }
                      }
                    }),
              )),
              (isShowStickers ? buildStickers() : Container()),
              !block
                  ? buildMessageComposer()
                  : Container(
                      color: Colors.white,
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: width * 0.05,
                              right: width * 0.02,
                              bottom: height * 0.01),
                          child: Text(
                              "User has been blocked, unblock from the above options",
                              style: TextStyle(
                                  color: Colors.black26, fontSize: 25.0),
                              overflow: TextOverflow.clip)))
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStickers() {
    var width = MediaQuery.of(context).size.width;
    return Flexible(
      flex: 1,
      fit: FlexFit.tight,
      child: Container(
        height: 50.0,
        color: Colors.white,
        child: GridView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 8.0 / 9.0,
              crossAxisSpacing: 1.0,
              mainAxisSpacing: 1.0),
          itemCount: stickers.length + bottomButton.length,
          itemBuilder: (context, i) {
            if (i < stickers.length) {
              return RawMaterialButton(
                shape: CircleBorder(),
                onPressed: () {
                  if (coins > int.parse(stickerCoins[i])) {
                    sendSticker(i);
                    setState(() {
                      coins -= int.parse(stickerCoins[i]);
                      if (receiverCoins != 0) {
                        receiverCoins += int.parse(stickerCoins[i]);
                      }
                    });
                    updateCoins();
                  } else {
                    Fluttertoast.showToast(
                        msg:
                            "You have no coins left in your account, Please buy more coins to send more messages.",
                        gravity: ToastGravity.BOTTOM);
                  }
                },
                child: Column(
                  children: [
                    Image(
                      image: AssetImage(stickers[i]),
                      width: 50.0,
                      height: 50.0,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 2.0),
                    Padding(
                      padding: EdgeInsets.only(left: width * 0.1),
                      child: Row(
                        children: [
                          Icon(Icons.monetization_on,
                              size: 15.0, color: Colors.yellow),
                          SizedBox(width: 4.0),
                          Text(stickerCoins[i],
                              style: TextStyle(color: Colors.black))
                        ],
                      ),
                    )
                  ],
                ),
              );
            } else {
              return bottomButton[i - (stickers.length)];
            }
          },
        ),
      ),
    );
  }

  Widget buildMessageComposer() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      // color: Colors.brown,
      child: Material(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 5.0),
            ),
            IconButton(
              icon: !isShowStickers
                  ? Image(image: AssetImage(gift_box))
                  : Icon(Icons.close),
              iconSize: 25.0,
              color: Theme.of(context).primaryColor,
              onPressed: getSticker,
            ),
            Expanded(
              child: TextField(
                onTap: () async {
                  setIsActive(widget.user.userId, "typing ....");
                },
                onEditingComplete: () async {
                  setIsActive(widget.user.userId, "Online");
                },
                controller: messageTextController,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (value) {
                  messageText = value;
                },
                decoration:
                    InputDecoration.collapsed(hintText: "Send a message..."),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              iconSize: 25.0,
              color: Theme.of(context).primaryColor,
              onPressed: () async {
                if (messageText.isEmpty) {
                  Fluttertoast.showToast(
                      msg: "Nothing to send", gravity: ToastGravity.BOTTOM);
                } else {
                  // print(coins);
                  if (coins > 10) {
                    onSendMessage(messageText);
                    setState(() {
                      coins -= 5;
                      if (receiverCoins != 0) {
                        receiverCoins -= 5;
                      }
                    });
                    updateCoins();
                  } else {
                    setState(() {
                      messageTextController.text = "";
                    });
                    Fluttertoast.showToast(
                        msg:
                            "You have no coins left in your account, Please buy more coins to send more messages.",
                        gravity: ToastGravity.BOTTOM);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void sendSticker(int index) async {
    await db.document(chatId).collection(chatId).add({
      "type": 1,
      "from": widget.user.userId,
      "to": widget.senderId,
      "content": index.toString(),
      "time": getCurrentTimeAndDate(),
      "timestamp": DateTime.now().millisecondsSinceEpoch
    });

    setState(() {
      noOfChats += 1;
    });
  }

  void onSendMessage(String content) async {
    // type: 0 for message and 1 for sticker
    if (content != null) {
      await db.document(chatId).collection(chatId).add({
        "type": 0,
        "from": widget.user.userId,
        "to": widget.senderId,
        "content": content.trim(),
        "time": getCurrentTimeAndDate(),
        "timestamp": DateTime.now().millisecondsSinceEpoch
      });

      setState(() {
        messageText = "";
        messageTextController.text = "";
        noOfChats += 1;
      });
    } else {
      Fluttertoast.showToast(
          msg: "Nothing to send", gravity: ToastGravity.BOTTOM);
    }
  }

  Future<void> update() async {
    await Firestore.instance
        .collection("users")
        .document(widget.user.userId)
        .get()
        .then((value) {
      var contacts = value.data["contacts"].keys.toList();
      contacts.forEach((element) {
        getQuery(element.toString(), widget.user.userId).forEach((elems) {
          // print(element.toString() + " " +  elems.documents.length.toString());
          setState(() {
            noOfChats += elems.documents.length;
            favourites.addAll({
              elems.documents.length: {
                'block': value.data["contacts"][element]["block"],
                'userId': element.toString()
              }
            });
          });
        });
      });
    });
    await getCoins();
    updateStatus();
  }

  Future<void> updateCoins() async {
    await Firestore.instance
        .collection("users")
        .document(widget.user.userId)
        .updateData({"coins": coins});
    await Firestore.instance
        .collection("users")
        .document(widget.senderId)
        .updateData({"coins": receiverCoins});
  }

  Future<void> getCoins() async {
    await Firestore.instance
        .collection("users")
        .document(widget.user.userId)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          coins = value.data["coins"];
        });
      }
    });
    await Firestore.instance
        .collection("users")
        .document(widget.senderId)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          receiverCoins = value.data["coins"];
        });
      }
    });
  }

  Future<void> updateUserDetails() async {
    await getUserProfile(widget.senderId).then((value) {
      if (mounted) {
        setState(() {
          receiver = value;
        });
      }
    });
  }

  void updateStatus() async {
    Firestore.instance
        .collection("users")
        .document(widget.senderId)
        .snapshots()
        .listen((event) {
      if (mounted) {
        setState(() {
          status = event.data["active"];
        });
      }
    });
  }

  void initializeStickers() {
    stickerCoins = [
      "2500",
      "10000",
      '1000',
      '75',
      '300',
      '5000',
      '750',
      '2000',
      '50',
      '4000',
      '500',
      '3000',
      '30',
      '150',
      '1500'
    ];
    bottomButton = [
      RawMaterialButton(
        elevation: 1.0,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => PaymentScreen(user: widget.user)));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.monetization_on, color: Colors.yellow, size: 25.0),
            SizedBox(width: 2.0),
            Text("Purchase",
                style: TextStyle(color: Colors.black, fontSize: 15.0))
          ],
        ),
        shape: RoundedRectangleBorder(),
        fillColor: Colors.white,
      ),
      RawMaterialButton(
        onPressed: () {},
        elevation: 0.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.monetization_on, color: Colors.yellow, size: 15.0),
            SizedBox(width: 2.0),
            Text("$myCoin My Coins",
                style: TextStyle(color: Colors.black, fontSize: 12.0))
          ],
        ),
        shape: RoundedRectangleBorder(),
        fillColor: Colors.white,
      )
    ];
    stickers = [
      bracelet,
      car,
      champagne,
      chocolate,
      cigar,
      crown,
      heart_gift_box,
      heels,
      lollipop,
      necklace,
      perfume,
      ring,
      rose,
      rose_box,
      treasure
    ];
  }
}

class MessageBubble extends StatelessWidget {
  final List<String> stickers;
  final int type;
  final String time;
  final String text;
  final bool isMe;

  MessageBubble({this.time, this.text, this.isMe, this.type, this.stickers});

  List<Widget> getMessage(context) {
    return type == 0
        ? [
            Text(
              time,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black54,
              ),
            ),
            Material(
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0))
                  : BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
              elevation: 3.0,
              color: isMe ? Colors.white : Theme.of(context).accentColor,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  text,
                  style: TextStyle(
                    color: isMe ? Colors.black : Colors.white,
                    fontSize: 15.0,
                  ),
                ),
              ),
            ),
          ]
        : [
            Text(
              time,
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.black54,
              ),
            ),
            Material(
              elevation: 0.0,
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Image(
                  image: AssetImage(stickers[int.parse(text)]),
                  height: 100.0,
                  width: 100.0,
                ),
              ),
            )
          ];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: getMessage(context),
      ),
    );
  }
}
