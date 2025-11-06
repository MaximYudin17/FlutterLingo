import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../models/question_model.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson; // Урок для прохождения

  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int currentQuestionIndex = 0;     // Текущий вопрос
  String? selectedAnswer;           // Выбранный ответ
  bool showHint = false;            // Показывать подсказку
  bool isCompleted = false;         // Урок завершен

  // Текущий вопрос
  Question get currentQuestion => widget.lesson.questions[currentQuestionIndex];

  // Проверка ответа
  void checkAnswer() {
    if (selectedAnswer == currentQuestion.correctAnswer) {
      setState(() {
        // Следующий вопрос или завершение
        if (currentQuestionIndex < widget.lesson.questions.length - 1) {
          currentQuestionIndex++;
          selectedAnswer = null;
          showHint = false;
        } else {
          isCompleted = true; // Все вопросы пройдены
        }
      });
    } else {
      setState(() {
        showHint = true; // Показать подсказку при ошибке
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Прогресс-бар урока
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / widget.lesson.questions.length,
              color: const Color(0xFF2196F3),
            ),
            const SizedBox(height: 20),
            
            // Экран вопроса или завершения
            if (isCompleted)
              _buildCompletionScreen()
            else
              _buildQuestionScreen(),
          ],
        ),
      ),
    );
  }

  // Экран вопроса
  Widget _buildQuestionScreen() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Номер вопроса
          Text('Вопрос ${currentQuestionIndex + 1}/${widget.lesson.questions.length}'),
          const SizedBox(height: 16),
          
          // Текст вопроса
          Text(currentQuestion.question),
          const SizedBox(height: 24),
          
          // Варианты ответов
          ...currentQuestion.options.map((option) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildOptionButton(option),
          )),
          
          const Spacer(),
          
          // Подсказка при ошибке
          if (showHint)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(child: Text(currentQuestion.hint)),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Кнопка проверки
          ElevatedButton(
            onPressed: selectedAnswer != null ? checkAnswer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Проверить'),
          ),
        ],
      ),
    );
  }

  // Кнопка варианта ответа
  Widget _buildOptionButton(String option) {
    final isSelected = selectedAnswer == option;
    return OutlinedButton(
      onPressed: () => setState(() => selectedAnswer = option),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF2196F3).withOpacity(0.1) : null,
        side: BorderSide(color: isSelected ? const Color(0xFF2196F3) : Colors.grey),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Text(option, textAlign: TextAlign.center),
    );
  }

  // Экран завершения урока
  Widget _buildCompletionScreen() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 20),
          const Text('Урок завершен!'),
          const SizedBox(height: 16),
          Text('+${widget.lesson.xpReward} XP'), // Награда
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context), // Возврат
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              minimumSize: const Size(200, 50),
            ),
            child: const Text('Вернуться'),
          ),
        ],
      ),
    );
  }
}