class Question {
  final String type;
  final String question;
  final String correctAnswer;
  final List<String> options;
  final String hint;

  Question({
    required this.type,
    required this.question,
    required this.correctAnswer,
    required this.options,
    required this.hint,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      type: json['type'],
      question: json['question'],
      correctAnswer: json['correctAnswer'],
      options: List<String>.from(json['options']),
      hint: json['hint'],
    );
  }
}