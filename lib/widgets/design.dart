import 'package:flutter/material.dart';

class Design extends StatelessWidget {

  Design(this.title, this.selectImage);
  final String title;
  final String selectImage;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
            left: 30,
            child: Image.asset('assets/images/Line5.png',)),
        Positioned(
            left: 180, height: 100,
            child: Opacity(
                opacity: 0.6,
                child: Image.asset('assets/images/Line5.png'))),
        Positioned(
            left: title == "Sign Up"?MediaQuery.of(context).size.width * 0.27:MediaQuery.of(context).size.width * 0.18, height: MediaQuery.of(context).size.height * 0.25, top: MediaQuery.of(context).size.height * 0.4,
            child: Column(
              children: <Widget>[
                Image.asset(selectImage, height: MediaQuery.of(context).size.height * 0.2,)
              ],
            )),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.32, top: MediaQuery.of(context).size.height * 0.17,
          child: Text(title, style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white,),
          ),
        ),
      ] ,
    );
  }
}
