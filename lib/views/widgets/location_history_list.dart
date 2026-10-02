import 'package:flutter/material.dart';
import '../../models/location_model.dart';

class LocationHistoryList extends StatelessWidget {
  final List<LocationModel> locations;

  const LocationHistoryList({
    super.key,
    required this.locations,
  });

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Center(
          child: Text(
            'No stored history in SQLite DB',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final loc = locations[index];
        final isLatest = index == 0;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
          elevation: isLatest ? 2 : 0.5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: isLatest
                  ? Colors.deepPurple.shade100
                  : Colors.grey.shade200,
              child: Icon(
                Icons.location_on,
                color: isLatest ? Colors.deepPurple : Colors.grey.shade600,
                size: 20,
              ),
            ),
            title: Text(
              'Lat: ${loc.latitude.toStringAsFixed(5)}, Lng: ${loc.longitude.toStringAsFixed(5)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            subtitle: Text(
              'Time: ${loc.formattedTime} | Acc: ${loc.accuracy.toStringAsFixed(1)}m',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
            trailing: loc.id != null
                ? Chip(
                    label: Text('#${loc.id}'),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    labelStyle: const TextStyle(fontSize: 10),
                  )
                : null,
          ),
        );
      },
    );
  }
}
