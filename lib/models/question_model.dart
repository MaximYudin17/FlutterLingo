class Question {
  // Поля класса - данные вопроса
  final String type;           // Тип вопроса (multiple_choice и т.д.)
  final String question;       // Текст вопроса
  final String correctAnswer;  // Правильный ответ
  final List<String> options;  // Варианты ответов
  final String hint;           // Подсказка при ошибке

  // Конструктор - создает объект вопроса
  Question({
    required this.type,
    required this.question,
    required this.correctAnswer,
    required this.options,
    required this.hint,
  });

  // Фабричный конструктор - создает вопрос из JSON данных
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      type: json['type'],
      question: json['question'],
      correctAnswer: json['correctAnswer'],
      // Преобразует JSON массив в List<String>
      options: List<String>.from(json['options']),
      hint: json['hint'],
    );
  }
}