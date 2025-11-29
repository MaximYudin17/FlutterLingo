class User {
  //данные пользователя
  String name;                    //имя пользователя
  String email;                   //email
  int streak;                     //дней подряд 
  int lingots;                    //игровая валюта
  int hearts;                     //жизни/попытки
  int xp;                         //опыт
  Map<String, int> languageProgress; //прогресс по темам
  List<String> completedLessons;  //завершенные уроки

  //конструктор - создание объекта пользователя
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

  
  int get level => (xp / 100).floor();
}