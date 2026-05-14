import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tracking_controller.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TrackingController controller = Get.find<TrackingController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Track Today')),
      body: Obx(() {
        final log = controller.todaysLog.value;

        return ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            const Text(
              'Quick Log',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildInteractiveCard(
              context,
              title: 'Steps',
              icon: Icons.directions_walk,
              color: Colors.green,
              metricKey: 'steps',
              currentValue: log?.steps ?? 0,
              isDouble: false,
              unit: 'steps',
            ),
            const SizedBox(height: 16),
            _buildInteractiveCard(
              context,
              title: 'Water',
              icon: Icons.water_drop,
              color: Colors.blue,
              metricKey: 'water',
              currentValue: log?.water ?? 0.0,
              isDouble: true,
              unit: 'Liters',
            ),
            const SizedBox(height: 16),
            _buildInteractiveCard(
              context,
              title: 'Calories',
              icon: Icons.local_fire_department,
              color: Colors.orange,
              metricKey: 'calories',
              currentValue: log?.calories ?? 0,
              isDouble: false,
              unit: 'kcal',
            ),
            const SizedBox(height: 16),
            _buildInteractiveCard(
              context,
              title: 'Sleep',
              icon: Icons.bedtime,
              color: Colors.deepPurple,
              metricKey: 'sleep',
              currentValue: log?.sleep ?? 0.0,
              isDouble: true,
              unit: 'Hours',
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInteractiveCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required String metricKey,
        required num currentValue,
        required bool isDouble,
        required String unit,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    '$currentValue $unit',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                IconButton(
                  onPressed: () => _showDialog(context, title, metricKey, isDouble, isEdit: true, currentValue: currentValue),
                  icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                  tooltip: 'Edit Total',
                ),
                Container(
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: IconButton(
                    onPressed: () => _showDialog(context, title, metricKey, isDouble, isEdit: false),
                    icon: const Icon(Icons.add, color: Colors.white),
                    tooltip: 'Add More',
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String metricKey, bool isDouble, {required bool isEdit, num? currentValue}) {
    final TextEditingController inputController = TextEditingController(text: isEdit ? currentValue?.toString() : '');
    final String actionText = isEdit ? 'Set Exact' : 'Add to';

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
              Text('$actionText $title', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                isEdit ? 'Correct the total amount for today.' : 'How much did you just do?',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: inputController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter amount...',
                  suffixIcon: isEdit ? IconButton(icon: const Icon(Icons.clear), onPressed: () => inputController.clear()) : null,
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
                      final text = inputController.text.trim().replaceAll(',', '');
                      if (text.isEmpty) return;

                      double? parsedDouble = double.tryParse(text);

                      if (parsedDouble == null) {
                        Get.snackbar(
                          'Invalid Input',
                          'Please enter a valid number.',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      num finalValue = isDouble ? parsedDouble : parsedDouble.toInt();
                      Get.back();
                      if (isEdit) {
                        Get.find<TrackingController>().editMetric(metricKey, finalValue);
                      } else {
                        Get.find<TrackingController>().addMetric(metricKey, finalValue);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                      child: Text(isEdit ? 'Save Changes' : 'Log It'),
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