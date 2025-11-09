import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/user_model.dart';
import '../models/lesson_model.dart';
import '../services/data_services.dart';
import '../widgets/lesson_card.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = DataService.userData;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Все уроки'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: FutureBuilder<List<Lesson>>(
        future: DataService.loadLessons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final lessons = snapshot.data ?? [];
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...lessons.map((lesson) {
                final isCompleted = user.completedLessons.contains(lesson.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LessonCard(
                    lesson: lesson,
                    isCompleted: isCompleted,
                    onTap: () {
                      if (!lesson.isLocked) {
                        context.push('/lesson/${lesson.id}');
                      }
                    },
                  ),
                );
              }),
            ],
          );
        },
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/learning');
              break;
            case 2:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Уроки'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}