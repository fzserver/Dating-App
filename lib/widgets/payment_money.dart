import 'package:flutter/material.dart';
import 'package:dating/widgets/payment.dart';
import 'package:dating/models/user.dart';

class PaymentMoney extends StatelessWidget {
  final int money;
  final int coins;
  final User user;

  PaymentMoney({this.coins, this.money, this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom) * 0.08,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => Payment(totalAmount: money, user: user, coins: coins))
          );
        },
        child: ListTile(
          trailing: Text("₹ ${money.toString()}"),
          title: Text(coins.toString()),
          leading: Icon(
              Icons.monetization_on, 
              color: Colors.orangeAccent,
            ),
        ),
      ),
    );
  }
}