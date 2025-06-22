import 'package:flutter/foundation.dart';
import '../models/water_intake_model.dart';
import '../models/user_profile_model.dart';
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
    _todayTotal = _todayIntakes.fold(0, (sum, intake) => sum + intake.amount);
    notifyListeners();
  }

  Future<void> addWaterIntake(int amount) async {
    try {
      final now = DateTime.now();
      final intake = WaterIntakeModel(
        date: now,
        amount: amount,
        timestamp: now,
      );

      await _databaseService.insertWaterIntake(intake);
      await _loadTodayIntakes();
      
      // Show success notification
      await _notificationService.showInstantReminder();
      
    } catch (e) {
      debugPrint('Error adding water intake: $e');
    }
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
}
