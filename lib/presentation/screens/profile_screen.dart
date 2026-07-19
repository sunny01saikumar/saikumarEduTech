import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/providers.dart';
import '../widgets/progress_chart.dart';
import 'policy_screens.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final streak = ref.watch(streakProvider);
    final isDark = ref.watch(darkModeProvider);
    final textSizeMultiplier = ref.watch(textSizeMultiplierProvider);
    final quizHistory = ref.watch(quizHistoryProvider);
    final resetAllProgress = ref.read(resetProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Streak Card
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 48),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$streak Day Streak',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            streak > 0
                                ? 'Keep learning Java daily to protect your streak!'
                                : 'Complete reading concepts or quizzes to start your streak!',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Progress Chart
            ProgressChart(quizHistory: quizHistory),
            const SizedBox(height: 24),

            // Settings Header
            Text(
              'App Settings',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Settings Card
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  // Dark Mode Switch
                  SwitchListTile(
                    title: const Text('Dark Mode (Static)'),
                    secondary: Icon(Icons.dark_mode, color: theme.colorScheme.primary),
                    value: true,
                    onChanged: null,
                  ),
                  const Divider(height: 1, indent: 56),

                  // Text Size Selector
                  ListTile(
                    title: const Text('Adjust Text Size'),
                    leading: Icon(Icons.text_fields, color: theme.colorScheme.primary),
                    subtitle: Text(_getTextSizeLabel(textSizeMultiplier)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () => _showTextSizeDialog(context, ref, textSizeMultiplier),
                  ),
                  const Divider(height: 1, indent: 56),

                  // Reset Progress
                  ListTile(
                    title: const Text('Reset All Progress'),
                    leading: const Icon(Icons.restart_alt, color: Colors.red),
                    subtitle: const Text('Reset reading history, stats & bookmarks'),
                    onTap: () => _confirmReset(context, resetAllProgress),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info & Support Header
            Text(
              'Support & Legals',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Support Card
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  // Share App
                  ListTile(
                    title: const Text('Share App'),
                    leading: Icon(Icons.share, color: theme.colorScheme.secondary),
                    onTap: () {
                      Share.share(
                        'Hey! Prepare for your Java & Spring Boot interviews offline with: SaiKumarEduTech - Java Master. Download now!',
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),

                  // Rate App
                  ListTile(
                    title: const Text('Rate App'),
                    leading: Icon(Icons.star, color: theme.colorScheme.secondary),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('App Store rating redirects in production release.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),

                  // About developer
                  ListTile(
                    title: const Text('About Developer'),
                    leading: Icon(Icons.info, color: theme.colorScheme.secondary),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AboutPage()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),

                  // Privacy Policy
                  ListTile(
                    title: const Text('Privacy Policy'),
                    leading: Icon(Icons.privacy_tip, color: theme.colorScheme.secondary),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getTextSizeLabel(double value) {
    if (value <= 0.8) return 'Small';
    if (value <= 1.0) return 'Normal (Recommended)';
    if (value <= 1.2) return 'Large';
    return 'Extra Large';
  }

  void _showTextSizeDialog(BuildContext context, WidgetRef ref, double currentValue) {
    showDialog(
      context: context,
      builder: (context) {
        double val = currentValue;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Text Size Scaling'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Adjust font size multiplier of study text & programs:'),
                  const SizedBox(height: 16),
                  Slider(
                    value: val,
                    min: 0.8,
                    max: 1.4,
                    divisions: 3,
                    label: _getTextSizeLabel(val),
                    onChanged: (newVal) {
                      setStateDialog(() {
                        val = newVal;
                      });
                    },
                  ),
                  Text(
                    'Sample Text Size preview',
                    style: TextStyle(fontSize: 14 * val, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    ref.read(textSizeMultiplierProvider.notifier).setMultiplier(val);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmReset(BuildContext context, Function resetProgress) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Progress?'),
          content: const Text(
            'This action is permanent. All bookmarks, reading history, streaks, and quiz statistics will be completely erased.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                resetProgress();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All local progress reset successfully.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}
