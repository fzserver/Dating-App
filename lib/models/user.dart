class User {
  String username, gender;
  String userId;
  String imageUrl;
  String country;
  int age;
  int onVideoCall;
  String token;
  int coins;

  User({this.token, this.username, this.userId, this.imageUrl, this.country, this.age, this.gender, this.onVideoCall, this.coins=100});

  set(dynamic value) {
    this.username = value["username"];
    this.imageUrl = value["imageUrl"];
    this.age = value["age"];
    this.country = value["country"];
    this.coins = value["coins"];
  }

  Map<String, dynamic> toMap({Map<String, dynamic> contacts, Map<String, dynamic> favourite}) {
    if (contacts == null && favourite == null) {
      return {
        "name": this.username,
        "imageUrl": this.imageUrl,
        "country": this.country,
        "age": this.age,
        "gender": this.gender
      };
    } else {
      return {
        "name": this.username,
        "imageUrl": this.imageUrl,
        "country": this.country,
        "age": this.age,
        "contacts": {},
        "favourite": {}
      };
    }
  }
}

User getBasicUser(String username, String imageUrl, String userId, String token) {
  return User(
    userId: userId,
    username: username,
    imageUrl: imageUrl,
    token: token,
    onVideoCall: 0,
    gender: "male",
    country: "India",
    age: 18,
    coins: 100
  );
}