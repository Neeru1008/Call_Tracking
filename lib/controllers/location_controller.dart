import 'dart:async';
import 'package:get/get.dart';
import '../models/location_model.dart';
import '../services/native_location_channel.dart';

class LocationController extends GetxController {
  final NativeLocationChannel _channel = NativeLocationChannel();

  final RxBool isServiceRunning = false.obs;
  final RxBool hasPermission = false.obs;
  final Rxn<LocationModel> currentLocation = Rxn<LocationModel>();
  final RxList<LocationModel> locationHistory = <LocationModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<LocationModel>? _locationSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    isLoading.value = true;
    try {
      await checkPermission();
      await checkServiceStatus();
      await fetchLastLocation();
      await fetchAllLocations();
      _listenToLocationUpdates();
    } catch (e) {
      errorMessage.value = "Failed to initialize: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkPermission() async {
    final granted = await _channel.hasLocationPermission();
    hasPermission.value = granted;
  }

  Future<bool> requestPermission() async {
    final granted = await _channel.requestLocationPermission();
    hasPermission.value = granted;
    if (!granted) {
      Get.snackbar(
        'Permission Required',
        'Location permission is required to fetch background locations.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      checkServiceStatus();
    }
    return granted;
  }

  Future<void> checkServiceStatus() async {
    final running = await _channel.isServiceRunning();
    isServiceRunning.value = running;
  }

  Future<void> fetchLastLocation() async {
    final location = await _channel.getLastLocation();
    if (location != null) {
      currentLocation.value = location;
    }
  }

  Future<void> fetchAllLocations() async {
    final locations = await _channel.getAllLocations();
    locationHistory.assignAll(locations);
  }

  void _listenToLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = _channel.onLocationUpdated.listen(
      (LocationModel newLocation) {
        currentLocation.value = newLocation;
        // Avoid duplicate insertion if already in list
        if (locationHistory.isEmpty ||
            locationHistory.first.id != newLocation.id ||
            locationHistory.first.timestamp != newLocation.timestamp) {
          locationHistory.insert(0, newLocation);
        }
      },
      onError: (error) {
        errorMessage.value = "Stream error: $error";
      },
    );
  }

  Future<void> toggleService() async {
    if (isServiceRunning.value) {
      await stopService();
    } else {
      await startService();
    }
  }

  Future<void> startService() async {
    if (!hasPermission.value) {
      final granted = await requestPermission();
      if (!granted) return;
    }

    isLoading.value = true;
    final success = await _channel.startLocationService();
    if (success) {
      isServiceRunning.value = true;
      Get.snackbar(
        'Service Started',
        'Background location service is actively recording coordinates.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to start location service. Please verify permissions.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    isLoading.value = false;
  }

  Future<void> stopService() async {
    isLoading.value = true;
    final success = await _channel.stopLocationService();
    if (success) {
      isServiceRunning.value = false;
      Get.snackbar(
        'Service Stopped',
        'Background location tracking stopped.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    isLoading.value = false;
  }

  Future<void> clearHistory() async {
    isLoading.value = true;
    final count = await _channel.clearLocationHistory();
    locationHistory.clear();
    currentLocation.value = null;
    isLoading.value = false;

    Get.snackbar(
      'History Cleared',
      'Removed $count entries from native SQLite database.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    await checkServiceStatus();
    await fetchLastLocation();
    await fetchAllLocations();
    isLoading.value = false;
  }

  @override
  void onClose() {
    _locationSubscription?.cancel();
    super.onClose();
  }
}
