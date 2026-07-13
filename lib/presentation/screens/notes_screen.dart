import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/providers.dart';
import '../../data/models/models.dart';
import '../widgets/ad_widgets.dart';

// Safe state for unlocked premium notes category IDs
final unlockedNotesCategoriesProvider = StateProvider<Set<String>>((ref) => {});

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  CategoryModel? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    if (_selectedCategory == null) {
      return _buildCategorySelector();
    } else {
      return _buildNotesList();
    }
  }

  Widget _buildCategorySelector() {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesFutureProvider);
    final unlockedCategories = ref.watch(unlockedNotesCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Notes'),
        centerTitle: true,
      ),
      body: categoriesAsync.when(
        data: (cats) {
          final list = cats['notes'] ?? [];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cat = list[index];
              // Let's locks categories that are microservices, design_patterns, sql
              final isLocked = (cat.id == 'microservices' || cat.id == 'design_patterns' || cat.id == 'sql') &&
                  !unlockedCategories.contains(cat.id);

              return Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isLocked ? Colors.orange.shade100 : theme.colorScheme.tertiaryContainer,
                    child: Icon(
                      isLocked ? Icons.lock : _getIcon(cat.icon),
                      color: isLocked ? Colors.orange.shade800 : theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        cat.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (isLocked) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Premium',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(isLocked ? 'Watch an ad to unlock this study note.' : 'Comprehensive developer tutorials.'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    if (isLocked) {
                      _promptUnlock(cat.id, cat.name);
                    } else {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load note categories')),
      ),
    );
  }

  void _promptUnlock(String categoryId, String categoryName) {
    AdService.showRewarded(
      context,
      onRewardEarned: () {
        ref.read(unlockedNotesCategoriesProvider.notifier).update((state) => {...state, categoryId});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$categoryName section successfully unlocked!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _selectedCategory = ref.read(categoriesFutureProvider).value?['notes']?.firstWhere((c) => c.id == categoryId);
        });
      },
      onFailed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to unlock content. Please try watching again.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Widget _buildNotesList() {
    final theme = Theme.of(context);
    final notesAsync = ref.watch(notesFutureProvider);

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
      body: notesAsync.when(
        data: (notes) {
          final list = notes.where((n) => n.category == _selectedCategory!.id).toList();

          if (list.isEmpty) {
            return const Center(child: Text('No notes available in this category yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final note = list[index];
              return Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
                ),
                child: ListTile(
                  title: Text(
                    note.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    note.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ref.read(recentlyViewedProvider.notifier).add('note', note.id, note.title);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteDetailScreen(note: note),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load notes')),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'school':
        return Icons.school;
      case 'list_alt':
        return Icons.list_alt;
      case 'developer_board':
        return Icons.developer_board;
      case 'bolt':
        return Icons.bolt;
      case 'hub':
        return Icons.hub;
      case 'category':
        return Icons.category;
      case 'database':
        return Icons.storage;
      default:
        return Icons.notes;
    }
  }
}

class NoteDetailScreen extends ConsumerWidget {
  final NoteModel note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookmarked = ref.watch(bookmarkedNotesProvider);
    final isBookmarked = bookmarked.contains(note.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(note.title),
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? theme.colorScheme.primary : null,
            ),
            onPressed: () {
              ref.read(bookmarkedNotesProvider.notifier).toggle(note.id);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Overview Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Concept Overview',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    note.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Markdown Contents
            MarkdownBody(
              data: note.examples,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                code: TextStyle(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  fontFamily: 'Courier',
                  fontSize: 13,
                ),
                codeblockDecoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Summary Card
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.summarize, color: theme.colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Summary',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      note.summary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
