import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/learning_screen.dart';

void main() {
  runApp(const MyApp()); // Запуск приложения
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterLingo',
      theme: ThemeData(
        primaryColor: const Color(0xFF2196F3),     // Основной синий цвет
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Фон приложения
      ),
      home: const MainApp(), // Главный виджет
      debugShowCheckedModeBanner: false, // Скрыть баннер debug
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0; // Текущая выбранная вкладка

  // Список экранов приложения
  final List<Widget> _screens = [
    const HomeScreen(),      // Главная страница
    const LearningScreen(),  // Все уроки
    const ProfileScreen(),   // Профиль пользователя
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Показываем текущий экран
      
      // Нижняя навигационная панель
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Активная вкладка
        onTap: (index) => setState(() => _currentIndex = index), // Смена экрана
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Уроки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
        selectedItemColor: const Color(0xFF2196F3), // Цвет активной вкладки
        unselectedItemColor: Colors.grey,           // Цвет неактивных вкладок
      ),
    );
  }
}