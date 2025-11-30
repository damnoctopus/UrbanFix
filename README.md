UrbanFix - Citizen App (Flutter)

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

