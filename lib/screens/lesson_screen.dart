import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/lesson_model.dart';
import '../models/question_model.dart';
import '../services/data_services.dart';
import '../services/supabase_service.dart';

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
  int earnedXp = 0;
  int earnedLingots = 0;

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

  void _calculateRewards() {
    final int baseXp = widget.lesson.xpReward;
    final int totalQuestions = widget.lesson.questions.length;
    final double successRate = (correctAnswers / totalQuestions) * 100;
    
    //расчет опыта
    final double correctBonus = (correctAnswers / totalQuestions) * (baseXp * 0.5);
    final int wrongAnswers = totalQuestions - correctAnswers;
    final double penalty = wrongAnswers * (baseXp * 0.1);
    
    earnedXp = (baseXp + correctBonus - penalty).round();
    earnedXp = earnedXp.clamp((baseXp * 0.1).round(), baseXp * 2);
    
    //расчет lingots
    if (successRate >= 80) {
      earnedLingots = 3;
    } else if (successRate >= 60) {
      earnedLingots = 1;
    } else {
      earnedLingots = 0;
    }
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
          //завершение урока - рассчет наград
          _calculateRewards();
          isCompleted = true;
          
          //сохранение прогресса в бд
          _saveProgressToDatabase();
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
        //урок завершен пропуском вопросов - рассчет наград
        _calculateRewards();
        isCompleted = true;
        
        //сохранение прогресса в бд
        _saveProgressToDatabase();
      }
    });
  }

  // Отдельный метод для сохранения прогресса в базу данных
void _saveProgressToDatabase() async {
  final userId = await DataService.getCurrentUserId();
  if (userId != null) {
    await DataService.completeLesson(
      userId,
      widget.lesson.id, 
      widget.lesson.xpReward, 
      correctAnswers, 
      widget.lesson.questions.length
    );
  }
}
  @override
  Widget build(BuildContext context) {
    final totalQuestions = widget.lesson.questions.length;
    final double progress = totalQuestions == 0 ? 0 : (currentQuestionIndex + 1) / totalQuestions;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          // Отображение текущего прогресса в реальном времени
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$correctAnswers/$totalQuestions',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Улучшенный прогресс-бар
            Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  color: const Color(0xFF2196F3),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Вопрос ${currentQuestionIndex + 1} из $totalQuestions',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
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
          // Статус вопроса
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Вопрос ${currentQuestionIndex + 1} из ${widget.lesson.questions.length}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF2196F3),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Текст вопроса
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                currentQuestion.question,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Варианты ответов
          Expanded(
            child: ListView(
              children: currentQuestion.options.map((option) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    elevation: 1,
                    child: ListTile(
                      title: Text(
                        option,
                        textAlign: TextAlign.center,
                      ),
                      onTap: () => setState(() => selectedAnswer = option),
                      tileColor: selectedAnswer == option 
                          ? const Color(0xFF2196F3).withOpacity(0.1)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: selectedAnswer == option 
                              ? const Color(0xFF2196F3)
                              : Colors.grey.shade300,
                          width: selectedAnswer == option ? 2 : 1,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Подсказка при ошибке
          if (showHint)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      currentQuestion.hint,
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          
          if (showHint) const SizedBox(height: 16),
          
          // Кнопки действий
          Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: skipQuestion,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    minimumSize: const Size(0, 50),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: const Text('Пропустить'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: selectedAnswer != null ? checkAnswer : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Проверить ответ'),
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
    
    final bool perfectScore = successRate == 100;
    final bool goodScore = successRate >= 80;
    final bool averageScore = successRate >= 60;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Иконка результата
          Icon(
            perfectScore ? Icons.celebration : 
            goodScore ? Icons.check_circle : 
            Icons.emoji_events,
            color: perfectScore ? Colors.amber : 
                  goodScore ? Colors.green : 
                  Colors.blue,
            size: 80,
          ),
          const SizedBox(height: 20),
          
          // Заголовок результата
          Text(
            perfectScore ? 'Идеальный результат! 🎯' :
            goodScore ? 'Отличная работа! 👍' :
            averageScore ? 'Хороший результат! 👏' :
            'Урок завершен!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Статистика
          Text(
            'Правильных ответов: $correctAnswers из ${widget.lesson.questions.length}',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'Успех: ${successRate.round()}%',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          // Награды
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: perfectScore ? Colors.amber[50] : 
                    goodScore ? Colors.green[50] : 
                    Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: perfectScore ? Colors.amber : 
                      goodScore ? Colors.green : 
                      Colors.blue,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRewardItem('+$earnedXp', 'XP', Icons.star, 
                        perfectScore ? Colors.amber : Colors.blue),
                    if (earnedLingots > 0)
                      _buildRewardItem('+$earnedLingots', 'Lingots', Icons.diamond, Colors.purple),
                  ],
                ),
                const SizedBox(height: 8),
                if (perfectScore)
                  Text(
                    '🎉 Идеальный результат! Максимальный бонус!',
                    style: TextStyle(
                      color: Colors.amber[700],
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (goodScore && !perfectScore)
                  Text(
                    '🌟 Отличный результат! Бонусные lingots!',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Детали расчета
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'База: ${widget.lesson.xpReward} XP + бонус за правильные ответы - штраф за ошибки',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Кнопка возврата
          ElevatedButton(
            onPressed: () => context.go('/learning'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Вернуться к урокам'),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}