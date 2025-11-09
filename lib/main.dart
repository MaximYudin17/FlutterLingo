import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/main_screen.dart';
import 'screens/second_screen.dart';
import 'screens/third_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/lesson_screen.dart';
import 'services/data_services.dart';
import 'models/lesson_model.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: [
   
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/second',
      builder: (context, state) => const SecondScreen(),
    ),
    GoRoute(
      path: '/third',
      builder: (context, state) => const ThirdScreen(),
    ),
    
    // Авторизация
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    
    // Основное приложение FlutterLingo
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/learning',
      builder: (context, state) => const LearningScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/lesson/:lessonId',
      builder: (context, state) {
        final lessonId = state.pathParameters['lessonId']!;
        return FutureBuilder<Lesson?>(
          future: DataService.getLessonById(lessonId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (snapshot.hasError || snapshot.data == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Ошибка')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Урок не найден'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go('/learning'),
                        child: const Text('Вернуться к урокам'),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return LessonScreen(lesson: snapshot.data!);
          },
        );
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FlutterLingo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}