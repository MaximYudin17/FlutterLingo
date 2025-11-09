import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/lesson_model.dart';
import '../models/question_model.dart';
import '../services/data_services.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool showHint = false;
  bool isCompleted = false;
  int correctAnswers = 0;

  Question get currentQuestion {
    if (widget.lesson.questions.isEmpty) {
      return Question(
        type: 'multiple_choice',
        question: 'Вопросов пока нет',
        correctAnswer: 'OK',
        options: ['OK'],
        hint: 'Этот урок в разработке',
      );
    }
    
    if (currentQuestionIndex >= widget.lesson.questions.length) {
      currentQuestionIndex = 0;
    }
    
    return widget.lesson.questions[currentQuestionIndex];
  }

  void checkAnswer() {
    if (widget.lesson.questions.isEmpty) {
      setState(() {
        isCompleted = true;
      });
      return;
    }

    if (selectedAnswer == currentQuestion.correctAnswer) {
      setState(() {
        correctAnswers++;
        showHint = false;
        
        if (currentQuestionIndex < widget.lesson.questions.length - 1) {
          currentQuestionIndex++;
          selectedAnswer = null;
        } else {
          isCompleted = true;
          DataService.completeLesson(
            widget.lesson.id, 
            widget.lesson.xpReward, 
            correctAnswers, 
            widget.lesson.questions.length
          );
        }
      });
    } else {
      setState(() {
        showHint = true;
      });
    }
  }

  void skipQuestion() {
    setState(() {
      if (currentQuestionIndex < widget.lesson.questions.length - 1) {
        currentQuestionIndex++;
        selectedAnswer = null;
        showHint = false;
      } else {
        isCompleted = true;
        DataService.completeLesson(
          widget.lesson.id, 
          (widget.lesson.xpReward * 0.7).round(), 
          correctAnswers, 
          widget.lesson.questions.length
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = widget.lesson.questions.length;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: totalQuestions == 0 ? 0 : (currentQuestionIndex + 1) / totalQuestions,
              backgroundColor: Colors.grey[200],
              color: const Color(0xFF2196F3),
            ),
            const SizedBox(height: 20),
            
            if (isCompleted)
              _buildCompletionScreen(context)
            else
              _buildQuestionScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionScreen() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Вопрос ${currentQuestionIndex + 1} из ${widget.lesson.questions.length}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                currentQuestion.question,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Expanded(
            child: ListView(
              children: currentQuestion.options.map((option) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      title: Text(option),
                      onTap: () => setState(() => selectedAnswer = option),
                      tileColor: selectedAnswer == option 
                          ? Colors.blue.withOpacity(0.1)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          if (showHint)
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(child: Text(currentQuestion.hint)),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: skipQuestion,
                  child: const Text('Пропустить'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: selectedAnswer != null ? checkAnswer : null,
                  child: const Text('Проверить'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(BuildContext context) {
    final successRate = widget.lesson.questions.isEmpty 
        ? 0 
        : (correctAnswers / widget.lesson.questions.length * 100);
        
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 20),
          const Text(
            'Урок завершен!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('Правильных ответов: $correctAnswers из ${widget.lesson.questions.length}'),
          Text('Успех: ${successRate.round()}%'),
          const SizedBox(height: 20),
          Text('+${widget.lesson.xpReward} XP', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => context.go('/learning'), // Возврат на экран уроков
            child: const Text('Вернуться к урокам'),
          ),
        ],
      ),
    );
  }
}