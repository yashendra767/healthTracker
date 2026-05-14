import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_controller.dart';
import '../models/user_model.dart';

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = AuthController.instance;

  Future<void> updateGoal(String goalKey, num newValue) async {
    final UserModel? user = _authController.currentUser.value;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'goals.$goalKey': newValue,
      });

      //local state update
      Map<String, num> updatedGoals = Map.from(user.goals);
      updatedGoals[goalKey] = newValue;

      UserModel updatedUser = UserModel(
        uid: user.uid,
        name: user.name,
        goals: updatedGoals,
      );

      _authController.currentUser.value = updatedUser;

      Get.snackbar('Success', 'Goal updated successfully', snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update goal: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}