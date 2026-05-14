import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tracking_controller.dart';
import '../../controllers/auth_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TrackingController trackingCtrl = Get.find<TrackingController>();
    final AuthController authCtrl = AuthController.instance;

    return Scaffold(
      body: Obx(() {
        final log = trackingCtrl.todaysLog.value;
        final user = authCtrl.currentUser.value;

        if (log == null || user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final goals = user.goals;
        double stepProgress = (log.steps / (goals['steps'] ?? 10000)).clamp(0.0, 1.0);

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${user.name.split(' ')[0]} 👋',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Here is your daily summary',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: stepProgress,
                            strokeWidth: 20,
                            strokeCap: StrokeCap.round,
                            backgroundColor: Colors.grey.shade100,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Column(
                          children: [
                            Icon(Icons.directions_walk, size: 40, color: Theme.of(context).primaryColor),
                            const SizedBox(height: 8),
                            Text(
                              '${log.steps}',
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1),
                            ),
                            Text(
                              '/ ${goals['steps']} steps',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(child: _buildSecondaryStat(context, 'Water', '${log.water}L', log.water, goals['water'] ?? 3.0, Icons.water_drop, Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSecondaryStat(context, 'Sleep', '${log.sleep}h', log.sleep, goals['sleep'] ?? 8.0, Icons.bedtime, Colors.deepPurple)),
                ],
              ),
              const SizedBox(height: 16),
              _buildSecondaryStat(context, 'Calories Burned', '${log.calories} kcal', log.calories, goals['calories'] ?? 2000, Icons.local_fire_department, Colors.orange),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSecondaryStat(BuildContext context, String title, String displayValue, num current, num goal, IconData icon, Color color) {
    double progress = (current / (goal == 0 ? 1 : goal)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(displayValue, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}