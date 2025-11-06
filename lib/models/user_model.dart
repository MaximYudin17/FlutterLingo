class User {
  // Поля класса - данные пользователя
  String name;                    // Имя пользователя
  String email;                   // Email
  int streak;                     // Дней подряд (как в Duolingo)
  int lingots;                    // Игровая валюта
  int hearts;                     // Жизни/попытки
  int xp;                         // Опыт
  Map<String, int> languageProgress; // Прогресс по темам
  List<String> completedLessons;  // Завершенные уроки

  // Конструктор - создает объект пользователя
  User({
    required this.name,
    required this.email,
    required this.streak,
    required this.lingots,
    required this.hearts,
    required this.xp,
    required this.languageProgress,
    required this.completedLessons,
  });

  // Геттер уровня - вычисляется на основе опыта
  int get level => (xp / 100).floor();
}