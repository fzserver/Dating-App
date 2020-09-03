import 'dart:async';

import 'package:dating/utils/constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/models/user.dart';
import 'dart:io';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

Future<String> loadCountries(BuildContext context) async {
    return await rootBundle.loadString("assets/countries.txt");
  }

Future<DocumentSnapshot> checkUser(String userId) async {
  var user = await Firestore.instance
    .collection("users")
    .document(userId)
    .get();
  return user;
}

Future<User> getUserProfile(String userId) async => await Firestore.instance
    .collection("users")
    .document(userId)
    .get()
    .then((value) {
      var user;
      user = User(
        username: value.data["name"],
        userId: userId,
        imageUrl: value.data["imageUrl"],
        country: value.data["country"],
        age: value.data["age"],
        gender: value.data["gender"],
        onVideoCall: value.data["onVideoCall"],
        token: value.data["token"],
        coins: value.data["coins"]
      );
      return user;
    });

Future<DocumentSnapshot> getUserDetails(String userId)  async {

  var userProfile =  await Firestore.instance
    .collection("users")
    .document(userId)
    .get();
  return userProfile;
}
void deleteNotifications() async {
  await Firestore.instance  
    .collection('notification')
    .getDocuments()
    .then((value) => {
      for(DocumentSnapshot ds in value.documents) {
        ds.reference.delete()
      }
    });
}
Future<void> callUser(String receiverId, currentUserId, channel) async {
  await Firestore.instance
    .collection("video_calls")
    .document(receiverId)
    .setData({
      "call": {
        "channel": channel,
        "userId": currentUserId,
        "onCall":1
      }
    });
}

Future<void> cancelVideoCall(String userId) async {
  await Firestore.instance
    .collection("video_calls")
    .document(userId)
    .setData({
      "call": {
        "onCall": 0
      }
    });
}

Future<void> createUserProfile(User user) async {
  await Firestore.instance
    .collection("users")
    .document(user.userId)
    .setData({
      "name": user.username,
      "age": user.age,
      "country": user.country,
      "imageUrl": user.imageUrl,
      "gender": user.gender,
      "favourite": {},
      "contacts": {},
      "token": user.token,
      "onVideoCall": 0,
      "coins": 100,
      "active": "Online",
      "about": ""
    });
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String getChatId(String currentUserNo, String peerNo) {
  if (currentUserNo.hashCode <= peerNo.hashCode) {
    return '$currentUserNo-$peerNo';
  } else {
    return '$peerNo-$currentUserNo';
  }
}

Future<String> uploadProfilePic(File file, String filename) async {
  StorageReference storageReference = FirebaseStorage.instance.ref().child("images/$filename");
  final StorageUploadTask uploadTask = storageReference.putFile(file);
  final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
  final String url = (await downloadUrl.ref.getDownloadURL());
  return url;
}

Future<void> addVideoCalls(String userId) async {
  var userRef = Firestore.instance
    .collection("video_calls")
    .document(userId);
  userRef.get().then((value) {
    if (!value.exists) {
      Firestore.instance
        .collection("video_calls")
        .document(userId)
        .setData(
          {
            "call": {
              "onCall": 0
            }
          }
        );
    }
  });
}

Future<void> addUserToContacts(String userId, senderId, name) async {
    await Firestore.instance
      .collection("users")
      .document(userId)
      .get()
      .then((value) {
        if(!value.data["contacts"].containsKey(senderId)) {
          Firestore.instance
          .collection("users")
          .document(userId)
          .setData({
            "contacts": {
              senderId: {
                "name": name,
                "block": false
              }
            }
          }, merge: true);
        }
      });
      
}

Future<void> blockOrUnblock(String senderId, String userId, String name, bool block) async {
  await Firestore.instance
    .collection("users")
    .document(userId)
    .setData({
      "contacts": {
        senderId: {
          "name": name,
          "block": block
        }
      }
    }, merge: true);
  await Firestore.instance  
    .collection("users")
    .document(userId)
    .setData({
      "favourite": {
        senderId: {
          "block": block
        }
      }
    }, merge: true);
}

Stream<QuerySnapshot> getQuery(String senderId, String userId) {
    var chatId = getChatId(userId, senderId);
    return Firestore.instance
            .collection("chats")
            .document(chatId)
            .collection(chatId)
            .snapshots();
  }

Future<void> updateUserProfile(String userId, field, dynamic map) async {
  await Firestore.instance
    .collection("users")
    .document(userId)
    .updateData({
      field: getSortedMap(map)
    });
}

Future<void> updateProfile(String userId, dynamic map) async {
  await Firestore.instance
    .collection("users")
    .document(userId)
    .updateData(
      map
    );
}

Map<String, dynamic> getSortedMap(dynamic map) {
  var values = map.keys.toList()..sort();
  var reversed = values.reversed;
  Map<String, dynamic> favours = {};
  reversed.forEach((value) {
    favours.addAll({
      map[value]["userId"]: {
        "block": map[value]["block"],
        "count": value
      }
    });
  });
  return favours;
}

Future<QuerySnapshot> getFilterResults(User user) async {
  var query = await Firestore.instance
    .collection("users")
    .getDocuments();
  return query;
}

String getCurrentTimeAndDate() {
    var dateandtime = DateTime.now();
    return DateFormat().add_MMMd().add_jm().format(dateandtime);
}

Future<Map<String, dynamic>> notify(FirebaseMessaging firebaseMessaging, String name, receiverToken) async {
  var serverToken = "AAAAp_dSzhI:APA91bGQoJwWdNGZUiuYrues4514vp5P3dR9rheTNVnJafqVJ0O5j2-Je43h85SodAlGuYlxgTJM20imu8-lZCP9bjC_v9PX3XxpAhi4eSEA-YWkbwssIitjlTWUZptCn1125QSsxrn5";
  await firebaseMessaging.requestNotificationPermissions(
    const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false)
  );

  await http.post(
    'https://fcm.googleapis.com/fcm/send',
     headers: <String, String>{
       'Content-Type': 'application/json',
       'Authorization': 'key=$serverToken',
     },
     body: jsonEncode(
       <String, dynamic>{
         'notification':<String, dynamic>{
           'body': "$name has been calling you",
           'title': "Video Call",
           'sound': 'default'
         },
         'priority': 'high',
         'data': <String, dynamic>{
           'click_action': 'FLUTTER_NOTIFICATION_CLICK',
           'id': 1,
           'status': 'done'
         },
          'to': receiverToken
       }
     )
  );
  final Completer<Map<String, dynamic>> completer = Completer<Map<String, dynamic>>();
  firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      completer.complete(message);
    }
  );
  return completer.future;

}

Future<void> updateCoins(int coins, int userCoins, String userId) async {
      await Firestore.instance
        .collection("users")
        .document(userId)
        .updateData({
          "coins": coins+userCoins
        });
  }

void setIsActive(String userId, String status) async {
    await Firestore.instance
        .collection("users")
        .document(userId)
        .setData({
      "active": status
    }, merge: true);
}

  void setLastSeen(String userId) async {
    await Firestore.instance
        .collection("users")
        .document(userId)
        .setData({
      "active": "Last seen: " + getCurrentTimeAndDate()
    }, merge: true);
  }

// reduceCoins(String userId) async {
//   await Firestore.instance
//     .collection("users")
//     .document(userId)
//     .get()
//     .then((value) => {
//       if (value.data["coins"] > 50) {
//         Firestore.instance 
//         .collection("users")
//         .document(userId)
//         .updateData({
//           "coins": value.data["coins"]-50
//         })
//       } else {

//       }
//     });
// }

