import 'question_model.dart';

class Lesson {
  final String id;
  final String title;
  final String icon;
  final String category;
  final int level;
  final bool isLocked;
  final int xpReward;
  final String description;
  final List<Question> questions;

  Lesson({
    required this.id,
    required this.title,
    required this.icon,
    required this.category,
    required this.level,
    required this.isLocked,
    required this.xpReward,
    required this.description,
    required this.questions,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      icon: json['icon'] ?? '📚',
      category: json['category'] ?? 'General',
      level: json['level'] ?? 1,
      isLocked: json['isLocked'] ?? true,
      xpReward: json['xpReward'] ?? 10,
      description: json['description'] ?? '',
      questions: (json['questions'] as List?)
          ?.map((q) => Question.fromJson(q))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'category': category,
      'level': level,
      'isLocked': isLocked,
      'xpReward': xpReward,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}