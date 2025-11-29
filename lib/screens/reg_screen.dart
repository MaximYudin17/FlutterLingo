import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/data_services.dart';
import '../services/supabase_service.dart';

class RegScreen extends StatelessWidget {
  const RegScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Создание аккаунта',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _RegForm(),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Уже есть аккаунт? Войдите'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegForm extends StatefulWidget {
  const _RegForm();

  @override
  State<_RegForm> createState() => _RegFormState();
}

class _RegFormState extends State<_RegForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _register() async {
    if (_usernameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Заполните все поля';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Пароли не совпадают';
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Пароль должен быть не менее 6 символов';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await SupabaseService().signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _usernameController.text.trim(),
      );

      if (response['user'] != null) {
        final String userId = response['user']['id'];
        await DataService.setUser(userId);
        
        if (mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: 'Имя пользователя',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Пароль',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Подтвердите пароль',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock_outline),
          ),
        ),
        
        if (_errorMessage.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 20),
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
        ],
        
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Зарегистрироваться'),
                ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}