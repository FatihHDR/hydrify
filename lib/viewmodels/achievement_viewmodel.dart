import 'package:flutter/foundation.dart';
import '../models/achievement_model.dart';
import '../models/water_intake_model.dart';
import '../services/database_service.dart';

class AchievementViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Achievement> _achievements = [];
  List<Achievement> _recentlyUnlocked = [];
  bool _isLoading = false;

  // Getters
  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements => _achievements.where((a) => a.isUnlocked).toList();
  List<Achievement> get lockedAchievements => _achievements.where((a) => !a.isUnlocked).toList();
  List<Achievement> get recentlyUnlocked => _recentlyUnlocked;
  bool get isLoading => _isLoading;

  int get totalUnlocked => unlockedAchievements.length;
  int get totalAchievements => _achievements.length;
  double get completionPercentage => totalAchievements > 0 ? totalUnlocked / totalAchievements : 0.0;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadAchievements();
    } catch (e) {
      debugPrint('Error initializing AchievementViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAchievements() async {
    final storedAchievements = await _databaseService.getAchievements();
    
    if (storedAchievements.isEmpty) {
      // First time setup - initialize with default achievements
      _achievements = Achievement.getDefaultAchievements();
      for (final achievement in _achievements) {
        await _databaseService.insertAchievement(achievement);
      }
    } else {
      _achievements = storedAchievements;
    }
    
    notifyListeners();
  }

  Future<void> checkAchievements({
    required int currentStreak,
    required int totalLifetimeIntake,
    required int dailyGoalsReached,
    required List<WaterIntakeModel> todayIntakes,
    required int todayTotal,
    required int dailyGoal,
  }) async {
    final newlyUnlocked = <Achievement>[];

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      
      if (achievement.isUnlocked) continue;

      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.streak:
          shouldUnlock = currentStreak >= achievement.requiredValue;
          break;
          
        case AchievementType.totalIntake:
          shouldUnlock = totalLifetimeIntake >= achievement.requiredValue;
          break;
          
        case AchievementType.dailyGoal:
          shouldUnlock = dailyGoalsReached >= achievement.requiredValue;
          break;
          
        case AchievementType.earlyBird:
          final earlyMorningCount = await _getEarlyMorningDaysCount();
          shouldUnlock = earlyMorningCount >= achievement.requiredValue;
          break;
          
        case AchievementType.nightOwl:
          final lateNightCount = await _getLateNightDaysCount();
          shouldUnlock = lateNightCount >= achievement.requiredValue;
          break;
          
        case AchievementType.milestone:
          if (achievement.id == 'first_glass') {
            shouldUnlock = todayIntakes.isNotEmpty;
          } else if (achievement.id == 'perfectionist') {
            final percentage = dailyGoal > 0 ? (todayTotal / dailyGoal * 100) : 0;
            shouldUnlock = percentage >= achievement.requiredValue;
          }
          break;
          
        case AchievementType.consistency:
          // Add custom logic for consistency achievements
          break;
      }

      if (shouldUnlock) {
        final unlockedAchievement = achievement.copyWith(
          isUnlocked: true,
          unlockedDate: DateTime.now(),
        );
        
        _achievements[i] = unlockedAchievement;
        newlyUnlocked.add(unlockedAchievement);
        
        await _databaseService.updateAchievement(unlockedAchievement);
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      _recentlyUnlocked.addAll(newlyUnlocked);
      notifyListeners();
    }
  }

  Future<int> _getEarlyMorningDaysCount() async {
    try {
      return await _databaseService.getEarlyMorningDaysCount();
    } catch (e) {
      debugPrint('Error getting early morning days count: $e');
      return 0;
    }
  }

  Future<int> _getLateNightDaysCount() async {
    try {
      return await _databaseService.getLateNightDaysCount();
    } catch (e) {
      debugPrint('Error getting late night days count: $e');
      return 0;
    }
  }

  void clearRecentlyUnlocked() {
    _recentlyUnlocked.clear();
    notifyListeners();
  }

  List<Achievement> getAchievementsByType(AchievementType type) {
    return _achievements.where((a) => a.type == type).toList();
  }

  Achievement? getAchievementById(String id) {
    try {
      return _achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshAchievements() async {
    await _loadAchievements();
  }
}
