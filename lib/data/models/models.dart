class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int count;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.count = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? 'code',
      count: json['count'] ?? 0,
    );
  }

  CategoryModel copyWith({int? count}) {
    return CategoryModel(
      id: id,
      name: name,
      icon: icon,
      count: count ?? this.count,
    );
  }
}

class QuestionModel {
  final int id;
  final String category;
  final String question;
  final String answer;
  final String difficulty;
  final String explanation;
  final String example;
  final List<String> tags;
  final String tips;

  QuestionModel({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    required this.difficulty,
    required this.explanation,
    required this.example,
    required this.tags,
    required this.tips,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id']?.toString() ?? '0'),
      category: json['category'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      difficulty: json['difficulty'] ?? 'Easy',
      explanation: json['explanation'] ?? '',
      example: json['example'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      tips: json['tips'] ?? '',
    );
  }
}

class ProgramModel {
  final int id;
  final String category;
  final String title;
  final String problemStatement;
  final String explanation;
  final String algorithm;
  final String timeComplexity;
  final String spaceComplexity;
  final String code;
  final String output;

  ProgramModel({
    required this.id,
    required this.category,
    required this.title,
    required this.problemStatement,
    required this.explanation,
    required this.algorithm,
    required this.timeComplexity,
    required this.spaceComplexity,
    required this.code,
    required this.output,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id']?.toString() ?? '0'),
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      problemStatement: json['problemStatement'] ?? '',
      explanation: json['explanation'] ?? '',
      algorithm: json['algorithm'] ?? '',
      timeComplexity: json['timeComplexity'] ?? '',
      spaceComplexity: json['spaceComplexity'] ?? '',
      code: json['code'] ?? '',
      output: json['output'] ?? '',
    );
  }
}

class NoteModel {
  final int id;
  final String category;
  final String title;
  final String description;
  final String examples;
  final String summary;

  NoteModel({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.examples,
    required this.summary,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id']?.toString() ?? '0'),
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      examples: json['examples'] ?? '',
      summary: json['summary'] ?? '',
    );
  }
}

class QuizModel {
  final int id;
  final String category;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  QuizModel({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id']?.toString() ?? '0'),
      category: json['category'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctOptionIndex: json['correctOptionIndex'] is int 
          ? json['correctOptionIndex'] 
          : int.parse(json['correctOptionIndex']?.toString() ?? '0'),
      explanation: json['explanation'] ?? '',
    );
  }
}

class TipModel {
  final int id;
  final String title;
  final String content;

  TipModel({
    required this.id,
    required this.title,
    required this.content,
  });

  factory TipModel.fromJson(Map<String, dynamic> json) {
    return TipModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id']?.toString() ?? '0'),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
