import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dating/models/user.dart';
import 'package:dating/utils/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Payment extends StatefulWidget {
  final int totalAmount;
  final User user;
  final int coins;
  Payment({@required this.totalAmount, this.user, this.coins});
  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  Razorpay razorpay;

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    updateCoins(widget.coins, widget.user.coins, widget.user.userId);
    Fluttertoast.showToast(msg: "Payment Success");
    Fluttertoast.showToast(msg: "It will reflected in your profile after sometime");
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "ERROR: " + response.code.toString() + " - " + response.message);
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "EXTERNAL_WALLET: " + response.walletName);
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_test_PVbcgwzwxvBafl',
      'amount': widget.totalAmount*100,
      'name': 'Crush',
      'description': 'Buy merchent',
      'prefill': {'contact': '', 'email': ''},
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 25.0),
            Card(
              color: Colors.grey.shade100,
              child: FlatButton(
                child: Text("Make Payment of ${widget.totalAmount}", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 25.0, fontWeight: FontWeight.bold)),
                onPressed: () {
                  openCheckout();
                },
              ),
            ),
          ],
        )
      ),
    );
  }

}