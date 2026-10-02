import 'dart:async';
import 'package:flutter/services.dart';
import '../models/location_model.dart';

class NativeLocationChannel {
  static const MethodChannel _methodChannel =
      MethodChannel('com.example.call_tracking/location_method_channel');

  static const EventChannel _eventChannel =
      EventChannel('com.example.call_tracking/location_event_channel');

  Stream<LocationModel>? _locationStream;

  Future<bool> startLocationService() async {
    try {
      final bool result =
          await _methodChannel.invokeMethod('startLocationService');
      return result;
    } on PlatformException catch (e) {
      print("Error starting location service: ${e.message}");
      return false;
    }
  }

  Future<bool> stopLocationService() async {
    try {
      final bool result =
          await _methodChannel.invokeMethod('stopLocationService');
      return result;
    } on PlatformException catch (e) {
      print("Error stopping location service: ${e.message}");
      return false;
    }
  }

  Future<bool> isServiceRunning() async {
    try {
      final bool result =
          await _methodChannel.invokeMethod('isServiceRunning');
      return result;
    } on PlatformException catch (e) {
      print("Error checking service status: ${e.message}");
      return false;
    }
  }

  Future<LocationModel?> getLastLocation() async {
    try {
      final dynamic result =
          await _methodChannel.invokeMethod('getLastLocation');
      if (result != null && result is Map) {
        return LocationModel.fromMap(result);
      }
      return null;
    } on PlatformException catch (e) {
      print("Error getting last location: ${e.message}");
      return null;
    }
  }

  Future<List<LocationModel>> getAllLocations() async {
    try {
      final dynamic result =
          await _methodChannel.invokeMethod('getAllLocations');
      if (result != null && result is List) {
        return result
            .whereType<Map>()
            .map((item) => LocationModel.fromMap(item))
            .toList();
      }
      return [];
    } on PlatformException catch (e) {
      print("Error getting location history: ${e.message}");
      return [];
    }
  }

  Future<int> clearLocationHistory() async {
    try {
      final dynamic result =
          await _methodChannel.invokeMethod('clearLocationHistory');
      return (result as num?)?.toInt() ?? 0;
    } on PlatformException catch (e) {
      print("Error clearing location history: ${e.message}");
      return 0;
    }
  }

  Future<bool> hasLocationPermission() async {
    try {
      final bool result =
          await _methodChannel.invokeMethod('hasLocationPermission');
      return result;
    } on PlatformException catch (e) {
      print("Error checking location permission: ${e.message}");
      return false;
    }
  }

  Future<bool> requestLocationPermission() async {
    try {
      final bool result =
          await _methodChannel.invokeMethod('requestLocationPermission');
      return result;
    } on PlatformException catch (e) {
      print("Error requesting location permission: ${e.message}");
      return false;
    }
  }

  Stream<LocationModel> get onLocationUpdated {
    _locationStream ??= _eventChannel
        .receiveBroadcastStream()
        .where((event) => event != null && event is Map)
        .map((event) => LocationModel.fromMap(event as Map));
    return _locationStream!;
  }
}
