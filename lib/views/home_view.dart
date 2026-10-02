import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/location_controller.dart';
import 'widgets/location_card.dart';
import 'widgets/location_history_list.dart';

class HomeView extends GetView<LocationController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Tracking'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh DB Data',
            onPressed: controller.refreshData,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.currentLocation.value == null &&
            controller.locationHistory.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Permission Warning Banner if missing
                if (!controller.hasPermission.value) ...[
                  _buildPermissionBanner(context),
                  const SizedBox(height: 16),
                ],

                // 2. Foreground Service Control Card
                _buildServiceControlCard(context),

                const SizedBox(height: 20),

                // 3. Last Fetched Location Card
                const Text(
                  'Current / Last Fetched Location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                LocationCard(
                  location: controller.currentLocation.value,
                  isLive: controller.isServiceRunning.value,
                ),

                const SizedBox(height: 24),

                // 4. Native SQLite Database History Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Location History (${controller.locationHistory.length})',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (controller.locationHistory.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Clear DB'),
                        onPressed: () {
                          Get.dialog(
                            AlertDialog(
                              title: const Text('Clear SQLite Database'),
                              content: const Text(
                                'Are you sure you want to delete all stored location entries from the Android native database?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    controller.clearHistory();
                                  },
                                  child: const Text(
                                    'Clear',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                LocationHistoryList(locations: controller.locationHistory),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPermissionBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade400),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Location Permission Needed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Grant location permissions so Android FusedLocationProviderClient can record coordinates.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: controller.requestPermission,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              foregroundColor: Colors.white,
            ),
            child: const Text('Grant'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceControlCard(BuildContext context) {
    final isRunning = controller.isServiceRunning.value;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isRunning
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  child: Icon(
                    isRunning ? Icons.radar : Icons.power_settings_new,
                    color: isRunning ? Colors.green : Colors.red,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRunning
                            ? 'Background Service Running'
                            : 'Background Service Stopped',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isRunning
                            ? 'Native FusedLocationProviderClient is recording location every 5 seconds.'
                            : 'Tap start to launch Kotlin Foreground Service.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRunning
                      ? Colors.red.shade700
                      : Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
                label: Text(
                  isRunning
                      ? 'Stop Location Service'
                      : 'Start Location Service',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                onPressed: controller.toggleService,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
