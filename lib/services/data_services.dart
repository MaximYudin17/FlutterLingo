import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/lesson_model.dart';
import '../models/question_model.dart';
import 'supabase_service.dart';

class DataService {
  static User _currentUser = User(
    name: 'Гость',
    email: 'guest@flutter.com',
    streak: 0,
    lingots: 0,
    hearts: 5,
    xp: 0,
    languageProgress: {
      'Widgets': 0, 
      'State': 0, 
      'Layout': 0, 
      'Basics': 0,
    },
    completedLessons: [],
  );

  static User get userData => _currentUser;

  //загрузка пользователя из бд
  static Future<void> loadUserFromDatabase(String userId) async {
    try {
      final profile = await SupabaseService().getUserProfile(userId);
      
      if (profile != null) {
        _currentUser = User(
          name: profile['username'] ?? 'Пользователь',
          email: profile['email'] ?? '',
          streak: profile['streak'] ?? 0,
          lingots: profile['lingots'] ?? 0,
          hearts: profile['hearts'] ?? 5,
          xp: profile['xp'] ?? 0,
          languageProgress: Map<String, int>.from(profile['language_progress'] ?? {
            'Widgets': 0, 
            'State': 0, 
            'Layout': 0, 
            'Basics': 0,
          }),
          completedLessons: List<String>.from(profile['completed_lessons'] ?? []),
        );
        
        await _saveToLocalStorage(userId);
      }
    } catch (e) {
      print('Error loading user from database: $e');
      await _loadFromLocalStorage(userId);
    }
  }

  //сохранение пользователя в бд
  static Future<void> saveUserToDatabase(String userId) async {
    try {
      await SupabaseService().saveUserProgress(
        userId: userId,
        xp: _currentUser.xp,
        lingots: _currentUser.lingots,
        streak: _currentUser.streak,
        hearts: _currentUser.hearts,
        languageProgress: _currentUser.languageProgress,
        completedLessons: _currentUser.completedLessons,
      );
      
      await _saveToLocalStorage(userId);
    } catch (e) {
      print('Error saving user to database: $e');
    }
  }

