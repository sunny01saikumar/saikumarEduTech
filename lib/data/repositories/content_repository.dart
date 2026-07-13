import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';

class ContentRepository {
  final AssetBundle _assetBundle;

  ContentRepository({AssetBundle? assetBundle})
      : _assetBundle = assetBundle ?? rootBundle;

  // Caches
  List<CategoryModel>? _categoriesQuestions;
  List<CategoryModel>? _categoriesPrograms;
  List<CategoryModel>? _categoriesNotes;
  List<CategoryModel>? _categoriesQuiz;
  List<QuestionModel>? _questions;
  List<ProgramModel>? _programs;
  List<NoteModel>? _notes;
  List<QuizModel>? _quizList;
  List<TipModel>? _tips;

  Future<void> preloadAll() async {
    await getQuestions();
    await getPrograms();
    await getNotes();
    await getQuizList();
    await getTips();
  }

  Future<Map<String, List<CategoryModel>>> getCategories() async {
    if (_categoriesQuestions != null) {
      return {
        'questions': _categoriesQuestions!,
        'programs': _categoriesPrograms!,
        'notes': _categoriesNotes!,
        'quiz': _categoriesQuiz!,
      };
    }

    try {
      final jsonStr = await _assetBundle.loadString('assets/json/categories.json');
      final Map<String, dynamic> data = jsonDecode(jsonStr);

      _categoriesQuestions = (data['questions'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
      _categoriesPrograms = (data['programs'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
      _categoriesNotes = (data['notes'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
      _categoriesQuiz = (data['quiz'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();

      // Update categories question counts dynamically based on loaded questions
      final qList = await getQuestions();
      for (int i = 0; i < _categoriesQuestions!.length; i++) {
        final cat = _categoriesQuestions![i];
        final count = qList.where((q) => q.category == cat.id).length;
        _categoriesQuestions![i] = cat.copyWith(count: count);
      }

      return {
        'questions': _categoriesQuestions!,
        'programs': _categoriesPrograms!,
        'notes': _categoriesNotes!,
        'quiz': _categoriesQuiz!,
      };
    } catch (_) {
      return {'questions': [], 'programs': [], 'notes': [], 'quiz': []};
    }
  }

  Future<List<QuestionModel>> getQuestions() async {
    if (_questions != null) return _questions!;
    try {
      final jsonStr = await _assetBundle.loadString('assets/json/questions.json');
      final List data = jsonDecode(jsonStr);
      _questions = data.map((e) => QuestionModel.fromJson(e)).toList();
      return _questions!;
    } catch (_) {
      return [];
    }
  }

  Future<List<ProgramModel>> getPrograms() async {
    if (_programs != null) return _programs!;
    try {
      final jsonStr = await _assetBundle.loadString('assets/json/programs.json');
      final List data = jsonDecode(jsonStr);
      _programs = data.map((e) => ProgramModel.fromJson(e)).toList();
      return _programs!;
    } catch (_) {
      return [];
    }
  }

  Future<List<NoteModel>> getNotes() async {
    if (_notes != null) return _notes!;
    try {
      final jsonStr = await _assetBundle.loadString('assets/json/notes.json');
      final List data = jsonDecode(jsonStr);
      _notes = data.map((e) => NoteModel.fromJson(e)).toList();
      return _notes!;
    } catch (_) {
      return [];
    }
  }

  Future<List<QuizModel>> getQuizList() async {
    if (_quizList != null) return _quizList!;
    try {
      final jsonStr = await _assetBundle.loadString('assets/json/quiz.json');
      final List data = jsonDecode(jsonStr);
      _quizList = data.map((e) => QuizModel.fromJson(e)).toList();
      return _quizList!;
    } catch (_) {
      return [];
    }
  }

  Future<List<TipModel>> getTips() async {
    if (_tips != null) return _tips!;
    try {
      final jsonStr = await _assetBundle.loadString('assets/json/tips.json');
      final List data = jsonDecode(jsonStr);
      _tips = data.map((e) => TipModel.fromJson(e)).toList();
      return _tips!;
    } catch (_) {
      return [];
    }
  }
}
