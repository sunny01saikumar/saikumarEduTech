# SaiKumarEduTech - Java Master

SaiKumarEduTech - Java Master is a production-ready, offline-first Android application designed for Java developers and interview preparation. 

It is built using **Flutter (Dart)**, following **Clean Architecture principles**, styled with **Material Design 3**, and utilizes **Riverpod** for robust, reactive state management.

---

## 🚀 Key Features

*   **100% Offline-First**: No backend, database, or server connections. All educational materials are cached locally inside assets.
*   **Comprehensive Q&A Modules**: Over detailed Java interview questions categorized across Core Java, OOP, Collections, Multithreading, JVM internals, Spring Boot, Hibernate, SQL, and Microservices.
*   **Source Code Repository**: Java programs with detailed problem statements, algorithm designs, time/space complexity analyses, formatted code blocks, and terminal console outputs.
*   **Interactive Quizzes**: MCQ tests with immediate correctness feedback, score tracking, accuracy metrics, and visual post-game answer review.
*   **Study Guides**: Scrollable, beautifully formatted markdown notes highlighting key interview secrets and architecture summaries.
*   **Streak & Analytics Dashboard**: Built-in gamification tracking daily streak records and progress graphs utilizing `fl_chart`.
*   **Monetization Hooks**: Custom wrappers for AdMob Banner, Inline Native, Interstitial (shows after reading 10 questions), and Rewarded ads (watch to unlock premium notes).
*   **Material 3 Adaptation**: Built-in support for dynamic Dark Mode and fluid Text Sizing adjustment.

---

## 📂 Folder Structure

```
C:\Users\saiku\Desktop\saikumarEduTech
├── android/                  # Android-native configuration files
│   ├── app/
│   │   ├── build.gradle      # SDK target 34, versioning, minification rules
│   │   ├── proguard-rules.pro# Shrinking rules protecting serialization models
│   │   └── src/main/
│   │       ├── AndroidManifest.xml # Network access, AdMob app ID
│   │       └── kotlin/       # Kotlin Main Activity
│   └── build.gradle
├── assets/
│   ├── json/                 # Offline content databases
│   │   ├── categories.json
│   │   ├── questions.json
│   │   ├── programs.json
│   │   ├── notes.json
│   │   ├── quiz.json
│   │   └── tips.json
│   └── images/               # App Icons, Splash Logo, Google Play Store Banners
├── lib/
│   ├── main.dart             # App Bootstrapper & dynamic media controllers
│   ├── core/
│   │   ├── theme/            # Material 3 light/dark presets
│   │   └── services/         # SharedPreferences progress tracking
│   ├── data/
│   │   ├── models/           # Data models with JSON deserialization
│   │   └── repositories/     # Asset bundle loader cache managers
│   └── presentation/
│       ├── providers/        # Riverpod state management notifier providers
│       ├── widgets/          # Reusable code blocks, charts, and AdMob layout wrappers
│       └── screens/          # Dashboard, Q&A, coding, quiz, bookmarks, settings
├── pubspec.yaml              # App dependencies & configurations
└── README.md
```

---

## 📦 How to Build and Publish to Play Store

### Prerequisites
Make sure you have [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your system.

### 1. Swap AdMob App & Unit IDs
In order to show your own ads, replace the Google AdMob test IDs with your production keys:
*   **App ID (Android)**: Swap inside `android/app/src/main/AndroidManifest.xml` under `<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="..." />`.
*   **Unit IDs**: Update variables inside [ad_widgets.dart](file:///C:/Users/saiku/Desktop/saikumarEduTech/lib/presentation/widgets/ad_widgets.dart) (`bannerUnitId`, `interstitialUnitId`, `rewardedUnitId`, `nativeUnitId`).

### 2. Configure Signing Keystore
To sign your app for production:
1. Generate an upload keystore:
   ```bash
   keytool -genkey -v -keystore C:\Users\saiku\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Reference the keystore in `android/key.properties` (create this file in `android/` directory):
   ```properties
   storePassword=your-keystore-password
   keyPassword=your-key-password
   keyAlias=upload
   storeFile=C:\\Users\\saiku\\upload-keystore.jks
   ```
3. Update `android/app/build.gradle` signing configurations to use release signing settings.

### 3. Build Android App Bundle (AAB)
Compile the production bundle (AAB) that is ready to upload to the Google Play Console:
```bash
flutter build appbundle --release
```
The output file will be generated at `build/app/outputs/bundle/release/app-release.aab`.

---

## 🛠️ Modifying Content
To add, edit, or remove questions, programs, notes, or quiz items:
1. Navigate to `assets/json/`
2. Edit the corresponding JSON database file (`questions.json`, `programs.json`, etc.).
3. Re-run or rebuild the app. No structural code modifications are required!
