import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressChart extends StatelessWidget {
  final List<Map<String, dynamic>> quizHistory;

  const ProgressChart({super.key, required this.quizHistory});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (quizHistory.isEmpty) {
      return Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 48,
                color: theme.colorScheme.secondary.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No Quiz Activity Yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Complete quizzes to see your learning curve and accuracy trends over time.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Take last 5 quizzes
    final lastQuizzes = quizHistory.length > 5
        ? quizHistory.sublist(quizHistory.length - 5)
        : quizHistory;

    List<BarChartGroupData> getBarGroups() {
      return List.generate(lastQuizzes.length, (index) {
        final quiz = lastQuizzes[index];
        final double score = (quiz['score'] as num).toDouble();
        final double total = (quiz['total'] as num).toDouble();
        final double percent = total > 0 ? (score / total) * 100 : 0.0;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: percent,
              color: percent >= 75
                  ? Colors.green
                  : (percent >= 50 ? theme.colorScheme.primary : Colors.orange),
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            )
          ],
        );
      });
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Quiz Accuracy (%)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => theme.colorScheme.surfaceContainer,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final quiz = lastQuizzes[group.x.toInt()];
                        return BarTooltipItem(
                          '${quiz['category'].toString().replaceAll('_quiz', '').toUpperCase()}\n${rod.toY.round()}% Correct',
                          theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ) ?? const TextStyle(),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int idx = value.toInt();
                          if (idx >= 0 && idx < lastQuizzes.length) {
                            String name = lastQuizzes[idx]['category']
                                .toString()
                                .replaceAll('_quiz', '');
                            if (name.length > 5) name = '${name.substring(0, 5)}.';
                            return Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                name.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 9,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: getBarGroups(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
