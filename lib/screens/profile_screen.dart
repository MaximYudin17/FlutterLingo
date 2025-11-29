import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 
import '../models/user_model.dart';
import '../services/data_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isRefreshing = false;

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });
    
    final userId = await DataService.getCurrentUserId();
    if (userId != null) {
      await DataService.loadUserFromDatabase(userId);
    }
    
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = DataService.userData;
    final rank = DataService.userRank;
    final stats = DataService.getUserStats();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Профиль'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Обновить данные',
          ),
        ],
      ),
      body: _isRefreshing
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Карточка профиля с рейтингом
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Аватар ранга
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Color(rank['color']),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(rank['color']).withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${rank['level']}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.email,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Chip(
                            label: Text(
                              rank['rank'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Color(rank['color']),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${user.xp} XP',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                         
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Выход'),
                                  content: const Text('Вы уверены, что хотите выйти?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Отмена'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        context.go('/');
                                      },
                                      child: const Text('Выйти'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Выйти'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Статистика
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Статистика',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(user.streak.toString(), 'Дней', Icons.local_fire_department, Colors.orange),
                              _buildStatItem(user.xp.toString(), 'XP', Icons.star, Colors.amber),
                              _buildStatItem(user.lingots.toString(), 'Lingots', Icons.diamond, Colors.purple),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(stats['completedLessons'].toString(), 'Уроков', Icons.check_circle, Colors.green),
                              _buildStatItem('${stats['completionRate']}%', 'Прогресс', Icons.trending_up, Colors.blue),
                              _buildStatItem('${stats['averageProgress']}%', 'Средний', Icons.bar_chart, Colors.cyan),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Следующий уровень: ${stats['nextRankXp']} XP',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Прогресс по категориям
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Прогресс по темам',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...user.languageProgress.entries.map((entry) => 
                            _buildProgressItem(entry.key, entry.value)
                          ).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProgressItem(String category, int progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _capitalize(category),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text('$progress%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey[200],
            color: _getCategoryColor(category),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'widgets': return Colors.blue;
      case 'state': return Colors.green;
      case 'layout': return Colors.orange;
      case 'basics': return Colors.purple;
      default: return Colors.grey;
    }
  }
}