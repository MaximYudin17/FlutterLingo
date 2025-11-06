import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/lesson_model.dart';
import '../services/data_services.dart';
import '../widgets/lesson_card.dart';
import 'lesson_screen.dart';

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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonScreen(lesson: lesson),
                          ),
                        );
                      }
                    },
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}