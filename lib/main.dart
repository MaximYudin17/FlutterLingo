import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_screen.dart';
import 'screens/reg_screen.dart';
import 'screens/home_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/lesson_screen.dart';
import 'services/data_services.dart';
import 'services/supabase_service.dart';
import 'models/lesson_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Supabase
  await Supabase.initialize(
    url: 'https://ukgpustuwjpcukcmuaha.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVrZ3B1c3R1d2pwY3VrY211YWhhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQyNjY2NjIsImV4cCI6MjA3OTg0MjY2Mn0.BEd30WgnckPdx7ptzQWRFtEJ9H808TyEWhBOO-czCcg',
  );
  
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/reg',
      builder: (context, state) => const RegScreen(),
    ),
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
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Ошибка')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Страница не найдена'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('На главную'),
          ),
        ],
      ),
    ),
  ),
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = await DataService.getCurrentUserId();
    if (userId != null) {
      await DataService.loadUserFromDatabase(userId);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'FlutterLingo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[700],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Загрузка...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'FlutterLingo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          centerTitle: false,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.indigo,
            textStyle: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 1,
          centerTitle: false,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            textStyle: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ),
      themeMode: ThemeMode.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}