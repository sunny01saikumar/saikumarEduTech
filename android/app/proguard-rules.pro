# Flutter ProGuard/R8 rules for shrinking and obfuscation

# Keep models from being obfuscated, ensuring JSON serialization keys remain unchanged
-keep class com.saikumaredutech.javamaster.data.models.** { *; }

# Google Play Services and AdMob rules
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Keep standard Flutter/Dart classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class org.chromium.** { *; }

# Prevent warnings/failures due to missing Google Play Core dependencies in Flutter engine
-dontwarn com.google.android.play.core.**

