import 'package:dating/screens/launching_screen.dart';
import 'package:dating/screens/loginScreen.dart';
import 'package:dating/screens/rootPage.dart';
import 'package:flutter/services.dart';
import 'package:dating/screens/sign_in_up_screen.dart';
import 'package:dating/screens/singup_profile.dart';
import 'package:dating/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:dating/screens/homePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlirtMe',
      theme: ThemeData(
        primaryColor: Colors.red,//Color(0xFFec405a),
        accentColor: Color(0xFFed7262),
        unselectedWidgetColor: Colors.grey
      ),
      initialRoute: '/',

      routes: {
        // '/': (context) => SignupProfile(),
        '/': (context) => RootPage(auth: Auth()),
      //  '/': (context) => LaunchingScreen(),
        // LoginScreen.routeName: (context) => LoginScreen(),
        // SignUp.routeName: (context) => SignUp(),
        // HomePage.routeName : (context) => HomePage()
      },
    );
  }
}
