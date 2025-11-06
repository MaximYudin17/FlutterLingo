import 'package:flutter/material.dart';
import '../models/lesson_model.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final bool isCompleted;
  final VoidCallback onTap;

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
        leading: Text(lesson.icon, style: const TextStyle(fontSize: 24)),
        title: Text(
          lesson.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: lesson.isLocked ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lesson.description),
            const SizedBox(height: 4),
            Text(
              '${lesson.questions.length} вопросов • ${lesson.xpReward} XP',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: lesson.isLocked
            ? const Icon(Icons.lock, color: Colors.grey)
            : Icon(
                isCompleted ? Icons.check_circle : Icons.play_arrow,
                color: isCompleted ? Colors.green : const Color(0xFF2196F3),
              ),
        onTap: lesson.isLocked ? null : onTap,
      ),
    );
  }
}