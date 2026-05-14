import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userCtrl = Get.put(UserController());
    final AuthController authCtrl = AuthController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Obx(() {
        final user = authCtrl.currentUser.value;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.verified, color: Theme.of(context).primaryColor, size: 28),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(user.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            ),

            const SizedBox(height: 48),

            const Text('Daily Targets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),

            _buildGoalTile(context, userCtrl, 'Steps', 'steps', user.goals['steps'], Icons.directions_walk, Colors.green, false, 'steps'),
            _buildGoalTile(context, userCtrl, 'Water', 'water', user.goals['water'], Icons.water_drop, Colors.blue, true, 'L'),
            _buildGoalTile(context, userCtrl, 'Calories', 'calories', user.goals['calories'], Icons.local_fire_department, Colors.orange, false, 'kcal'),
            _buildGoalTile(context, userCtrl, 'Sleep', 'sleep', user.goals['sleep'], Icons.bedtime, Colors.deepPurple, true, 'hours'),

            const SizedBox(height: 48),

            TextButton.icon(
              onPressed: () => _showLogoutDialog(authCtrl),
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }

  Widget _buildGoalTile(BuildContext context, UserController ctrl, String title, String goalKey, num? currentValue, IconData icon, Color color, bool isDouble, String unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${currentValue?.toString() ?? '0'} $unit',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
              child: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _showEditGoalDialog(context, ctrl, title, goalKey, currentValue, isDouble),
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, UserController ctrl, String title, String goalKey, num? currentValue, bool isDouble) {
    final TextEditingController inputController = TextEditingController(text: currentValue?.toString() ?? '');

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit $title Target', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Set a new daily goal for yourself.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              TextField(
                controller: inputController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter new goal...',
                  suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () => inputController.clear()),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final text = inputController.text.trim();
                      if (text.isEmpty) return;

                      num? newValue = isDouble ? double.tryParse(text) : int.tryParse(text);
                      if (newValue == null) {
                        Get.snackbar('Invalid Input', 'Please enter a valid number');
                        return;
                      }

                      Get.back();
                      ctrl.updateGoal(goalKey, newValue);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                      child: const Text('Save Goal'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(AuthController authCtrl) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text('Log Out?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Are you sure you want to log out?', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        authCtrl.logout();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text('Log Out'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}