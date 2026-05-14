import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/daily_log_model.dart';
import 'auth_controller.dart';

class HistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<DateTime> selectedDate = DateTime.now().obs;
  Rx<DailyLog?> selectedLog = Rx<DailyLog?>(null);
  RxList<DailyLog> weeklyLogs = <DailyLog>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDataForDate(selectedDate.value);
    fetchWeeklyLogs();
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void changeDate(DateTime date) {
    selectedDate.value = date;
    fetchDataForDate(date);
  }

  Future<void> fetchDataForDate(DateTime date) async {
    final uid = AuthController.instance.currentUser.value?.uid;
    if (uid == null) return;

    isLoading.value = true;
    String docId = _formatDate(date);

    try {
      var doc = await _firestore.collection('users').doc(uid).collection('logs').doc(docId).get();
      if (doc.exists && doc.data() != null) {
        selectedLog.value = DailyLog.fromMap(doc.data()!, doc.id);
      } else {
        selectedLog.value = null;
      }
    } finally {
      isLoading.value = false;
    }
  }

  //for chart last 7 days
  Future<void> fetchWeeklyLogs() async {
    final uid = AuthController.instance.currentUser.value?.uid;
    if (uid == null) return;

    DateTime aWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    String startDocId = _formatDate(aWeekAgo);

    try {
      var snapshot = await _firestore.collection('users').doc(uid)
          .collection('logs')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startDocId)
          .get();

      List<DailyLog> logs = snapshot.docs
          .map((doc) => DailyLog.fromMap(doc.data(), doc.id))
          .toList();

      logs.sort((a, b) => a.date.compareTo(b.date));
      weeklyLogs.assignAll(logs);
    } catch (e) {
      debugPrint("Error fetching weekly logs: $e");
    }
  }
}