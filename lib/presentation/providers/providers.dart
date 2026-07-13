import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/models.dart';
import '../../data/repositories/content_repository.dart';

// --- Services & Repositories ---
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize SharedPreferences in main.dart first');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StorageService(prefs);
});

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository();
});

// --- Theme & Settings Providers ---
class DarkModeNotifier extends StateNotifier<bool> {
  final StorageService _storage;
  DarkModeNotifier(this._storage) : super(_storage.isDarkMode());

  Future<void> toggle() async {
    final newValue = !state;
    await _storage.setDarkMode(newValue);
    state = newValue;
  }
}

final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return DarkModeNotifier(storage);
});

class TextSizeNotifier extends StateNotifier<double> {
  final StorageService _storage;
  TextSizeNotifier(this._storage) : super(_storage.getTextSizeMultiplier());

  Future<void> setMultiplier(double value) async {
    await _storage.setTextSizeMultiplier(value);
    state = value;
  }
}

final textSizeMultiplierProvider = StateNotifierProvider<TextSizeNotifier, double>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return TextSizeNotifier(storage);
});

// --- Data Fetching Providers ---
final categoriesFutureProvider = FutureProvider<Map<String, List<CategoryModel>>>((ref) async {
  final repository = ref.watch(contentRepositoryProvider);
  return await repository.getCategories();
});

final questionsFutureProvider = FutureProvider<List<QuestionModel>>((ref) async {
  final repository = ref.watch(contentRepositoryProvider);
  return await repository.getQuestions();
});

final programsFutureProvider = FutureProvider<List<ProgramModel>>((ref) async {
  final repository = ref.watch(contentRepositoryProvider);
  return await repository.getPrograms();
});

final notesFutureProvider = FutureProvider<List<NoteModel>>((ref) async {
  final repository = ref.watch(contentRepositoryProvider);
  return await repository.getNotes();
});

final quizListFutureProvider = FutureProvider<List<QuizModel>>((ref) async {
  final repository = ref.watch(contentRepositoryProvider);
  return await repository.getQuizList();
});

final tipsFutureProvider = FutureProvider<List<TipModel>>((ref) async {
  final repository = ref.watch(contentRepositoryProvider);
  return await repository.getTips();
});

// --- Bookmarks Providers ---
class BookmarkedQuestionsNotifier extends StateNotifier<List<int>> {
  final StorageService _storage;
  BookmarkedQuestionsNotifier(this._storage) : super(_storage.getBookmarkedQuestions());

  Future<void> toggle(int id) async {
    await _storage.toggleQuestionBookmark(id);
    state = _storage.getBookmarkedQuestions();
  }
}

final bookmarkedQuestionsProvider = StateNotifierProvider<BookmarkedQuestionsNotifier, List<int>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return BookmarkedQuestionsNotifier(storage);
});

class BookmarkedProgramsNotifier extends StateNotifier<List<int>> {
  final StorageService _storage;
  BookmarkedProgramsNotifier(this._storage) : super(_storage.getBookmarkedPrograms());

  Future<void> toggle(int id) async {
    await _storage.toggleProgramBookmark(id);
    state = _storage.getBookmarkedPrograms();
  }
}

final bookmarkedProgramsProvider = StateNotifierProvider<BookmarkedProgramsNotifier, List<int>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return BookmarkedProgramsNotifier(storage);
});

class BookmarkedNotesNotifier extends StateNotifier<List<int>> {
  final StorageService _storage;
  BookmarkedNotesNotifier(this._storage) : super(_storage.getBookmarkedNotes());

  Future<void> toggle(int id) async {
    await _storage.toggleNoteBookmark(id);
    state = _storage.getBookmarkedNotes();
  }
}

final bookmarkedNotesProvider = StateNotifierProvider<BookmarkedNotesNotifier, List<int>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return BookmarkedNotesNotifier(storage);
});

// --- Progress Providers ---
class ReadQuestionsNotifier extends StateNotifier<List<int>> {
  final StorageService _storage;
  final Ref _ref;
  ReadQuestionsNotifier(this._storage, this._ref) : super(_storage.getReadQuestions());

  Future<void> markRead(int id) async {
    if (!state.contains(id)) {
      await _storage.markQuestionAsRead(id);
      state = _storage.getReadQuestions();
      _ref.read(streakProvider.notifier).updateStreak();
    }
  }
}

final readQuestionsProvider = StateNotifierProvider<ReadQuestionsNotifier, List<int>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ReadQuestionsNotifier(storage, ref);
});

class CompletedProgramsNotifier extends StateNotifier<List<int>> {
  final StorageService _storage;
  final Ref _ref;
  CompletedProgramsNotifier(this._storage, this._ref) : super(_storage.getCompletedPrograms());

  Future<void> markCompleted(int id) async {
    if (!state.contains(id)) {
      await _storage.markProgramAsCompleted(id);
      state = _storage.getCompletedPrograms();
      _ref.read(streakProvider.notifier).updateStreak();
    }
  }
}

final completedProgramsProvider = StateNotifierProvider<CompletedProgramsNotifier, List<int>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return CompletedProgramsNotifier(storage, ref);
});

// --- Recently Viewed ---
class RecentlyViewedNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final StorageService _storage;
  RecentlyViewedNotifier(this._storage) : super(_storage.getRecentlyViewed());

  Future<void> add(String type, int id, String title) async {
    await _storage.addRecentlyViewed(type, id, title);
    state = _storage.getRecentlyViewed();
  }
}

final recentlyViewedProvider = StateNotifierProvider<RecentlyViewedNotifier, List<Map<String, dynamic>>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return RecentlyViewedNotifier(storage);
});

// --- Quiz History ---
class QuizHistoryNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final StorageService _storage;
  final Ref _ref;
  QuizHistoryNotifier(this._storage, this._ref) : super(_storage.getQuizHistory());

  Future<void> addResult(String category, int score, int total) async {
    await _storage.saveQuizResult(category, score, total);
    state = _storage.getQuizHistory();
    _ref.read(streakProvider.notifier).updateStreak();
  }
}

final quizHistoryProvider = StateNotifierProvider<QuizHistoryNotifier, List<Map<String, dynamic>>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return QuizHistoryNotifier(storage, ref);
});

// --- Daily Streak State ---
class StreakNotifier extends StateNotifier<int> {
  final StorageService _storage;
  StreakNotifier(this._storage) : super(_storage.getStreakCount());

  void updateStreak() {
    state = _storage.getStreakCount();
  }
}

final streakProvider = StateNotifierProvider<StreakNotifier, int>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return StreakNotifier(storage);
});

// --- Reset Progress Helper ---
final resetProgressProvider = Provider<Function>((ref) {
  return () async {
    final storage = ref.read(storageServiceProvider);
    await storage.resetAllProgress();
    
    // Refresh all states
    ref.read(bookmarkedQuestionsProvider.notifier).state = [];
    ref.read(bookmarkedProgramsProvider.notifier).state = [];
    ref.read(bookmarkedNotesProvider.notifier).state = [];
    ref.read(readQuestionsProvider.notifier).state = [];
    ref.read(completedProgramsProvider.notifier).state = [];
    ref.read(recentlyViewedProvider.notifier).state = [];
    ref.read(quizHistoryProvider.notifier).state = [];
    ref.read(streakProvider.notifier).updateStreak();
  };
});
