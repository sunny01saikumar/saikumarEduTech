import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/providers.dart';
import '../../data/models/models.dart';
import '../widgets/code_block.dart';
import '../widgets/ad_widgets.dart';

class InterviewScreen extends ConsumerStatefulWidget {
  const InterviewScreen({super.key});

  @override
  ConsumerState<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends ConsumerState<InterviewScreen> {
  CategoryModel? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    if (_selectedCategory == null) {
      return _buildCategorySelector();
    } else {
      return _buildQuestionList();
    }
  }

  Widget _buildCategorySelector() {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Q&A'),
        centerTitle: true,
      ),
      body: categoriesAsync.when(
        data: (cats) {
          final list = cats['questions'] ?? [];
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
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  _getIcon(cat.icon),
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${cat.count} Questions',
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

  Widget _buildQuestionList() {
    final theme = Theme.of(context);
    final questionsAsync = ref.watch(questionsFutureProvider);
    final bookmarked = ref.watch(bookmarkedQuestionsProvider);
    final readQuestions = ref.watch(readQuestionsProvider);

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
      body: questionsAsync.when(
        data: (questions) {
          final list = questions.where((q) => q.category == _selectedCategory!.id).toList();

          if (list.isEmpty) {
            return const Center(child: Text('No questions available in this category yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (context, index) {
              // Insert Native Ad between question lists every 3 elements
              if (index > 0 && index % 3 == 0) {
                return const AdNative();
              }
              return const SizedBox(height: 12);
            },
            itemBuilder: (context, index) {
              final q = list[index];
              final isBookmarked = bookmarked.contains(q.id);
              final isRead = readQuestions.contains(q.id);

              return _buildQuestionCard(q, isBookmarked, isRead);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load questions')),
      ),
    );
  }

  Widget _buildQuestionCard(QuestionModel q, bool isBookmarked, bool isRead) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isRead 
              ? theme.colorScheme.primary.withOpacity(0.3) 
              : theme.colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getDifficultyColor(q.difficulty).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                q.difficulty,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _getDifficultyColor(q.difficulty),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (isRead)
              Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            q.question,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onExpansionChanged: (expanded) {
          if (expanded) {
            // Add to recently viewed
            ref.read(recentlyViewedProvider.notifier).add('question', q.id, q.question);
            // Mark as read
            ref.read(readQuestionsProvider.notifier).markRead(q.id);
            // Track view to show Interstitial Ads
            AdService.trackQuestionView(context, onComplete: () {});
          }
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
                const SizedBox(height: 8),
                Text(
                  'Answer',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  q.answer,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Explanation',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  q.explanation,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (q.example.isNotEmpty) ...[
                  Text(
                    'Example / Syntax',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CodeBlock(code: q.example),
                  const SizedBox(height: 16),
                ],
                if (q.tips.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Interview Tip',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                q.tips,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? theme.colorScheme.primary : null,
                      ),
                      onPressed: () {
                        ref.read(bookmarkedQuestionsProvider.notifier).toggle(q.id);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        Share.share(
                          'Java Interview Q&A\n\nQuestion: ${q.question}\n\nAnswer: ${q.answer}\n\nApp: SaiKumarEduTech - Java Master',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Color _getDifficultyColor(String diff) {
    switch (diff.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'code':
        return Icons.code;
      case 'corporate_fare':
        return Icons.corporate_fare;
      case 'error_outline':
        return Icons.error_outline;
      case 'view_list':
        return Icons.view_list;
      case 'waves':
        return Icons.waves;
      case 'alt_route':
        return Icons.alt_route;
      case 'memory':
        return Icons.memory;
      case 'text_fields':
        return Icons.text_fields;
      case 'settings_input_component':
        return Icons.settings_input_component;
      case 'storage':
        return Icons.storage;
      case 'cloud':
        return Icons.cloud;
      case 'table_chart':
        return Icons.table_chart;
      case 'architecture':
        return Icons.architecture;
      case 'lan':
        return Icons.lan;
      default:
        return Icons.help_outline;
    }
  }
}
