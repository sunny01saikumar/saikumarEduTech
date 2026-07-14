import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../providers/providers.dart';
import 'search_screen.dart';
import 'notes_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final streak = ref.watch(streakProvider);
    final readQuestions = ref.watch(readQuestionsProvider);
    final completedPrograms = ref.watch(completedProgramsProvider);
    final recentlyViewed = ref.watch(recentlyViewedProvider);

    final questionsAsync = ref.watch(questionsFutureProvider);
    final programsAsync = ref.watch(programsFutureProvider);
    final tipsAsync = ref.watch(tipsFutureProvider);

    // Dynamic stats
    int totalQuestions = questionsAsync.value?.length ?? 100;
    int totalPrograms = programsAsync.value?.length ?? 50;

    double progressPercent = (totalQuestions + totalPrograms) > 0
        ? ((readQuestions.length + completedPrograms.length) /
        (totalQuestions + totalPrograms)) *
        100
        : 0;

    // Daily Java Tip of the Day
    String tipTitle = 'Java Compiler Fact';
    String tipContent = 'Java bytecode runs on the JVM, making the compiled binaries cross-platform.';
    if (tipsAsync.value != null && tipsAsync.value!.isNotEmpty) {
      final random = Random();
      final tipObj = tipsAsync.value![random.nextInt(tipsAsync.value!.length)];
      tipTitle = tipObj.title;
      tipContent = tipObj.content;
    }

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Elegant Header with Branding
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'SaiKumarEduTech',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );
                },
              ),
            ],
          ),

          // Dashboard Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar Card
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Text(
                            'Search questions, programs, notes...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Progress & Streak Section
                  Row(
                    children: [
                      // Streak Count Card
                      Expanded(
                        child: Card(
                          elevation: 0,
                          color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$streak',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Day Streak',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Progress Percent Card
                      Expanded(
                        child: Card(
                          elevation: 0,
                          color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.trending_up, color: Colors.blue, size: 28),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${progressPercent.toStringAsFixed(1)}%',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSecondaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Completion',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Study Tip Card
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.tertiaryContainer.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.tertiary.withOpacity(0.2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: theme.colorScheme.tertiary, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Java Fact of the Day',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onTertiaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tipTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tipContent,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Core Action Categories Grid
                  Text(
                    'Quick Navigation',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _buildNavigationCard(
                        context,
                        title: 'Study Notes',
                        subtitle: 'Java & Spring Boot',
                        icon: Icons.menu_book,
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotesScreen()),
                          );
                        },
                      ),
                      _buildNavigationCard(
                        context,
                        title: 'Roadmaps',
                        subtitle: 'Developer Paths',
                        icon: Icons.alt_route,
                        color: Colors.green,
                        onTap: () {
                          _showRoadmapDialog(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Continue Learning
                  if (recentlyViewed.isNotEmpty) ...[
                    Text(
                      'Continue Learning',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: min(recentlyViewed.length, 3),
                      itemBuilder: (context, index) {
                        final item = recentlyViewed[index];
                        final type = item['type'] ?? '';
                        final title = item['title'] ?? '';

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8),
                          color: theme.colorScheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.outlineDeco(),
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: type == 'question'
                                  ? theme.colorScheme.primaryContainer
                                  : (type == 'program'
                                  ? theme.colorScheme.secondaryContainer
                                  : theme.colorScheme.tertiaryContainer),
                              child: Icon(
                                type == 'question'
                                    ? Icons.question_answer
                                    : (type == 'program' ? Icons.code : Icons.book),
                                size: 16,
                                color: type == 'question'
                                    ? theme.colorScheme.onPrimaryContainer
                                    : (type == 'program'
                                    ? theme.colorScheme.onSecondaryContainer
                                    : theme.colorScheme.onTertiaryContainer),
                              ),
                            ),
                            title: Text(
                              title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              type.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.outlineDeco()),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoadmapDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: const Text('Java Developer Roadmap'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStep(theme, 'Step 1: Core Java', 'Learn syntax, OOP, Collections, Exception Handling.'),
                _buildStep(theme, 'Step 2: Databases', 'SQL fundamentals, relational schemas, indexing.'),
                _buildStep(theme, 'Step 3: Hibernate & JPA', 'ORM mappings, lazy loading, JPQL/HQL queries.'),
                _buildStep(theme, 'Step 4: Spring Framework', 'Dependency injection, beans, IoC container.'),
                _buildStep(theme, 'Step 5: Spring Boot & MVC', 'REST APIs, autoconfiguration, filters.'),
                _buildStep(theme, 'Step 6: Microservices', 'Eureka, gateway, Resilience4j, config servers.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }

  Widget _buildStep(ThemeData theme, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  desc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension ColorExtension on ThemeData {
  Color outlineDeco() {
    return colorScheme.outlineVariant.withOpacity(0.4);
  }
}
