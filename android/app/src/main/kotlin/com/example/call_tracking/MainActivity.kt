package com.example.call_tracking

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val METHOD_CHANNEL_NAME = "com.example.call_tracking/location_method_channel"
        private const val EVENT_CHANNEL_NAME = "com.example.call_tracking/location_event_channel"
        private const val PERMISSION_REQUEST_CODE = 1002
    }

    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Setup Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                handleMethodCall(call, result)
            }

        // 2. Setup Event Channel for live location updates
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL_NAME)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    LocationForegroundService.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    LocationForegroundService.eventSink = null
                }
            })
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val dbHelper = LocationDbHelper.getInstance(this)

        when (call.method) {
            "startLocationService" -> {
                if (hasLocationPermissions()) {
                    LocationForegroundService.startService(this)
                    result.success(true)
                } else {
                    result.error("PERMISSION_DENIED", "Location permissions are not granted", null)
                }
            }
            "stopLocationService" -> {
                LocationForegroundService.stopService(this)
                result.success(true)
            }
            "isServiceRunning" -> {
                result.success(LocationForegroundService.isServiceRunning)
            }
            "getLastLocation" -> {
                val lastLoc = dbHelper.getLastLocation()
                result.success(lastLoc)
            }
            "getAllLocations" -> {
                val locations = dbHelper.getAllLocations()
                result.success(locations)
            }
            "clearLocationHistory" -> {
                val count = dbHelper.clearLocations()
                result.success(count)
            }
            "hasLocationPermission" -> {
                result.success(hasLocationPermissions())
            }
            "requestLocationPermission" -> {
                if (hasLocationPermissions()) {
                    result.success(true)
                } else {
                    pendingPermissionResult = result
                    requestLocationPermissions()
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun hasLocationPermissions(): Boolean {
        val fineLocation = ContextCompat.checkSelfPermission(
            this, Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        val coarseLocation = ContextCompat.checkSelfPermission(
            this, Manifest.permission.ACCESS_COARSE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED

        return fineLocation || coarseLocation
    }

    private fun requestLocationPermissions() {
        val permissions = mutableListOf(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            permissions.add(Manifest.permission.POST_NOTIFICATIONS)
        }

        ActivityCompat.requestPermissions(
            this,
            permissions.toTypedArray(),
            PERMISSION_REQUEST_CODE
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_REQUEST_CODE) {
            val granted = hasLocationPermissions()
            pendingPermissionResult?.success(granted)
            pendingPermissionResult = null
        }
    }
}
