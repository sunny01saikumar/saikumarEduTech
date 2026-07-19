import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('About Developer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 54,
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
            const SizedBox(height: 20),
            Text(
              'SaiKumarEduTech',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Learn Java. Crack Interviews.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Java Master is a production-ready offline learning platform. Our goal is to provide high-quality reference guides, quick checklists, compilation steps, and mock quizzes for software developers, CS students, and enterprise engineering professionals looking to build deep Java expertise or clear technical interviews.',
              textAlign: TextAlign.justify,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(context, 'Version', '1.0.0 (Build 1)'),
            _buildInfoRow(context, 'Developer', 'Sai Kumar'),
            _buildInfoRow(context, 'Email Support', 'dmartcampous@gmail.com'),
            _buildInfoRow(context, 'Location', 'Offline First (Local Storage)'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String key, String val) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(val, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for SaiKumarEduTech - Java Master',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Last updated: July 2026'),
            const Divider(height: 24),
            _buildSection(
              theme,
              '1. Overview',
              'This application works entirely offline. We do NOT host any user databases, register personal details, implement third-party auth, or store credentials on our servers. All study progress, favorite items, and settings are saved locally inside your device using SharedPreferences.',
            ),
            _buildSection(
              theme,
              '2. Permissions Needed',
              'The application limits Android permissions to the following:\n- INTERNET: Required to load Google AdMob advertisements and verify monetization checks.\n- ACCESS_NETWORK_STATE: Required by AdMob to determine internet connectivity and load fallbacks.',
            ),
            _buildSection(
              theme,
              '3. AdMob Integration',
              'We integrate Google AdMob to display banner and native ads. Google may use advertising identifiers to serve customized promotions according to Google Play Policies. You can manage personalization preferences via Android System Settings.',
            ),
            _buildSection(
              theme,
              '4. Data Deletion',
              'Since all details live strictly inside your device storage, you can erase your data instantly by clicking "Reset All Progress" under settings or by clearing the application storage cache inside Android settings.',
            ),
            _buildSection(
              theme,
              '5. Contact Support',
              'For queries regarding security standards, terms of use, or learning resources, reach us at dmartcampous@gmail.com.',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}
