# SnatchMart Flutter App

Production-ready Flutter client for the SnatchMart affiliate deals backend (Spring Boot).

## Stack

- Flutter 3+ / Dart 3
- **State:** Riverpod
- **API:** Dio (JWT interceptors, error handling)
- **Navigation:** GoRouter (protected routes)
- **UI:** Material 3, theme + dark mode, shimmer, empty states, pull-to-refresh
- **Models:** Plain Dart classes with `fromJson`/`toJson` (optional: add Freezed + build_runner later)

## How to run

**1. Open a terminal** and go to the Flutter app folder:

```bash
cd /Users/pulkitgiddu/Documents/Code/Backend/snatchMart/ui/flutter_app
```

**2. Install dependencies:**

```bash
flutter pub get
```

**3. (Optional) Start an emulator or connect a device:**

- Android: start Android Studio → AVD Manager → run an emulator, or connect a phone with USB debugging.
- iOS: open Simulator from Xcode, or connect an iPhone.

**4. Run the app:**

```bash
flutter run
```

Pick a device when prompted (e.g. `Chrome`, an Android emulator, or an iOS simulator).

**5. Point the app at your backend:**

- **Android emulator** (backend on your Mac): the app uses `http://10.0.2.2:8081` by default. If your backend runs on port 8081, no change needed.
- **iOS simulator**: use your machine’s IP or `127.0.0.1`. Example:

  ```bash
  flutter run --dart-define=BASE_URL=http://127.0.0.1:8081
  ```

- **Physical device**: use your computer’s LAN IP (e.g. `http://192.168.1.5:8081`).

**Quick run (script):**

```bash
chmod +x run_app.sh
./run_app.sh
```

To pass extra args (e.g. a specific device):

```bash
./run_app.sh -d chrome
# or
./run_app.sh --dart-define=BASE_URL=http://127.0.0.1:8081
```

## Run from Android Studio

1. **Open the project in Android Studio**
   - File → Open → select the **`ui/flutter_app`** folder (the one that contains `pubspec.yaml`), not the whole repo root.
   - Wait for Gradle/Flutter to sync.

2. **Install Flutter plugin** (if needed)
   - Android Studio → Settings/Preferences → Plugins → search **Flutter** → Install (and **Dart** if prompted).

3. **Start an Android emulator**
   - Tools → Device Manager → create or choose an AVD → click the **Run** (play) button.

4. **Run the app**
   - Select your emulator (or device) in the device dropdown in the toolbar.
   - Click the green **Run** button, or use **Run → Run 'main.dart'** (Shift+F10).
   - First run may take a few minutes (Gradle build).

5. **Backend URL for emulator**
   - The app must use `http://10.0.2.2:8081` to reach the backend on your machine.
   - To set it in Android Studio: **Run → Edit Configurations** → select your Flutter app configuration → in **Additional run args** add:
     ```text
     --dart-define=BASE_URL=http://10.0.2.2:8081
     ```
   - Apply → OK, then run again.  
   - Or run from terminal once:  
     `flutter run -d <device_id> --dart-define=BASE_URL=http://10.0.2.2:8081`

6. **Ensure the backend is running** on your machine (e.g. `./mvnw spring-boot:run -Dspring-boot.run.profiles=local` from the repo root) on port **8081**.

## Structure

```
lib/
  config/          # env, router, providers
  core/            # theme, errors, network (Dio + interceptors)
  features/
    auth/          # login, register, auth state
    home/          # home + categories
    products/      # list, detail, search, pagination, affiliate click
    coupons/       # coupon list
    wishlist/      # wishlist CRUD
    budgets/       # budget alerts
    notifications/ # notification list
    profile/       # profile + logout
  models/         # DTOs
  repositories/    # API calls
  services/        # local storage (token)
  widgets/         # shimmer, empty state
```

## Affiliate tracking

From product detail, "Open deal" calls `POST /api/v1/affiliate-clicks` with `userId`, `productId`, `merchantId`, then opens the affiliate URL with `url_launcher`.

## Optional: Freezed + code gen

To switch to Freezed + `json_serializable` for models:

1. Add `part '*.freezed.dart'; part '*.g.dart';` and `@freezed` / `fromJson` to model files.
2. Run: `dart run build_runner build --delete-conflicting-outputs`

## Backend

Ensure the Spring Boot backend is running (e.g. port 8081). Use `BASE_URL` so the app points to your host (e.g. `http://10.0.2.2:8081` on Android emulator).
