import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/advanced_widgets.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'achievement_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const AchievementScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          // Floating Bottom Navigation Bar
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: FloatingBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                FloatingNavItem(icon: Icons.home, label: 'Home'),
                FloatingNavItem(icon: Icons.history, label: 'History'),
                FloatingNavItem(icon: Icons.emoji_events, label: 'Achievements'),
                FloatingNavItem(icon: Icons.person, label: 'Profile'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
