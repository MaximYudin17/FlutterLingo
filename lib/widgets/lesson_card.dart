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
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              lesson.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        
        title: Text(
          lesson.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: lesson.isLocked ? Colors.grey : Colors.black,
          ),
        ),
        
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lesson.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getLevelColor(lesson.level),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Ур. ${lesson.level}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${lesson.questions.length} вопр. • ${lesson.xpReward} XP',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        
        trailing: lesson.isLocked
            ? const Icon(Icons.lock, color: Colors.grey)
            : Badge(
                backgroundColor: isCompleted ? Colors.green : Colors.transparent,
                label: isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.play_arrow,
                  color: isCompleted ? Colors.green : const Color(0xFF2196F3),
                ),
              ),
        
        onTap: lesson.isLocked ? null : onTap,
      ),
    );
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1: return Colors.green;
      case 2: return Colors.orange;
      case 3: return Colors.red;
      default: return Colors.grey;
    }
  }
}