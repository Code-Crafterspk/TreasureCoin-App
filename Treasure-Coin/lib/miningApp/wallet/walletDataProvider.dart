import 'package:flutter/foundation.dart';

class WalletProvider with ChangeNotifier {
  WalletModel _walletData = WalletModel();

  WalletModel get walletData => _walletData;

  void updateWalletData(WalletModel newData) {
    _walletData = newData;
    notifyListeners();
  }

  void refreshBalance() {
    // Implement the logic to refresh balance here
    // For example:
    _walletData.balance = '${(double.parse(_walletData.balance) + 1).toStringAsFixed(3)}';
    notifyListeners();
  }

  void sendTreasureCoin() {
    // Implement the logic to send treasure coin here
    notifyListeners();
  }

  void withdraw() {
    // Implement the logic for withdrawal here
    notifyListeners();
  }
}

class WalletModel {
  String balance;
  String transactionDate;
  String transactionType;
  String transactionAmount;
  String transactionStatus;
  String recipientAddress;
  String amount;
  String fee;
  String total;
  String receivingAddress;

  WalletModel({
    this.balance = 'XXX.XXX',
    this.transactionDate = 'xxxx-xx-xx',
    this.transactionType = 'Mining Reward, Sent, Received',
    this.transactionAmount = 'xxx',
    this.transactionStatus = 'confirmed/pending',
    this.recipientAddress = 'xxx',
    this.amount = 'xxx',
    this.fee = 'xxx',
    this.total = 'xxx',
    this.receivingAddress = 'xx',
  });
}
