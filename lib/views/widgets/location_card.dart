import 'package:flutter/material.dart';
import '../../models/location_model.dart';

class LocationCard extends StatelessWidget {
  final LocationModel? location;
  final bool isLive;

  const LocationCard({
    super.key,
    required this.location,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (location == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Icons.location_off_rounded, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'No Location Recorded Yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Start the background service to fetch coordinates and store them in Native SQLite.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final loc = location!;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        isLive
                            ? Icons.my_location_rounded
                            : Icons.history_rounded,
                        color: isLive ? Colors.green : Colors.deepPurple,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isLive
                              ? 'Live Location (Service)'
                              : 'Last Location (SQLite DB)',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLive
                        ? Colors.green.withOpacity(0.15)
                        : Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isLive ? 'LIVE' : 'CACHED',
                    style: TextStyle(
                      color: isLive ? Colors.green.shade800 : Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildDetailTile(
                    label: 'Latitude',
                    value: loc.latitude.toStringAsFixed(6),
                    icon: Icons.explore,
                  ),
                ),
                Expanded(
                  child: _buildDetailTile(
                    label: 'Longitude',
                    value: loc.longitude.toStringAsFixed(6),
                    icon: Icons.compass_calibration,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailTile(
                    label: 'Accuracy',
                    value: '${loc.accuracy.toStringAsFixed(1)} m',
                    icon: Icons.gps_fixed,
                  ),
                ),
                Expanded(
                  child: _buildDetailTile(
                    label: 'Timestamp',
                    value: loc.formattedTime,
                    icon: Icons.access_time_rounded,
                  ),
                ),
              ],
            ),
            if (loc.id != null) ...[
              const SizedBox(height: 8),
              Text(
                'SQLite Entry ID: #${loc.id}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.deepPurple.shade300),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
