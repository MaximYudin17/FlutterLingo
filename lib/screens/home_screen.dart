import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import '../models/user_model.dart';
import '../models/lesson_model.dart';
import '../services/data_services.dart';
import '../widgets/lesson_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = DataService.userData;
    final progress = user.languageProgress['Widgets'] ?? 0;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('FlutterLingo'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.diamond, color: Color(0xFF2196F3), size: 16),
                const SizedBox(width: 4),
                Text('${user.lingots}'),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Lesson>>(
        future: DataService.loadLessons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final lessons = snapshot.data ?? [];
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildWelcomeSection(user),
              const SizedBox(height: 20),
              _buildProgressSection(progress),
              const SizedBox(height: 20),
              _buildStatsSection(user),
              const SizedBox(height: 20),
              _buildLessonsSection(lessons, user, context),
            ],
          );
        },
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/learning');
              break;
            case 2:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Уроки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildWelcomeSection(User user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
              child: const Icon(Icons.code, color: Color(0xFF2196F3)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Привет, ${user.name}!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.streak} дней подряд изучаете Flutter',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(int progress) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Общий прогресс по Flutter',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[200],
              color: const Color(0xFF2196F3),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$progress% завершено',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${DataService.userRank['rank']}',
                  style: TextStyle(
                    color: Color(DataService.userRank['color']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(User user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ваша статистика',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(user.xp.toString(), 'XP', Icons.star, Colors.amber),
                _buildStatItem(user.lingots.toString(), 'Lingots', Icons.diamond, Colors.purple),
                _buildStatItem(user.streak.toString(), 'Streak', Icons.local_fire_department, Colors.orange),
                _buildStatItem(user.hearts.toString(), 'Hearts', Icons.favorite, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLessonsSection(List<Lesson> lessons, User user, BuildContext context) {
    final availableLessons = lessons.where((lesson) => !lesson.isLocked).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Рекомендуемые уроки',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...availableLessons.map((lesson) {
          final isCompleted = user.completedLessons.contains(lesson.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: LessonCard(
              lesson: lesson,
              isCompleted: isCompleted,
              onTap: () {
                if (!lesson.isLocked) {
                  context.push('/lesson/${lesson.id}');
                }
              },
            ),
          );
        }),
        if (availableLessons.isEmpty) ...[
          const Center(
            child: Text(
              'Все уроки завершены! 🎉',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ],
    );
  }
}