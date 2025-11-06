import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../models/lesson_model.dart';
import '../models/question_model.dart';

class DataService {
  static User get userData => User(
    name: 'Flutter Student',
    email: 'student@flutter.com',
    streak: 7,
    lingots: 45,
    hearts: 5,
    xp: 1250,
    languageProgress: {'widgets': 40, 'state': 25, 'layout': 30, 'basics': 50, 'navigation': 10},
    completedLessons: ['widgets_basics', 'flutter_basics'],
  );

  static Future<List<Lesson>> loadLessons() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/lessons.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      final List<dynamic> lessonsJson = jsonData['lessons'];
      return lessonsJson.map((lessonJson) => Lesson.fromJson(lessonJson)).toList();
    } catch (e) {
      print('Error loading JSON: $e');
      return _getDefaultLessons();
    }
  }

  static List<Lesson> _getDefaultLessons() {
    return [
      Lesson(
        id: 'widgets_basics',
        title: 'Основы Widgets',
        icon: '🧩',
        category: 'Widgets',
        level: 1,
        isLocked: false,
        xpReward: 10,
        description: 'Изучите базовые виджеты Flutter',
        questions: [
          Question(
            type: 'multiple_choice',
            question: 'Какой виджет используется для отображения текста?',
            correctAnswer: 'Text',
            options: ['Text', 'Container', 'Row', 'Column'],
            hint: 'Этот виджет отображает строку текста',
          ),
        ],
      ),
      Lesson(
        id: 'flutter_basics',
        title: 'Основы Flutter',
        icon: '🎯',
        category: 'Basics',
        level: 1,
        isLocked: false,
        xpReward: 8,
        description: 'Фундаментальные концепции Flutter',
        questions: [
          Question(
            type: 'multiple_choice',
            question: 'На каком языке программирования написан Flutter?',
            correctAnswer: 'Dart',
            options: ['Dart', 'Java', 'Kotlin', 'Swift'],
            hint: 'Язык разработанный Google',
          ),
        ],
      ),
    ];
  }
}