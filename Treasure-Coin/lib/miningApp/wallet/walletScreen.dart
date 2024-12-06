import 'package:flutter/material.dart';
import 'package:mining/miningApp/utils/constants.dart';
import 'package:mining/miningApp/wallet/walletDataProvider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../mainScreen/mainScreen.dart';

class Walletscreen extends StatefulWidget {
  final PersistentTabController controller;
  const Walletscreen({Key? key, required this.controller}) : super(key: key);

  @override
  _WalletscreenState createState() => _WalletscreenState();
}

class _WalletscreenState extends State<Walletscreen> {
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF07096d),
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(17),
          ),
        ),
        backgroundColor: Color(0xFFffd735),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            widget.controller.jumpToTab(0);
          },
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 28),
              Consumer<WalletProvider>(
                builder: (context, walletProvider, child) => Text(
                  'Treasure Coin Balance : ${walletProvider.walletData.balance}',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontFamily: 'Montserrat',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Provider.of<WalletProvider>(context, listen: false).refreshBalance();
                },
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.yellow),
                    SizedBox(width: 8),
                    Text(
                      'Refresh Balance',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Transaction History',
                style: TextStyle(
                  color: Colors.yellow,
                  fontFamily: 'Montserrat',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 10),
              Consumer<WalletProvider>(
                builder: (context, walletProvider, child) => Text(
                  'Date : ${walletProvider.walletData.transactionDate}\n'
                      'Type : ${walletProvider.walletData.transactionType}\n'
                      'Amount : ${walletProvider.walletData.transactionAmount}\n'
                      'Status : ${walletProvider.walletData.transactionStatus}',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Montserrat',
                    fontSize: 15,
                    height: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Send Treasure Coin Screen',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 10),
              Consumer<WalletProvider>(
                builder: (context, walletProvider, child) => Text(
                  'Recipient Address: ${walletProvider.walletData.recipientAddress}\n'
                      'Amount: ${walletProvider.walletData.amount}\n'
                      'Fee: ${walletProvider.walletData.fee}\n'
                      'Total: ${walletProvider.walletData.total}',
                  style: TextStyle(
                      color: Colors.yellow,
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      height: 2,
                      fontWeight: FontWeight.w500
                  ),
                ),
              ),
              SizedBox(height: 5),
              ElevatedButton(
                onPressed: () {
                  Provider.of<WalletProvider>(context, listen: false).sendTreasureCoin();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.yellow,
                  side: BorderSide(color: Colors.yellow),
                ),
                child: TextButton(
                  onPressed: (){

                  },
                  child: Text(
                    'Send Treasure Coin',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Receive Treasure Coin Screen',
                style: TextStyle(
                  color: Colors.yellow,
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Consumer<WalletProvider>(
                builder: (context, walletProvider, child) => Text(
                  'QR Code Display: (for receiving)\n'
                      'Address: ${walletProvider.walletData.receivingAddress}',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 25),
              Column(
                  children: [ElevatedButton(
                    onPressed: () {
                      Provider.of<WalletProvider>(context, listen: false).withdraw();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFffd735),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.download, color: Colors.black),
                        SizedBox(width: 10),
                        Text(
                          'Withdraw',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ]),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}