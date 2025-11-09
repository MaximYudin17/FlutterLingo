import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;
  String _errorMessage = '';

  // Тестовые учетные данные
  final Map<String, String> _testUsers = {
    'admin@flutter.com': 'admin123',
    'user@flutter.com': 'user123',
    'test@test.com': 'test123',
  };

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Имитация загрузки
    await Future.delayed(const Duration(seconds: 1));

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isLogin) {
      // Проверка логина
      if (_testUsers[email] == password) {
        // Успешный вход
        setState(() {
          _isLoading = false;
        });
        context.go('/home');
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Неверный email или пароль';
        });
      }
    } else {
      // Регистрация (просто добавляем нового пользователя)
      if (!_testUsers.containsKey(email)) {
        _testUsers[email] = password;
        setState(() {
          _isLoading = false;
        });
        context.go('/home');
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Пользователь с таким email уже существует';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Заголовок
                    Text(
                      _isLogin ? 'Вход' : 'Регистрация',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin 
                          ? 'Войдите в свой аккаунт' 
                          : 'Создайте новый аккаунт',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    
                    // Тестовые данные
                    if (_isLogin) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Тестовые данные:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('admin@flutter.com / admin123'),
                            Text('user@flutter.com / user123'),
                            Text('test@test.com / test123'),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 16),

                    // Сообщение об ошибке
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    if (_errorMessage.isNotEmpty) const SizedBox(height: 16),

                    // Поле email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите email';
                        }
                        if (!value.contains('@')) {
                          return 'Введите корректный email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Поле пароля
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введите пароль';
                        }
                        if (value.length < 6) {
                          return 'Пароль должен быть не менее 6 символов';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Кнопка входа/регистрации
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _isLogin ? 'Войти' : 'Зарегистрироваться',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Переключение между входом и регистрацией
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = '';
                        });
                      },
                      child: Text(
                        _isLogin
                            ? 'Нет аккаунта? Зарегистрируйтесь'
                            : 'Уже есть аккаунт? Войдите',
                        style: const TextStyle(color: Color(0xFF2196F3)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}