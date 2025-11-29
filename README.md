UrbanFix - Citizen App (Flutter)

This repository contains a Flutter client app for citizens to report civic issues (UrbanFix).

Features implemented:
- Onboarding, Register, Login
- Home with Recent complaints and Report Issue button
- Report Issue: image picker (camera/gallery), GPS auto-fetch, severity slider, category select
Note about category routing
- The backend provides an auto-routing engine so the client no longer needs to provide an explicit "category" when creating a complaint. The app omits the category field and the backend determines the appropriate department/category.

Android permissions required for location & camera
- To use GPS and camera on Android add these permissions in `android/app/src/main/AndroidManifest.xml` inside the `<manifest>` / `<application>` as appropriate:

	<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
	<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
	<uses-permission android:name="android.permission.CAMERA" />

On iOS add corresponding usage descriptions to `ios/Runner/Info.plist` (NSLocationWhenInUseUsageDescription, NSCameraUsageDescription, NSPhotoLibraryUsageDescription).

API base URL:
- Update `lib/services/api_service.dart` -> `baseUrl` to point to your backend.

Dependencies (added to pubspec.yaml):
- http, provider, flutter_secure_storage, image_picker, flutter_image_compress, geolocator, flutter_map, connectivity_plus, shared_preferences, intl

How to run:
1. Install Flutter and ensure `flutter doctor` is clean.
2. From project root run:

```powershell
flutter pub get
flutter run
```

Notes & next steps:
- Add your map API keys if you want richer map previews.
- This project includes minimal error handling and some mock data for the UI; connect to a real backend matching the API routes to make it functional.
- Consider adding offline queueing & sync (SharedPreferences/local DB) to store reports when offline.
