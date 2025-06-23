import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/achievement_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
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
          ],
        ),
      ),
    );
  }
}
