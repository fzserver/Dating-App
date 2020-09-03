
class Chat {
  bool unread = true;
  final String text;
  final String time;
  final Sender sender;

  Chat({this.text, this.time, this.sender});

}

class Sender {
  final String imageUrl;
  final String name;

  Sender({this.imageUrl, this.name});

}
