import 'package:flutter/material.dart';
import '../models/lesson_model.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;      // Данные урока
  final bool isCompleted;  // Завершен ли урок
  final VoidCallback onTap;// Обработчик нажатия

  const LessonCard({
    super.key,
    required this.lesson,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        // Иконка урока
        leading: Text(lesson.icon, style: const TextStyle(fontSize: 24)),
        
        // Название урока
        title: Text(
          lesson.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: lesson.isLocked ? Colors.grey : Colors.black, // Серый если заблокирован
          ),
        ),
        
        // Описание и детали
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lesson.description), // Описание урока
            const SizedBox(height: 4),
            Text(
              '${lesson.questions.length} вопросов • ${lesson.xpReward} XP', // Количество вопросов и награда
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        
        // Иконка статуса
        trailing: lesson.isLocked
            ? const Icon(Icons.lock, color: Colors.grey) // Замок для заблокированных
            : Icon(
                isCompleted ? Icons.check_circle : Icons.play_arrow, // Галочка или стрелка
                color: isCompleted ? Colors.green : const Color(0xFF2196F3),
              ),
        
        // Обработчик нажатия (отключен для заблокированных)
        onTap: lesson.isLocked ? null : onTap,
      ),
    );
  }
}