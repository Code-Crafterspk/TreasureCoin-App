import 'package:flutter/material.dart';

class DataProvider with ChangeNotifier {
  // Dummy data
  String estimatedReward = '\$1000';
  String rewardDate = '2024-10-15';
  String referralLink = 'https://treasurecoin.com/ref';
  int friendsJoined = 5;
  double commissionEarned = 250.0;
  double referralRewards = 75.0;
  List<Map<String, dynamic>> topMiners = [
    {'name': 'JohnDoe', 'amount': 10000},
    {'name': 'JaneDoe', 'amount': 8000},
    {'name': 'BobSmith', 'amount': 7000},
  ];

  // Optional: Add methods to update the state and notify listeners
  void updateData() {
    // Update the dummy data as needed
    notifyListeners();
  }
}
// factory MiningData.fromJson(Map<String, dynamic> json) {
// return MiningData(
// estimatedReward: json['estimatedReward'] ?? '',
// rewardDate: json['rewardDate'] ?? '',
// referralLink: json['referralLink'] ?? '',
// friendsJoined: json['friendsJoined'] ?? 0,
// commissionEarned: (json['commissionEarned'] ?? 0).toDouble(),
// referralRewards: (json['referralRewards'] ?? 0).toDouble(),
// topMiners: List<String>.from(json['topMiners'] ?? []),
// );
// }