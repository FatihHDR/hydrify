import 'package:flutter/foundation.dart';
import '../models/water_intake_model.dart';
import '../models/user_profile_model.dart';
import '../models/drink_type_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class HomeViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  UserProfileModel? _userProfile;
  List<WaterIntakeModel> _todayIntakes = [];
  int _todayTotal = 0;
  bool _isLoading = false;

  // Getters
  UserProfileModel? get userProfile => _userProfile;
  List<WaterIntakeModel> get todayIntakes => _todayIntakes;
  int get todayTotal => _todayTotal;
  bool get isLoading => _isLoading;
  
  double get progressPercentage {
    if (_userProfile == null) return 0.0;
    return (_todayTotal / _userProfile!.dailyGoal).clamp(0.0, 1.0);
  }

  int get remainingAmount {
    if (_userProfile == null) return 0;
    final remaining = _userProfile!.dailyGoal - _todayTotal;
    return remaining > 0 ? remaining : 0;
  }

  bool get isGoalAchieved => _userProfile != null && _todayTotal >= _userProfile!.dailyGoal;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadUserProfile();
      await _loadTodayIntakes();
    } catch (e) {
      debugPrint('Error initializing HomeViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    _userProfile = await _databaseService.getUserProfile();
    notifyListeners();
  }
  Future<void> _loadTodayIntakes() async {
    final today = DateTime.now();
    _todayIntakes = await _databaseService.getWaterIntakeByDate(today);
    // Use effective amount if available, otherwise use regular amount
    _todayTotal = _todayIntakes.fold(0, (sum, intake) => 
        sum + (intake.effectiveAmount ?? intake.amount));
    notifyListeners();
  }Future<void> addWaterIntake(int amount, {DrinkTypeModel? drinkType}) async {
    try {
      final now = DateTime.now();
      final effectiveAmount = drinkType != null 
          ? (amount * drinkType.multiplier).round() 
          : amount;
          
      final intake = WaterIntakeModel(
        date: now,
        amount: amount,
        timestamp: now,
        drinkTypeId: drinkType?.id,
        effectiveAmount: effectiveAmount,
      );

      await _databaseService.insertWaterIntake(intake);
      await _loadTodayIntakes();
      
      // Check for achievements after adding water intake
      await _checkAchievements();
      
      // Show success notification
      await _notificationService.showInstantReminder();
      
    } catch (e) {
      debugPrint('Error adding water intake: $e');
    }
  }

  // Legacy method for backward compatibility
  Future<void> addWaterIntakeSimple(int amount) async {
    await addWaterIntake(amount);
  }

  Future<void> removeWaterIntake(WaterIntakeModel intake) async {
    try {
      if (intake.id != null) {
        await _databaseService.deleteWaterIntake(intake.id!);
        await _loadTodayIntakes();
      }
    } catch (e) {
      debugPrint('Error removing water intake: $e');
    }
  }

  Future<void> updateWaterIntake(WaterIntakeModel intake) async {
    try {
      await _databaseService.updateWaterIntake(intake);
      await _loadTodayIntakes();
    } catch (e) {
      debugPrint('Error updating water intake: $e');
    }
  }

  Future<void> refreshData() async {
    await initialize();
  }

  String getMotivationalMessage() {
    if (_userProfile == null) return 'Welcome to Hydrify!';
    
    final percentage = progressPercentage;
    
    if (percentage >= 1.0) {
      return '🎉 Congratulations! You\'ve reached your daily goal!';
    } else if (percentage >= 0.8) {
      return '💪 Almost there! You\'re doing great!';
    } else if (percentage >= 0.5) {
      return '🌊 Good progress! Keep it up!';
    } else if (percentage >= 0.25) {
      return '💧 You\'re on the right track! Don\'t give up!';
    } else {
      return '🚰 Let\'s start hydrating! Your body will thank you!';
    }
  }

  List<int> getQuickAddAmounts() {
    return [200, 250, 300, 500, 750, 1000]; // Common water amounts in ml
  }
  Future<void> _checkAchievements() async {
    try {
      // Get current stats for achievement checking
      final currentStreak = await _databaseService.getCurrentStreak();
      final totalLifetimeIntake = await _databaseService.getTotalLifetimeIntake();
      final dailyGoalsReached = await _databaseService.getDailyGoalsReachedCount();
      
      // Trigger achievement checking through event bus or notification
      // For now, we'll print the stats for debugging
      debugPrint('Current streak: $currentStreak');
      debugPrint('Total lifetime intake: $totalLifetimeIntake ml');
      debugPrint('Daily goals reached: $dailyGoalsReached');
      
    } catch (e) {
      debugPrint('Error checking achievements: $e');
    }
  }
}
