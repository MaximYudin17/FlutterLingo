import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../models/lesson_model.dart';
import '../models/question_model.dart';

class DataService {
  static User _userData = User(
    name: 'Flutter Student',
    email: 'student@flutter.com',
    streak: 7,
    lingots: 45,
    hearts: 5,
    xp: 1250,
    languageProgress: {
      'Widgets': 40, 
      'State': 25, 
      'Layout': 30, 
      'Basics': 50, 
    },
    completedLessons: ['widgets_basics'],
  );

  static User get userData => _userData;

  // Система рейтинга
  static Map<String, dynamic> get userRank {
    final int xp = _userData.xp;
    
    if (xp >= 2000) return {'rank': 'Flutter Мастер', 'level': 5, 'color': 0xFFFFD700};
    if (xp >= 1500) return {'rank': 'Flutter Эксперт', 'level': 4, 'color': 0xFFFF6B6B};
    if (xp >= 1000) return {'rank': 'Flutter Разработчик', 'level': 3, 'color': 0xFF4ECDC4};
    if (xp >= 500) return {'rank': 'Flutter Ученик', 'level': 2, 'color': 0xFF45B7D1};
    return {'rank': 'Flutter Новичок', 'level': 1, 'color': 0xFF96CEB4};
  }

  // Завершение урока
  static void completeLesson(String lessonId, int xpReward, int correctAnswers, int totalQuestions) {
    if (!_userData.completedLessons.contains(lessonId)) {
      _userData.completedLessons.add(lessonId);
      
      final double successRate = (correctAnswers / totalQuestions) * 100;
      final int bonusXp = successRate == 100 ? (xpReward * 0.2).round() : 0;
      
      _userData.xp += xpReward + bonusXp;
      _userData.lingots += 5 + (bonusXp > 0 ? 3 : 0);
      
      _updateCategoryProgress(lessonId, successRate);
      _userData.streak++;
    }
  }

  static void _updateCategoryProgress(String lessonId, double successRate) {
    final progressIncrement = (successRate / 20).round();
    _userData.languageProgress.update(
      'Widgets', 
      (value) => (value + progressIncrement).clamp(0, 100),
      ifAbsent: () => progressIncrement.clamp(0, 100)
    );
  }

  // Получение статистики пользователя
  static Map<String, dynamic> getUserStats() {
    final totalLessons = 4;
    final completedLessons = _userData.completedLessons.length;
    final completionRate = totalLessons > 0 ? (completedLessons / totalLessons * 100).round() : 0;
    
    return {
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'completionRate': completionRate,
      'averageProgress': _calculateAverageProgress(),
      'nextRankXp': _calculateNextRankXp(),
    };
  }

  static int _calculateAverageProgress() {
    if (_userData.languageProgress.isEmpty) return 0;
    final sum = _userData.languageProgress.values.reduce((a, b) => a + b);
    return (sum / _userData.languageProgress.length).round();
  }

  static int _calculateNextRankXp() {
    final int currentXp = _userData.xp;
    if (currentXp < 500) return 500;
    if (currentXp < 1000) return 1000;
    if (currentXp < 1500) return 1500;
    if (currentXp < 2000) return 2000;
    return 0;
  }

  // Загрузка уроков из JSON
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

  static Future<Lesson?> getLessonById(String lessonId) async {
    try {
      final lessons = await loadLessons();
      return lessons.firstWhere((lesson) => lesson.id == lessonId);
    } catch (e) {
      print('Lesson not found: $lessonId');
      return null;
    }
  }

  // Резервные уроки
  static List<Lesson> _getDefaultLessons() {
    return [
      Lesson(
        id: 'widgets_basics',
        title: 'Основы Widgets',
        icon: '🧩',
        category: 'Widgets',
        level: 1,
        isLocked: false,
        xpReward: 25,
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
    ];
  }
}