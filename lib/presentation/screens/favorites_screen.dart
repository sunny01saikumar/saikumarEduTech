import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'programs_screen.dart';
import 'notes_screen.dart';
import '../../data/models/models.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favQuestions = ref.watch(bookmarkedQuestionsProvider);
    final favPrograms = ref.watch(bookmarkedProgramsProvider);
    final favNotes = ref.watch(bookmarkedNotesProvider);

    final questionsAsync = ref.watch(questionsFutureProvider);
    final programsAsync = ref.watch(programsFutureProvider);
    final notesAsync = ref.watch(notesFutureProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookmarks'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Questions'),
              Tab(text: 'Programs'),
              Tab(text: 'Notes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Questions
            questionsAsync.when(
              data: (list) {
                final bookmarkedList = list.where((q) => favQuestions.contains(q.id)).toList();
                if (bookmarkedList.isEmpty) {
                  return _buildEmptyState(theme, 'No bookmarked questions.', Icons.question_answer_outlined);
                }
                return _buildQuestionsList(context, ref, bookmarkedList, theme);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Failed to load bookmarks')),
            ),

            // Tab 2: Programs
            programsAsync.when(
              data: (list) {
                final bookmarkedList = list.where((p) => favPrograms.contains(p.id)).toList();
                if (bookmarkedList.isEmpty) {
                  return _buildEmptyState(theme, 'No bookmarked programs.', Icons.code_outlined);
                }
                return _buildProgramsList(context, bookmarkedList, theme);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Failed to load bookmarks')),
            ),

            // Tab 3: Notes
            notesAsync.when(
              data: (list) {
                final bookmarkedList = list.where((n) => favNotes.contains(n.id)).toList();
                if (bookmarkedList.isEmpty) {
                  return _buildEmptyState(theme, 'No bookmarked notes.', Icons.menu_book_outlined);
                }
                return _buildNotesList(context, bookmarkedList, theme);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Failed to load bookmarks')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(
      BuildContext context, WidgetRef ref, List<QuestionModel> list, ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final q = list[index];
        return Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
          ),
          child: ListTile(
            title: Text(
              q.question,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('Category: ${q.category.replaceAll('_', ' ').toUpperCase()} • ${q.difficulty}'),
            trailing: IconButton(
              icon: const Icon(Icons.bookmark_remove, color: Colors.red),
              onPressed: () {
                ref.read(bookmarkedQuestionsProvider.notifier).toggle(q.id);
              },
            ),
            onTap: () => _showQuestionPreviewDialog(context, q),
          ),
        );
      },
    );
  }

  Widget _buildProgramsList(BuildContext context, List<ProgramModel> list, ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final p = list[index];
        return Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
          ),
          child: ListTile(
            title: Text(
              p.title,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Time: ${p.timeComplexity} • Space: ${p.spaceComplexity}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProgramDetailScreen(program: p),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNotesList(BuildContext context, List<NoteModel> list, ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final n = list[index];
        return Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
          ),
          child: ListTile(
            title: Text(
              n.title,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              n.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(note: n),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showQuestionPreviewDialog(BuildContext context, QuestionModel q) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(q.question),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Difficulty: ${q.difficulty}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: q.difficulty.toLowerCase() == 'easy'
                        ? Colors.green
                        : (q.difficulty.toLowerCase() == 'medium' ? Colors.orange : Colors.red),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Answer:',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(q.answer),
                const SizedBox(height: 12),
                Text(
                  'Explanation:',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(q.explanation),
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
}
