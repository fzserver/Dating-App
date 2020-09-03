import 'package:dating/models/chats.dart';
import 'package:flutter/material.dart';
import 'package:dating/utils/functions.dart';
import 'package:dating/models/user.dart';

class ProfileImageWidget extends StatelessWidget {
  final User sender;
  ProfileImageWidget({this.sender});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white70,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10.0),
          CircleAvatar(
            backgroundImage: NetworkImage(sender.imageUrl),
            radius: 75.0,
          ),
          SizedBox(height: 20.0),
          Text(
            "${sender.username}, ${sender.age}",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25.0),
          ),
          SizedBox(height: 10.0),
          Text("India", style: TextStyle(fontSize: 20.0))
        ],
      ),
    );

  }

}