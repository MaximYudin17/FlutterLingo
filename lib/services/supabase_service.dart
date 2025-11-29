import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  //регистрация пользователя
  Future<Map<String, dynamic>> signUp(String email, String password, String username) async {
    try {
      //проверка на email
      final emailCheck = await supabase
          .from('profiles')
          .select()
          .eq('email', email);

      if (emailCheck.isNotEmpty) {
        throw Exception('Пользователь с таким email уже существует');
      }

      //проверка на username
      final usernameCheck = await supabase
          .from('profiles')
          .select()
          .eq('username', username);

      if (usernameCheck.isNotEmpty) {
        throw Exception('Имя пользователя уже занято');
      }

      //добавляем нового пользователя
      final response = await supabase
          .from('profiles')
          .insert({
            'username': username,
            'email': email,
            'password': password,
            'xp': 0,
            'lingots': 0,
            'streak': 0,
            'hearts': 5,
            'language_progress': {
              'Widgets': 0,
              'State': 0,
              'Layout': 0,
              'Basics': 0,
            },
            'completed_lessons': [],
            'created_at': DateTime.now().toIso8601String(),
          })
          .select();

      if (response.isEmpty) {
        throw Exception('Не удалось создать профиль');
      }

      final user = response[0];

      return {
        'user': {
          'id': user['id'],
          'email': email,
          'username': username,
        }
      };
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  //авторизация
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('email', email)
          .eq('password', password);

      if (response.isEmpty) {
        throw Exception('Неверный email или пароль');
      }

      final user = response[0];

      return {
        'user': {
          'id': user['id'],
          'email': user['email'],
          'username': user['username'],
        }
      };
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  //получение профиля пользователя
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId);

      if (response.isNotEmpty) {
        return response[0];
      }
      return null;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  //сохранение прогресса пользователя
  Future<void> saveUserProgress({
    required String userId,
    required int xp,
    required int lingots,
    required int streak,
    required int hearts,
    required Map<String, dynamic> languageProgress,
    required List<dynamic> completedLessons,
  }) async {
    try {
      await supabase
          .from('profiles')
          .update({
            'xp': xp,
            'lingots': lingots,
            'streak': streak,
            'hearts': hearts,
            'language_progress': languageProgress,
            'completed_lessons': completedLessons,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      print('Save progress error: $e');
      rethrow;
    }
  }

  
  

  String? get currentUserId => null;

  bool get isSignedIn => currentUserId != null;

  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('username', username);
      return response.isEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isEmailAvailable(String email) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('email', email);
      return response.isEmpty;
    } catch (e) {
      return false;
    }
  }
}