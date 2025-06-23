import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/achievement_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import '../utils/theme_manager.dart';
import '../widgets/theme_widgets.dart';
import 'analytics_screen.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Panel'),
        backgroundColor: AppColors.waterBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Achievement System Debug',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Achievement status
            Consumer<AchievementViewModel>(
              builder: (context, achievementVM, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Achievements: ${achievementVM.totalAchievements}'),
                        Text('Unlocked: ${achievementVM.totalUnlocked}'),
                        Text('Completion: ${(achievementVM.completionPercentage * 100).toStringAsFixed(1)}%'),
                        Text('Loading: ${achievementVM.isLoading}'),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Debug buttons
            ElevatedButton(
              onPressed: () async {
                final achievementVM = Provider.of<AchievementViewModel>(context, listen: false);
                await achievementVM.refreshAchievements();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Achievements refreshed')),
                );
              },
              child: const Text('Refresh Achievements'),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: () async {
                final db = DatabaseService();
                await db.initializeDefaultAchievements();
                final achievementVM = Provider.of<AchievementViewModel>(context, listen: false);
                await achievementVM.refreshAchievements();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Default achievements initialized')),
                );
              },
              child: const Text('Initialize Default Achievements'),
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: () async {
                final homeVM = Provider.of<HomeViewModel>(context, listen: false);
                final achievementVM = Provider.of<AchievementViewModel>(context, listen: false);
                
                // Add some water intake to trigger achievements
                await homeVM.addWaterIntake(250);
                  // Check achievements
                await achievementVM.checkAchievements(
                  currentStreak: 1,
                  totalLifetimeIntake: 1000, // Placeholder value
                  dailyGoalsReached: 0,
                  todayIntakes: homeVM.todayIntakes,
                  todayTotal: homeVM.todayTotal,
                  dailyGoal: homeVM.userProfile?.dailyGoal ?? 2000,
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added water and checked achievements')),
                );
              },
              child: const Text('Add Water & Check Achievements'),
            ),
            
            const SizedBox(height: 8),
            
            // Test Analytics Button
            ElevatedButton(
              onPressed: () async {
                final homeVM = Provider.of<HomeViewModel>(context, listen: false);
                
                // Add multiple water intake entries to generate analytics data
                final amounts = [250, 300, 200, 400, 250, 350, 300];
                for (int i = 0; i < amounts.length; i++) {
                  await homeVM.addWaterIntake(amounts[i]);
                  // Add a small delay to create different timestamps
                  await Future.delayed(const Duration(milliseconds: 100));
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added ${amounts.length} water intake entries for analytics testing')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Sample Data for Analytics'),
            ),
            
            const SizedBox(height: 16),
            
            // Analytics Screen Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnalyticsScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Open Analytics Screen'),
            ),
            
            const SizedBox(height: 16),
            
            // Achievement list
            Expanded(
              child: Consumer<AchievementViewModel>(
                builder: (context, achievementVM, child) {
                  if (achievementVM.achievements.isEmpty) {
                    return const Center(
                      child: Text('No achievements found'),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: achievementVM.achievements.length,
                    itemBuilder: (context, index) {
                      final achievement = achievementVM.achievements[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            achievement.icon,
                            color: achievement.color,
                          ),
                          title: Text(achievement.title),
                          subtitle: Text(achievement.description),
                          trailing: Icon(
                            achievement.isUnlocked ? Icons.check_circle : Icons.lock,
                            color: achievement.isUnlocked ? Colors.green : Colors.grey,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Theme Testing Section
            const Text(
              'Theme Testing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Theme Controls'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final themeManager = Provider.of<ThemeManager>(context, listen: false);
                              await themeManager.setTheme(ThemeMode.light);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Switched to Light Mode')),
                              );
                            },
                            icon: const Icon(Icons.light_mode),
                            label: const Text('Light'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[300],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final themeManager = Provider.of<ThemeManager>(context, listen: false);
                              await themeManager.setTheme(ThemeMode.dark);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Switched to Dark Mode')),
                              );
                            },
                            icon: const Icon(Icons.dark_mode),
                            label: const Text('Dark'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Animated Toggle: '),
                        const AnimatedThemeToggle(size: 20),
                        const SizedBox(width: 16),
                        const Text('Switch: '),
                        Consumer<ThemeManager>(
                          builder: (context, themeManager, child) {
                            return Switch.adaptive(
                              value: themeManager.isDarkMode,
                              onChanged: (_) => themeManager.toggleTheme(),
                              activeColor: AppColors.primary,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
