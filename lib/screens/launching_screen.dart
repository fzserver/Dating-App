import 'package:dating/screens/homePage.dart';
import 'package:dating/screens/sign_in_up_screen.dart';
import 'package:flutter/material.dart';

const double smallFontSize = 18;

class LaunchingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Theme.of(context).accentColor, Theme.of(context).primaryColor], begin: Alignment.topCenter, end: Alignment.bottomCenter)
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FractionallySizedBox(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                  ),
                ),
                Image.asset('assets/images/Heart.png'),
                Text('FlirtMe', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),),
                Text('Online Dating, Meet, Chat & Love', style: TextStyle(fontSize: 16, color: Colors.white),),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                ),
                Text('Start talking anonymously', style: TextStyle(fontSize: 18, color: Colors.white),),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 15),
                  height: MediaQuery.of(context).padding.top * 2,
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: RaisedButton( onPressed: () {Navigator.pushNamed(context, SignUp.routeName);},
                    color: Color(0xFFD9D9D9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Text('Start', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 35),),),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                  child: FractionallySizedBox(
                    widthFactor: MediaQuery.of(context).size.width * 0.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('By Signing in you agree to ', style: TextStyle(color: Colors.white, fontSize: smallFontSize),),
                        Text('privacy policy ', style: TextStyle(color: Colors.white, fontSize: smallFontSize, fontWeight: FontWeight.bold),),
                        Text('And ', style: TextStyle(color: Colors.white, fontSize: smallFontSize),),
                      ],
                    ),
                  ),
                ),
                Text('terms of use.',  style: TextStyle(color: Colors.white, fontSize: smallFontSize, fontWeight: FontWeight.bold),)
              ],
            )
          ],
        )
    );
  }
}
