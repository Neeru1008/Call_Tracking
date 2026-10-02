<<<<<<< 
# Location Tracking — Background Location Service
A production-grade Flutter application demonstrating persistent background location tracking using **GetX (MVC Architecture)** and **Native Android (Kotlin)** with `FusedLocationProviderClient`, native **SQLite Database**, **Foreground Service**, and **Boot Auto-Start capabilities**.

## Architecture Overview
The application is architected around a strict decoupled model where location retrieval, background execution, and persistent SQLite database operations are managed entirely on the **Android Native (Kotlin)** side. Flutter interacts via **Platform Channels** (MethodChannel & EventChannel) using **GetX State Management** under an MVC pattern.

                    ┌─────────────────────────┐
                    │       Flutter UI        │
                    │ (HomeView, LocationCard)│
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │     GetX Controller     │
                    │  (LocationController)   │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │  NativeLocationChannel  │
                    └──────┬───────────┬──────┘
             MethodChannel │           │ EventChannel
                           ▼           ▼
                    ┌─────────────────────────┐
                    │     MainActivity.kt     │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │LocationForegroundService│◄─────┐
                    └────────────┬────────────┘      │
                                 │                   │
                    ┌────────────▼────────────┐   ┌──┴──────────┐
                    │FusedLocationProviderClient  │BootReceiver │
                    └────────────┬────────────┘   └─────────────┘
                                 │
                    ┌────────────┴────────────┐
                    ▼                         ▼
            ┌───────────────┐         ┌───────────────┐
            │   SQLite DB   │         │ EventChannel  │
            │(LocationDb)   │         │  Live Stream  │
            └───────────────┘         └───────────────┘
## Key Features & Technical Highlights
### 1. Native Android Implementation (Kotlin)
- **Zero External Flutter Location Plugins**: Built exclusively using native Kotlin code and Google Play Services Location API.
- **FusedLocationProviderClient**: Configured with `Priority.PRIORITY_HIGH_ACCURACY` (5-second intervals, 3-second fastest interval).
- **Native SQLite Controller (`LocationDbHelper.kt`)**: Implemented using `SQLiteOpenHelper`. Performs transactional location storage (`id`, `latitude`, `longitude`, `accuracy`, `timestamp`) directly on the native thread.
- **Ongoing Foreground Service (`LocationForegroundService.kt`)**: Displays a persistent status notification with live coordinates and operates under Android 14 (`FOREGROUND_SERVICE_LOCATION`) standards.

### 2. Background Persistence & Auto-Restart
- **App-Kill Resilience**: Overrides `onTaskRemoved()` combined with `AlarmManager` to immediately relaunch the background service if the user swipes away or force-kills the app from Recent Apps.
- **Device Reboot Auto-Start (`BootReceiver.kt`)**: Registered receiver listening to `ACTION_BOOT_COMPLETED`, `ACTION_MY_PACKAGE_REPLACED`, and `QUICKBOOT_POWERON`. Automatically resumes tracking upon device restart if enabled.
- **SharedPreferences Persistence**: Saves active tracking state to survive system restarts and memory kills.

### 3. Flutter & GetX State Management (MVC)
- **Model (`LocationModel.dart`)**: Safe type casting and timestamp formatting for coordinates retrieved from native platform calls.
- **View (`HomeView.dart`, `LocationCard.dart`, `LocationHistoryList.dart`)**: Production-level Material 3 responsive UI with live vs cached indicators, status badges, and database history view.
- **Controller (`LocationController.dart`)**: GetX controller managing reactive state (`isServiceRunning`, `hasPermission`, `currentLocation`, `locationHistory`). Loads cached SQLite history on app launch and listens to live `EventChannel` updates when open.

### 4. Platform Channels
- **MethodChannel (`com.example.call_tracking/location_method_channel`)**:
  - `startLocationService` / `stopLocationService`
  - `isServiceRunning`
  - `getLastLocation` (Queries native SQLite)
  - `getAllLocations` (Queries native SQLite)
  - `clearLocationHistory` (Clears native SQLite table)
  - `hasLocationPermission` / `requestLocationPermission`
- **EventChannel (`com.example.call_tracking/location_event_channel`)**:
  - Broadcasts live location updates directly to Flutter UI when the app is in foreground.
    
## Project Directory Structure
call_tracking/
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml                  # Permissions, Service & Boot Receiver declarations
│       └── kotlin/com/example/call_tracking/
│           ├── MainActivity.kt                  # MethodChannel & EventChannel Handler
│           ├── LocationForegroundService.kt     # FusedLocationProviderClient & Foreground Service
│           ├── LocationDbHelper.kt              # Native SQLite Controller
│           └── BootReceiver.kt                  # Auto-start on device reboot
└── lib/
    ├── main.dart                                # GetMaterialApp entry point
    ├── models/
    │   └── location_model.dart                  # Location data model
    ├── services/
    │   └── native_location_channel.dart         # Method & Event channel abstraction
    ├── controllers/
    │   └── location_controller.dart             # GetX Controller
    └── views/
        ├── home_view.dart                       # Main UI Screen
        └── widgets/
            ├── location_card.dart               # Current/Last location card
            └── location_history_list.dart       # SQLite database history list
            
## Required Permissions (Android Manifest)

- `ACCESS_FINE_LOCATION` & `ACCESS_COARSE_LOCATION`
- `ACCESS_BACKGROUND_LOCATION`
- `FOREGROUND_SERVICE` & `FOREGROUND_SERVICE_LOCATION`
- `POST_NOTIFICATIONS` (Android 13+)
- `RECEIVE_BOOT_COMPLETED`
  

---

## Testing Background & Reboot Capabilities

1. **Test Background Tracking when App is Killed**:
   - Open the app, grant permissions, and tap **"Start Location Service"**.
   - Swipe away / kill the app from Recent Apps.
   - Observe that the persistent notification remains active and updates coordinates every 5 seconds.
   - Reopen the app to see all background-collected locations populated from the native SQLite DB.

2. **Test Device Reboot**:
   - Ensure location service is started.
   - Restart the device (`adb reboot`).
   - Upon reboot, `BootReceiver` will trigger `LocationForegroundService` automatically.