  static Future<void> _saveToLocalStorage(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      await prefs.setString('user_data', json.encode({
        'name': _currentUser.name,
        'email': _currentUser.email,
        'streak': _currentUser.streak,
        'lingots': _currentUser.lingots,
        'hearts': _currentUser.hearts,
        'xp': _currentUser.xp,
        'languageProgress': _currentUser.languageProgress,
        'completedLessons': _currentUser.completedLessons,
      }));
    } catch (e) {
      print('Error saving to local storage: $e');
    }
  }

  static Future<void> _loadFromLocalStorage(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      
      if (userDataString != null) {
        final userData = json.decode(userDataString);
        _currentUser = User(
          name: userData['name'] ?? 'Пользователь',
          email: userData['email'] ?? '',
          streak: userData['streak'] ?? 0,
          lingots: userData['lingots'] ?? 0,
          hearts: userData['hearts'] ?? 5,
          xp: userData['xp'] ?? 0,
          languageProgress: Map<String, int>.from(userData['languageProgress'] ?? {
            'Widgets': 0, 
            'State': 0, 
            'Layout': 0, 
            'Basics': 0,
          }),
          completedLessons: List<String>.from(userData['completedLessons'] ?? []),
        );
      }
    } catch (e) {
      print('Error loading from local storage: $e');
    }
  }

  //установка пользователя после авторизации
  static Future<void> setUser(String userId) async {
    await loadUserFromDatabase(userId);
  }

  //получение текущего пользователя
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  //система рейтинга
  static Map<String, dynamic> get userRank {
    final int xp = _currentUser.xp;
    
    if (xp >= 2000) return {'rank': 'Flutter Мастер', 'level': 5, 'color': 0xFFFFD700};
    if (xp >= 1500) return {'rank': 'Flutter Эксперт', 'level': 4, 'color': 0xFFFF6B6B};
    if (xp >= 1000) return {'rank': 'Flutter Разработчик', 'level': 3, 'color': 0xFF4ECDC4};
    if (xp >= 500) return {'rank': 'Flutter Ученик', 'level': 2, 'color': 0xFF45B7D1};
    return {'rank': 'Flutter Новичок', 'level': 1, 'color': 0xFF96CEB4};
  }

  //завершение урока с сохранением в бд
  static Future<void> completeLesson(String userId, String lessonId, int xpReward, int correctAnswers, int totalQuestions) async {
    try {
      final double successRate = (correctAnswers / totalQuestions) * 100;
      final int bonusXp = successRate == 100 ? (xpReward * 0.2).round() : 0;
      final int totalXp = xpReward + bonusXp;
      
      //обновление статистики
      _currentUser.xp += totalXp;
      _currentUser.lingots += 5 + (bonusXp > 0 ? 3 : 0);
      _currentUser.streak++;
      
      //добавление урока в завершенные если его там нет
      if (!_currentUser.completedLessons.contains(lessonId)) {
        _currentUser.completedLessons.add(lessonId);
      }
      
      //обновление прогресса по категории
      _updateCategoryProgress(lessonId, successRate);
      
      //сохранение изменений в бд
      await saveUserToDatabase(userId);
      
      print('Урок завершен! Заработано: $totalXp XP, Lingots: ${5 + (bonusXp > 0 ? 3 : 0)}, Streak: ${_currentUser.streak}');
    } catch (e) {
      print('Error completing lesson: $e');
      rethrow;
    }
  }

  static void _updateCategoryProgress(String lessonId, double successRate) {
    try {
      final lesson = _allLessons.firstWhere((l) => l.id == lessonId);
      final String category = lesson.category;
      
      final progressIncrement = (successRate / 20).round();
      _currentUser.languageProgress.update(
        category, 
        (value) => (value + progressIncrement).clamp(0, 100),
        ifAbsent: () => progressIncrement.clamp(0, 100)
      );
    } catch (e) {
      print('Error updating category progress: $e');
    }
  }

  //обновление жизней
  static Future<void> updateHearts(String userId, int newHearts) async {
    _currentUser.hearts = newHearts.clamp(0, 5);
    await saveUserToDatabase(userId);
  }

  //обновление streak
  static Future<void> updateStreak(String userId, int newStreak) async {
    _currentUser.streak = newStreak;
    await saveUserToDatabase(userId);
  }

  //добавление XP
  static Future<void> addXp(String userId, int xpToAdd) async {
    _currentUser.xp += xpToAdd;
    await saveUserToDatabase(userId);
  }

  //добавление lingots
  static Future<void> addLingots(String userId, int lingotsToAdd) async {
    _currentUser.lingots += lingotsToAdd;
    await saveUserToDatabase(userId);
  }

  //получение статистики пользователя
  static Map<String, dynamic> getUserStats() {
    final totalLessons = _allLessons.length;
    final completedLessons = _currentUser.completedLessons.length;
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
    if (_currentUser.languageProgress.isEmpty) return 0;
    final sum = _currentUser.languageProgress.values.reduce((a, b) => a + b);
    return (sum / _currentUser.languageProgress.length).round();
  }

  static int _calculateNextRankXp() {
    final int currentXp = _currentUser.xp;
    if (currentXp < 500) return 500;
    if (currentXp < 1000) return 1000;
    if (currentXp < 1500) return 1500;
    if (currentXp < 2000) return 2000;
    return 0;
  }

  //загрузка уроков из json
  static Future<List<Lesson>> loadLessons() async {
    if (_allLessons.isEmpty) {
      await _loadLessonsFromJson();
    }
    return _allLessons;
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

  static List<Lesson> _allLessons = [];

  //загрузка уроков из json
  static Future<void> _loadLessonsFromJson() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/lessons.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _allLessons = (jsonData['lessons'] as List)
          .map((lessonJson) => Lesson.fromJson(lessonJson))
          .toList();
      
      print('Loaded ${_allLessons.length} lessons from JSON');
    } catch (e) {
      print('Error loading lessons from JSON: $e');
      _allLessons = _createFallbackLessons();
    }
  }

  static List<Lesson> _createFallbackLessons() {
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