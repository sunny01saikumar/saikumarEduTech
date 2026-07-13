import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/providers.dart';
import 'presentation/screens/main_layout.dart';
import 'presentation/widgets/ad_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize AdMob SDK
  await AdService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const JavaMasterApp(),
    ),
  );
}

class JavaMasterApp extends ConsumerWidget {
  const JavaMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);
    final textSizeMultiplier = ref.watch(textSizeMultiplierProvider);

    return MaterialApp(
      title: 'SaiKumarEduTech - Java Master',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        // Dynamic Text Scaling multiplier
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textSizeMultiplier),
          ),
          child: child!,
        );
      },
      home: const MainLayout(),
    );
  }
}
