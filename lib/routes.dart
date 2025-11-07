import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/lesson_screen.dart';
import 'models/lesson_model.dart';

class AppRoutes {
  static const String home = '/';
  static const String learning = '/learning';
  static const String profile = '/profile';
  static const String lesson = '/lesson';
}

final GoRouter router = GoRouter(
  routes: [
    // Главный экран
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    
    // Все уроки
    GoRoute(
      path: AppRoutes.learning,
      builder: (context, state) => const LearningScreen(),
    ),
    
    // Профиль
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    
    // Экран урока (с параметром)
    GoRoute(
      path: '${AppRoutes.lesson}/:lessonId',
      builder: (context, state) {
        final lessonId = state.pathParameters['lessonId']!;
        // Здесь нужно получить урок по ID из вашего DataService
        // Пока используем заглушку
        final lesson = Lesson(
          id: lessonId,
          title: 'Урок $lessonId',
          icon: '📚',
          category: 'General',
          level: 1,
          isLocked: false,
          xpReward: 10,
          description: 'Описание урока',
          questions: [],
        );
        return LessonScreen(lesson: lesson);
      },
    ),
  ],
);