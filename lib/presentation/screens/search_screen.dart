import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'programs_screen.dart';
import 'notes_screen.dart';
import '../../data/models/models.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final questionsAsync = ref.watch(questionsFutureProvider);
    final programsAsync = ref.watch(programsFutureProvider);
    final notesAsync = ref.watch(notesFutureProvider);

    List<dynamic> results = [];

    if (_query.trim().isNotEmpty) {
      final queryLower = _query.toLowerCase();

      if (questionsAsync.value != null) {
        results.addAll(questionsAsync.value!.where((q) =>
            q.question.toLowerCase().contains(queryLower) ||
            q.answer.toLowerCase().contains(queryLower) ||
            q.tags.any((t) => t.toLowerCase().contains(queryLower))));
      }

      if (programsAsync.value != null) {
        results.addAll(programsAsync.value!.where((p) =>
            p.title.toLowerCase().contains(queryLower) ||
            p.problemStatement.toLowerCase().contains(queryLower)));
      }

      if (notesAsync.value != null) {
        results.addAll(notesAsync.value!.where((n) =>
            n.title.toLowerCase().contains(queryLower) ||
            n.description.toLowerCase().contains(queryLower)));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search java concepts, programs, notes...',
            border: InputBorder.none,
          ),
          onChanged: (val) {
            setState(() {
              _query = val;
            });
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _query = '';
                });
              },
            ),
        ],
      ),
      body: _query.trim().isEmpty
          ? _buildSuggestionsHelp(theme)
          : (results.isEmpty
              ? _buildNoResults(theme)
              : _buildResultsList(results, theme)),
    );
  }

  Widget _buildSuggestionsHelp(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Type to Search Everything',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search instantly across interview questions, full Java source code examples, and study guide topics.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(ThemeData theme) {
    return Center(
      child: Text(
        'No matches found for "$_query"',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildResultsList(List<dynamic> results, ThemeData theme) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = results[index];
        String title = '';
        String subtitle = '';
        IconData icon = Icons.help;
        Color color = theme.colorScheme.primary;

        if (item is QuestionModel) {
          title = item.question;
          subtitle = 'Question • ${item.difficulty}';
          icon = Icons.question_answer;
          color = Colors.blue;
        } else if (item is ProgramModel) {
          title = item.title;
          subtitle = 'Program • ${item.timeComplexity}';
          icon = Icons.code;
          color = Colors.green;
        } else if (item is NoteModel) {
          title = item.title;
          subtitle = 'Study Note';
          icon = Icons.book;
          color = Colors.purple;
        }

        return Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 20),
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
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _handleItemTap(item),
          ),
        );
      },
    );
  }

  void _handleItemTap(dynamic item) {
    if (item is QuestionModel) {
      ref.read(recentlyViewedProvider.notifier).add('question', item.id, item.question);
      _showQuestionPreviewDialog(item);
    } else if (item is ProgramModel) {
      ref.read(recentlyViewedProvider.notifier).add('program', item.id, item.title);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProgramDetailScreen(program: item),
        ),
      );
    } else if (item is NoteModel) {
      ref.read(recentlyViewedProvider.notifier).add('note', item.id, item.title);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteDetailScreen(note: item),
        ),
      );
    }
  }

  void _showQuestionPreviewDialog(QuestionModel q) {
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
