class User {
  String name;
  String email;
  int streak;
  int lingots;
  int hearts;
  int xp;
  Map<String, int> languageProgress;
  List<String> completedLessons;

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