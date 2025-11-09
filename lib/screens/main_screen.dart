import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главный экран'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Главный экран',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push('/second'),
              child: const Text('Перейти на второй экран'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/third'),
              child: const Text('Перейти на третий экран'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/auth'),
              child: const Text('Авторизация'),
            ),
          ],
        ),
      ),
    );
  }
}