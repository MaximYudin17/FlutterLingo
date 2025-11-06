import 'question_model.dart'; 

class Lesson {
  final String id;           // Уникальный ID урока
  final String title;        // Название урока
  final String icon;         // Иконка 
  final String category;     // Категория 
  final int level;           // Уровень сложности
  final bool isLocked;       // Доступен ли урок
  final int xpReward;        // Награда за прохождение
  final String description;  // Описание урока
  final List<Question> questions; // Список вопросов

  // Конструктор - создает объект урока
  Lesson({
    required this.id,
    required this.title,
    required this.icon,
    required this.category,
    required this.level,
    required this.isLocked,
    required this.xpReward,
    required this.description,
    required this.questions,
  });

  // Фабричный конструктор - создает урок из JSON данных
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      icon: json['icon'],
      category: json['category'],
      level: json['level'],
      isLocked: json['isLocked'],
      xpReward: json['xpReward'],
      description: json['description'],
      // Преобразует JSON массив вопросов в список объектов Question
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
    );
  }
}