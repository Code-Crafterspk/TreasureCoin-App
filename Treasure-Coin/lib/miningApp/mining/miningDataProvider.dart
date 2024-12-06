import 'package:flutter/material.dart';

class MiningDataProvider extends ChangeNotifier {
  double _hashRate = 0.0; // Hash Rate in MH/s
  int _blocksMined = 0; // Total blocks mined
  double _miningSpeed = 0.0; // Mining Speed in KH/s
  Duration _nextRewardDuration = Duration(days: 0); // Countdown to next reward

  double get hashRate => _hashRate;
  int get blocksMined => _blocksMined;
  double get miningSpeed => _miningSpeed;
  Duration get nextRewardDuration => _nextRewardDuration;

  void updateMiningData(double newHashRate, int newBlocksMined, double newMiningSpeed, Duration newNextRewardDuration) {
    _hashRate = newHashRate;
    _blocksMined = newBlocksMined;
    _miningSpeed = newMiningSpeed;
    _nextRewardDuration = newNextRewardDuration;
    notifyListeners(); // Notify listeners about the changes
  }
}
