import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/providers.dart';
import '../../data/models/models.dart';
import '../widgets/code_block.dart';
import '../widgets/ad_widgets.dart';

class ProgramsScreen extends ConsumerStatefulWidget {
  const ProgramsScreen({super.key});

  @override
  ConsumerState<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends ConsumerState<ProgramsScreen> {
  CategoryModel? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    if (_selectedCategory == null) {
      return _buildCategorySelector();
    } else {
      return _buildProgramList();
    }
  }

  Widget _buildCategorySelector() {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Java Programs'),
        centerTitle: true,
      ),
      body: categoriesAsync.when(
        data: (cats) {
          final list = cats['programs'] ?? [];
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final cat = list[index];
              return _buildCategoryCard(cat);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load categories')),
      ),
    );
  }

  Widget _buildCategoryCard(CategoryModel cat) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = cat;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Icon(
                  _getIcon(cat.icon),
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              Text(
                cat.name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramList() {
    final theme = Theme.of(context);
    final programsAsync = ref.watch(programsFutureProvider);
    final completed = ref.watch(completedProgramsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedCategory!.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedCategory = null;
            });
          },
        ),
      ),
      body: programsAsync.when(
        data: (programs) {
          final list = programs.where((p) => p.category == _selectedCategory!.id).toList();

          if (list.isEmpty) {
            return const Center(child: Text('No programs available in this category yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (context, index) {
              if (index > 0 && index % 3 == 0) {
                return const AdNative();
              }
              return const SizedBox(height: 12);
            },
            itemBuilder: (context, index) {
              final program = list[index];
              final isCompleted = completed.contains(program.id);

              return Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isCompleted
                        ? theme.colorScheme.primary.withOpacity(0.3)
                        : theme.colorScheme.outlineVariant.withOpacity(0.4),
                  ),
                ),
                child: ListTile(
                  title: Text(
                    program.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Time: ${program.timeComplexity}',
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary),
                        ],
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ref.read(recentlyViewedProvider.notifier).add('program', program.id, program.title);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProgramDetailScreen(program: program),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load programs')),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'data_array':
        return Icons.data_array;
      case 'text_snippet':
        return Icons.text_snippet;
      case 'pin':
        return Icons.pin;
      case 'grid_on':
        return Icons.grid_on;
      case 'loop':
        return Icons.loop;
      case 'sort':
        return Icons.sort;
      case 'hive':
        return Icons.hive;
      case 'account_tree':
        return Icons.account_tree;
      case 'extension':
        return Icons.extension;
      default:
        return Icons.code;
    }
  }
}

class ProgramDetailScreen extends ConsumerWidget {
  final ProgramModel program;

  const ProgramDetailScreen({super.key, required this.program});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final completed = ref.watch(completedProgramsProvider);
    final bookmarked = ref.watch(bookmarkedProgramsProvider);
    final isCompleted = completed.contains(program.id);
    final isBookmarked = bookmarked.contains(program.id);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(program.title),
          actions: [
            IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked ? theme.colorScheme.primary : null,
              ),
              onPressed: () {
                ref.read(bookmarkedProgramsProvider.notifier).toggle(program.id);
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                Share.share(
                  'Java Program: ${program.title}\n\nProblem: ${program.problemStatement}\n\nTime Complexity: ${program.timeComplexity}\n\nApp: SaiKumarEduTech - Java Master',
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Algorithm'),
              Tab(text: 'Code'),
              Tab(text: 'Output'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  // Tab 1: Algorithm & Info
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Problem Statement',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          program.problemStatement,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Explanation',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          program.explanation,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        // Complexity Card
                        Card(
                          elevation: 0,
                          color: theme.colorScheme.surfaceContainerLow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text('Time Complexity', style: theme.textTheme.labelMedium),
                                    const SizedBox(height: 4),
                                    Text(
                                      program.timeComplexity,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  height: 32,
                                  color: theme.colorScheme.outlineVariant,
                                ),
                                Column(
                                  children: [
                                    Text('Space Complexity', style: theme.textTheme.labelMedium),
                                    const SizedBox(height: 4),
                                    Text(
                                      program.spaceComplexity,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Algorithm Steps',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          program.algorithm,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        // Mark Completed Action Button
                        Center(
                          child: FilledButton.icon(
                            onPressed: () {
                              ref.read(completedProgramsProvider.notifier).markCompleted(program.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: theme.colorScheme.onPrimary),
                                      const SizedBox(width: 8),
                                      const Text('Program marked as completed!'),
                                    ],
                                  ),
                                  backgroundColor: theme.colorScheme.primary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: Icon(isCompleted ? Icons.check : Icons.assignment_turned_in),
                            label: Text(isCompleted ? 'Completed' : 'Mark Completed'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(200, 48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab 2: Code
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CodeBlock(code: program.code),
                      ],
                    ),
                  ),

                  // Tab 3: Output
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Expected Console Output',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                          ),
                          child: Text(
                            program.output,
                            style: TextStyle(
                              color: Colors.greenAccent[400],
                              fontFamily: 'Courier',
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
