import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Keys
  static const String _keyDarkMode = 'setting_dark_mode';
  static const String _keyTextSizeMultiplier = 'setting_text_size_multiplier';
  static const String _keyBookmarkedQuestions = 'fav_questions';
  static const String _keyBookmarkedPrograms = 'fav_programs';
  static const String _keyBookmarkedNotes = 'fav_notes';
  static const String _keyReadQuestions = 'progress_read_questions';
  static const String _keyCompletedPrograms = 'progress_completed_programs';
  static const String _keyRecentlyViewed = 'recently_viewed';
  static const String _keyQuizHistory = 'quiz_history';
  static const String _keyStreakCount = 'streak_count';
  static const String _keyLastActivityDate = 'last_activity_date';

  // --- Settings ---
  bool isDarkMode() {
    return _prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_keyDarkMode, value);
  }

  double getTextSizeMultiplier() {
    return _prefs.getDouble(_keyTextSizeMultiplier) ?? 1.0;
  }

  Future<void> setTextSizeMultiplier(double value) async {
    await _prefs.setDouble(_keyTextSizeMultiplier, value);
  }

  // --- Bookmarks (Favorites) ---
  List<int> getBookmarkedQuestions() {
    final list = _prefs.getStringList(_keyBookmarkedQuestions) ?? [];
    return list.map((e) => int.parse(e)).toList();
  }

  Future<void> toggleQuestionBookmark(int id) async {
    final bookmarks = getBookmarkedQuestions();
    if (bookmarks.contains(id)) {
      bookmarks.remove(id);
    } else {
      bookmarks.add(id);
    }
    await _prefs.setStringList(
        _keyBookmarkedQuestions, bookmarks.map((e) => e.toString()).toList());
  }

  List<int> getBookmarkedPrograms() {
    final list = _prefs.getStringList(_keyBookmarkedPrograms) ?? [];
    return list.map((e) => int.parse(e)).toList();
  }

  Future<void> toggleProgramBookmark(int id) async {
    final bookmarks = getBookmarkedPrograms();
    if (bookmarks.contains(id)) {
      bookmarks.remove(id);
    } else {
      bookmarks.add(id);
    }
    await _prefs.setStringList(
        _keyBookmarkedPrograms, bookmarks.map((e) => e.toString()).toList());
  }

  List<int> getBookmarkedNotes() {
    final list = _prefs.getStringList(_keyBookmarkedNotes) ?? [];
    return list.map((e) => int.parse(e)).toList();
  }

  Future<void> toggleNoteBookmark(int id) async {
    final bookmarks = getBookmarkedNotes();
    if (bookmarks.contains(id)) {
      bookmarks.remove(id);
    } else {
      bookmarks.add(id);
    }
    await _prefs.setStringList(
        _keyBookmarkedNotes, bookmarks.map((e) => e.toString()).toList());
  }

  // --- Progress Tracking (Questions Read & Programs Completed) ---
  List<int> getReadQuestions() {
    final list = _prefs.getStringList(_keyReadQuestions) ?? [];
    return list.map((e) => int.parse(e)).toList();
  }

  Future<void> markQuestionAsRead(int id) async {
    final read = getReadQuestions();
    if (!read.contains(id)) {
      read.add(id);
      await _prefs.setStringList(
          _keyReadQuestions, read.map((e) => e.toString()).toList());
      await updateStreak();
    }
  }

  List<int> getCompletedPrograms() {
    final list = _prefs.getStringList(_keyCompletedPrograms) ?? [];
    return list.map((e) => int.parse(e)).toList();
  }

  Future<void> markProgramAsCompleted(int id) async {
    final completed = getCompletedPrograms();
    if (!completed.contains(id)) {
      completed.add(id);
      await _prefs.setStringList(
          _keyCompletedPrograms, completed.map((e) => e.toString()).toList());
      await updateStreak();
    }
  }

  // --- Recently Viewed (Continue Learning) ---
  // Structure: List of maps containing { 'type': 'question|program|note', 'id': id, 'title': title, 'time': epoch }
  List<Map<String, dynamic>> getRecentlyViewed() {
    final data = _prefs.getString(_keyRecentlyViewed);
    if (data == null) return [];
    try {
      final list = jsonDecode(data) as List;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addRecentlyViewed(String type, int id, String title) async {
    final list = getRecentlyViewed();
    // Remove if already exists
    list.removeWhere((item) => item['type'] == type && item['id'] == id);
    // Insert at front
    list.insert(0, {
      'type': type,
      'id': id,
      'title': title,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    // Keep last 10 items
    if (list.length > 10) {
      list.removeRange(10, list.length);
    }
    await _prefs.setString(_keyRecentlyViewed, jsonEncode(list));
  }

  // --- Quiz History ---
  // Structure: List of maps containing { 'category': cat, 'score': s, 'total': t, 'date': isoString }
  List<Map<String, dynamic>> getQuizHistory() {
    final data = _prefs.getString(_keyQuizHistory);
    if (data == null) return [];
    try {
      final list = jsonDecode(data) as List;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveQuizResult(String category, int score, int total) async {
    final history = getQuizHistory();
    history.add({
      'category': category,
      'score': score,
      'total': total,
      'date': DateTime.now().toIso8601String(),
    });
    await _prefs.setString(_keyQuizHistory, jsonEncode(history));
    await updateStreak();
  }

  // --- Daily Streak Calculation ---
  int getStreakCount() {
    return _prefs.getInt(_keyStreakCount) ?? 0;
  }

  Future<void> updateStreak() async {
    final lastDateStr = _prefs.getString(_keyLastActivityDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastDateStr == null) {
      // First activity
      await _prefs.setInt(_keyStreakCount, 1);
      await _prefs.setString(_keyLastActivityDate, today.toIso8601String());
      return;
    }

    final lastDate = DateTime.parse(lastDateStr);
    final difference = today.difference(lastDate).inDays;

    if (difference == 1) {
      // Consecutive day
      int currentStreak = getStreakCount();
      await _prefs.setInt(_keyStreakCount, currentStreak + 1);
      await _prefs.setString(_keyLastActivityDate, today.toIso8601String());
    } else if (difference > 1) {
      // Streak broken
      await _prefs.setInt(_keyStreakCount, 1);
      await _prefs.setString(_keyLastActivityDate, today.toIso8601String());
    }
    // If difference == 0, it is the same day. Do nothing.
  }

  // --- Reset All Progress ---
  Future<void> resetAllProgress() async {
    await _prefs.remove(_keyBookmarkedQuestions);
    await _prefs.remove(_keyBookmarkedPrograms);
    await _prefs.remove(_keyBookmarkedNotes);
    await _prefs.remove(_keyReadQuestions);
    await _prefs.remove(_keyCompletedPrograms);
    await _prefs.remove(_keyRecentlyViewed);
    await _prefs.remove(_keyQuizHistory);
    await _prefs.remove(_keyStreakCount);
    await _prefs.remove(_keyLastActivityDate);
  }
}
