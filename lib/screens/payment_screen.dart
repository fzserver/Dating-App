import 'package:dating/models/user.dart';
import 'package:flutter/material.dart';
import 'package:dating/widgets/payment_money.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentScreen extends StatefulWidget {
  final User user;
  PaymentScreen({this.user});
  static const routeName = "paymentscreen";
  @override
  PaymentScreenState createState() => PaymentScreenState();
}
class PaymentScreenState extends State<PaymentScreen> {

  @override
  void initState() {
    super.initState();
    getCoins();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        width: double.infinity,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.04),
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white,),
                      iconSize: 22.0,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: screenHeight * 0.125),
                    Text("MY COINS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25))
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.04,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monetization_on,
                    color: Colors.yellow,
                  ),
                  SizedBox(width: screenHeight * 0.04,),
                  Text(widget.user.coins.toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.0),)
                ],
              ),
              SizedBox(height: screenHeight * 0.04,),
              Text("In order to send more messages, to receive more matches", style: TextStyle(color: Colors.white)),
              Text(" and for many more, buy coins", style: TextStyle(color: Colors.white)),
              SizedBox(height: screenHeight * 0.04),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Card(
                        color: Colors.grey.shade100,
                        child: PaymentMoney(
                          coins: 300, 
                          money:49,
                          user: widget.user,
                        ),
                      ),
                      Card(
                        color: Colors.grey.shade100,
                        child: PaymentMoney(
                          coins: 1200, 
                          money: 199,
                          user: widget.user,
                        ),
                      ),
                      Card(
                        color: Colors.grey.shade100,
                        child: PaymentMoney(
                          coins: 2500, 
                          money: 1599,
                          user: widget.user,
                        ),
                      ),
                      Card(
                        color: Colors.grey.shade100,
                        child: PaymentMoney(
                          coins: 7100, 
                          money: 3999,
                          user: widget.user,
                        ),
                      ),
                      Card(
                        color: Colors.grey.shade100,
                        child: PaymentMoney(
                          coins: 15000, 
                          money: 7999,
                          user: widget.user,
                        ),
                      ),
                      Card(
                        color: Colors.grey.shade100,
                        child: PaymentMoney(
                          coins: 35000, 
                          money: 15999,
                          user: widget.user,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  getCoins() async {
    Firestore.instance
      .collection("users")
      .document(widget.user.userId)
      .get()
      .then((value) {
        if(mounted) {
          setState(() {
            widget.user.coins = value.data["coins"];
          });
        }
      });
  }

}