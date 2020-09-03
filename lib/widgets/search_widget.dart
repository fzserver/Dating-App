import 'package:dating/models/chats.dart';
import 'package:dating/screens/user_chats.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dating/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';


class DataSearch extends SearchDelegate<String> {
  final User user;
  DataSearch({this.user});
  @override
  List<Widget> buildActions(BuildContext context) {
      // TODO: implement buildActions
      return [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          },
        )
      ];
    }
  
    @override
    Widget buildLeading(BuildContext context) {
      // TODO: implement buildLeading
      return IconButton(
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow,
            progress: transitionAnimation
          ),
          onPressed: () {
            close(context, null);
          },
        );
    }
  
    @override
    Widget buildResults(BuildContext context) {
      // TODO: implement buildResults
      return buildSuggestions(context);
    }
  
    @override
    Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return StreamBuilder(
      stream: Firestore.instance
              .collection("users")
              .snapshots(),
      builder: (context, snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            );
          default: 
            return ListView.builder(
          itemCount: snapshot.data.documents.length,
          itemBuilder: (BuildContext context, int index) {
            var username = snapshot.data.documents[index]["name"];
            if (query.isNotEmpty && username != null) {
              if (username.toLowerCase().startsWith(query) && username != user.username) {
                return InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(
                        block: false,
                        status: "Online",
                        senderId: snapshot.data.documents[index].documentID,
                        user: user,
                        sender: User(
                          username: username,
                          imageUrl: snapshot.data.documents[index]["imageUrl"],
                          age: snapshot.data.documents[index]["age"],
                          country: snapshot.data.documents[index]["country"],
                        ),
                      )));
                    },
                    child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data.documents[index]["imageUrl"]),
                          radius: 20.0,
                        ),
                        SizedBox(width: 20.0),
                        Text(username, style: TextStyle(fontSize: 20.0))
                      ],
                    ),
                  ),
                );
              } else {
                return SizedBox(height: 0.0);
              }
            } else {
                return SizedBox(height: 0.0);
            }
          },
        );
        }
      },
    );
  }

}