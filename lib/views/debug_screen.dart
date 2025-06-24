import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/achievement_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/drink_type_viewmodel.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import '../utils/theme_manager.dart';
import '../widgets/theme_widgets.dart';
import '../widgets/gradient_background.dart';
import 'analytics_screen.dart';
import 'drink_type_management_screen.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return GradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,            appBar: AppBar(
              title: const Text('Debug Panel'),
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              scrolledUnderElevation: 0,
              actions: [
                // Animated theme toggle button in app bar
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: AnimatedThemeToggle(
                    size: 20,
                    onToggle: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            themeManager.isDarkMode 
                                ? 'Switched to Light Mode' 
                                : 'Switched to Dark Mode'
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: themeManager.isDarkMode 
                              ? AppColors.surfaceDark 
                              : AppColors.surface,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Added extra bottom padding
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  // Theme Controls Section
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeManager.isDarkMode ? AppColors.surfaceDark : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (themeManager.isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.palette,
                              color: themeManager.isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Theme Controls',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeManager.isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Current Theme: ',
                              style: TextStyle(
                                color: themeManager.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: themeManager.isDarkMode ? AppColors.primary : AppColors.accent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                themeManager.isDarkMode ? 'Dark Mode' : 'Light Mode',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await themeManager.toggleTheme();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Theme switched to ${themeManager.isDarkMode ? 'Dark' : 'Light'} Mode'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                icon: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    themeManager.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                    key: ValueKey(themeManager.isDarkMode),
                                  ),
                                ),
                                label: Text(themeManager.isDarkMode ? 'Switch to Light' : 'Switch to Dark'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: themeManager.isDarkMode ? AppColors.accent : AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const ThemeToggleSwitch(scale: 1.2),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeManager.isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Feature buttons row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AnalyticsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.analytics, size: 16),
                          label: const Text('Analytics'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // Initialize drink type service
                            final drinkTypeVM = Provider.of<DrinkTypeViewModel>(context, listen: false);
                            await drinkTypeVM.initialize();
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DrinkTypeManagementScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.local_drink, size: 16),
                          label: const Text('Drink Types'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Achievement System Debug',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeManager.isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Achievement status
                  Consumer<AchievementViewModel>(
                    builder: (context, achievementVM, child) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: Card(
                          color: themeManager.isDarkMode ? AppColors.surfaceDark : AppColors.surface,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Achievements: ${achievementVM.totalAchievements}',
                                  style: TextStyle(
                                    color: themeManager.isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Unlocked: ${achievementVM.totalUnlocked}',
                                  style: TextStyle(
                                    color: themeManager.isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Completion: ${(achievementVM.completionPercentage * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: themeManager.isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Loading: ${achievementVM.isLoading}',
                                  style: TextStyle(
                                    color: themeManager.isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
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
                  Consumer<AchievementViewModel>(
                    builder: (context, achievementVM, child) {
                      if (achievementVM.achievements.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No achievements found',
                              style: TextStyle(
                                color: themeManager.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: achievementVM.achievements.length,
                          itemBuilder: (context, index) {
                            final achievement = achievementVM.achievements[index];
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Card(
                                color: themeManager.isDarkMode ? AppColors.surfaceDark : AppColors.surface,
                                child: ListTile(
                                  leading: Icon(
                                    achievement.icon,
                                    color: achievement.color,
                                  ),
                                  title: Text(
                                    achievement.title,
                                    style: TextStyle(
                                      color: themeManager.isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    achievement.description,
                                    style: TextStyle(
                                      color: themeManager.isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    ),
                                  ),
                                  trailing: Icon(
                                    achievement.isUnlocked ? Icons.check_circle : Icons.lock,
                                    color: achievement.isUnlocked ? Colors.green : Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),                      );
                    },
                  ),
                  const SizedBox(height: 16), // Extra space at bottom
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
