import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/daily_log_model.dart';
import 'auth_controller.dart';

class TrackingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //rx(reactive)
  Rx<DailyLog?> todaysLog = Rx<DailyLog?>(null);

  String get todayDocId {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  void onInit() {
    super.onInit();
    _listenToTodaysLog();
  }

  void _listenToTodaysLog() {
    final uid = AuthController.instance.currentUser.value?.uid;
    if (uid == null) return;

    _firestore
        .collection('users')
        .doc(uid)
        .collection('logs')
        .doc(todayDocId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        todaysLog.value = DailyLog.fromMap(snapshot.data()!, snapshot.id);
      } else {
        //start of day
        todaysLog.value = DailyLog(date: todayDocId, updatedAt: Timestamp.now());
      }
    });
  }

  //metric add
  Future<void> addMetric(String metricKey, num value) async {
    final uid = AuthController.instance.currentUser.value?.uid;
    if (uid == null) return;

    final docRef = _firestore.collection('users').doc(uid).collection('logs').doc(todayDocId);

    try {
      await docRef.set({
        metricKey: FieldValue.increment(value),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar('Success', 'Updated!', snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update log: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
  //metric edit
  Future<void> editMetric(String metricKey, num exactValue) async {
    final uid = AuthController.instance.currentUser.value?.uid;
    if (uid == null) return;

    final docRef = _firestore.collection('users').doc(uid).collection('logs').doc(todayDocId);

    try {
      await docRef.set({
        metricKey: exactValue,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar('Updated', 'Log corrected!', snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update log: $e');
    }
  }
}