import 'package:cloud_firestore/cloud_firestore.dart';

class DailyLog {
  final String date; //yyyy-MM-dd
  final int steps;
  final double water;
  final int calories;
  final double sleep;
  final Timestamp updatedAt;

  DailyLog({
    required this.date,
    this.steps = 0,
    this.water = 0.0,
    this.calories = 0,
    this.sleep = 0.0,
    required this.updatedAt,
  });

  factory DailyLog.fromMap(Map<String, dynamic> map, String documentId) {
    return DailyLog(
      date: documentId,
      steps: map['steps']?.toInt() ?? 0,
      water: (map['water'] ?? 0.0).toDouble(),
      calories: map['calories']?.toInt() ?? 0,
      sleep: (map['sleep'] ?? 0.0).toDouble(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }
}