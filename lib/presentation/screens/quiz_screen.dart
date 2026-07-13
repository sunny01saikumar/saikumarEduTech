import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../../data/models/models.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  CategoryModel? _selectedCategory;
  List<QuizModel> _quizQuestions = [];
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  int _score = 0;
  bool _quizFinished = false;

  // Track answers for review: maps question index to chosen option index
  final Map<int, int> _userAnswers = {};

  @override
  Widget build(BuildContext context) {
    if (_selectedCategory == null) {
      return _buildCategorySelector();
    } else if (_quizFinished) {
      return _buildQuizSummary();
    } else {
      return _buildQuizGameplay();
    }
  }

  Widget _buildCategorySelector() {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily MCQ Quiz'),
        centerTitle: true,
      ),
      body: categoriesAsync.when(
        data: (cats) {
          final list = cats['quiz'] ?? [];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cat = list[index];
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
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(_getIcon(cat.icon), color: theme.colorScheme.onPrimaryContainer),
                  ),
                  title: Text(
                    cat.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Test your knowledge & maintain your streak!'),
                  trailing: const Icon(Icons.play_arrow, color: Colors.green),
                  onTap: () => _startQuiz(cat),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load quiz categories')),
      ),
    );
  }

  void _startQuiz(CategoryModel category) async {
    final repository = ref.read(contentRepositoryProvider);
    final allQuizItems = await repository.getQuizList();
    // Filter questions by category
    final filtered = allQuizItems.where((q) => q.category == category.id).toList();

    // Shuffle questions for randomized experience
    filtered.shuffle();

    setState(() {
      _selectedCategory = category;
      _quizQuestions = filtered.take(5).toList(); // Load up to 5 questions
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _isAnswered = false;
      _score = 0;
      _quizFinished = false;
      _userAnswers.clear();
    });
  }

  Widget _buildQuizGameplay() {
    final theme = Theme.of(context);

    if (_quizQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(_selectedCategory!.name)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No quiz questions found for this category.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() => _selectedCategory = null),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final question = _quizQuestions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${_selectedCategory!.name} (${_currentQuestionIndex + 1}/${_quizQuestions.length})'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showExitWarning();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Linear Progress Bar
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _quizQuestions.length,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 24),
            // Question Card
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  question.question,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Options List
            ...List.generate(question.options.length, (index) {
              final optionText = question.options[index];
              return _buildOptionButton(index, optionText, question);
            }),

            const SizedBox(height: 24),

            // Explanation Display (When answered)
            if (_isAnswered) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explanation',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      question.explanation,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _nextQuestion,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _currentQuestionIndex == _quizQuestions.length - 1 ? 'Finish Quiz' : 'Next Question',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(int index, String text, QuizModel question) {
    final theme = Theme.of(context);
    final isCorrectOption = index == question.correctOptionIndex;
    final isSelectedOption = index == _selectedOptionIndex;

    Color buttonColor = theme.colorScheme.surfaceContainerLow;
    Color borderSideColor = theme.colorScheme.outlineVariant.withOpacity(0.5);
    Color textColor = theme.colorScheme.onSurface;

    if (_isAnswered) {
      if (isCorrectOption) {
        buttonColor = Colors.green.withOpacity(0.15);
        borderSideColor = Colors.green;
        textColor = Colors.green[800]!;
      } else if (isSelectedOption) {
        buttonColor = Colors.red.withOpacity(0.15);
        borderSideColor = Colors.red;
        textColor = Colors.red[800]!;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: OutlinedButton(
        onPressed: _isAnswered ? null : () => _submitAnswer(index),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          backgroundColor: buttonColor,
          side: BorderSide(color: borderSideColor, width: _isAnswered && (isCorrectOption || isSelectedOption) ? 2 : 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isAnswered && isCorrectOption 
                    ? Colors.green 
                    : (_isAnswered && isSelectedOption ? Colors.red : theme.colorScheme.surfaceContainerHighest),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _isAnswered && (isCorrectOption || isSelectedOption) 
                        ? Colors.white 
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontWeight: isSelectedOption || (_isAnswered && isCorrectOption) 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
            ),
            if (_isAnswered && isCorrectOption)
              const Icon(Icons.check_circle, color: Colors.green)
            else if (_isAnswered && isSelectedOption)
              const Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
  }

  void _submitAnswer(int index) {
    final question = _quizQuestions[_currentQuestionIndex];
    setState(() {
      _selectedOptionIndex = index;
      _isAnswered = true;
      _userAnswers[_currentQuestionIndex] = index;
      if (index == question.correctOptionIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
      });
    } else {
      // Save stats to Riverpod Providers (updates SharedPreferences)
      ref.read(quizHistoryProvider.notifier).addResult(
        _selectedCategory!.id,
        _score,
        _quizQuestions.length,
      );
      setState(() {
        _quizFinished = true;
      });
    }
  }

  Widget _buildQuizSummary() {
    final theme = Theme.of(context);
    final percent = (_score / _quizQuestions.length) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score Circle Card
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      'Your Score',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$_score / ${_quizQuestions.length}',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Accuracy: ${percent.round()}%',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Review Answers',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Summary List
            ...List.generate(_quizQuestions.length, (index) {
              final q = _quizQuestions[index];
              final chosenIdx = _userAnswers[index];
              final isCorrect = chosenIdx == q.correctOptionIndex;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Question ${index + 1}',
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(q.question, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Your Answer: ${chosenIdx != null ? q.options[chosenIdx] : 'Unanswered'}',
                        style: TextStyle(color: isCorrect ? Colors.green[800] : Colors.red[800], fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      if (!isCorrect)
                        Text(
                          'Correct Answer: ${q.options[q.correctOptionIndex]}',
                          style: TextStyle(color: Colors.green[800], fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _selectedCategory = null),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back to Home'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _startQuiz(_selectedCategory!),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Retry Quiz'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExitWarning() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quit Quiz?'),
          content: const Text('Are you sure you want to exit? Your progress for this quiz will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedCategory = null;
                });
              },
              child: const Text('Quit'),
            ),
          ],
        );
      },
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'quiz':
        return Icons.quiz;
      case 'integration_instructions':
        return Icons.integration_instructions;
      case 'dns':
        return Icons.dns;
      case 'format_list_bulleted':
        return Icons.format_list_bulleted;
      case 'bubble_chart':
        return Icons.bubble_chart;
      default:
        return Icons.quiz;
    }
  }
}
