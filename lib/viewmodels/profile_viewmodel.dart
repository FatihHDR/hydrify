import 'package:flutter/foundation.dart';
import '../models/user_profile_model.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  UserProfileModel? _userProfile;
  bool _isLoading = false;
  bool _isSaving = false;

  // Getters
  UserProfileModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadUserProfile();
    } catch (e) {
      debugPrint('Error initializing ProfileViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    _userProfile = await _databaseService.getUserProfile();
    
    // If no profile exists, create a default one
    if (_userProfile == null) {
      _userProfile = UserProfileModel(
        name: '',
        age: 25,
        weight: 70.0,
        dailyGoal: UserProfileModel.calculateRecommendedIntake(70.0),
        startTime: DateTime(2024, 1, 1, 7, 0), // 7:00 AM
        endTime: DateTime(2024, 1, 1, 22, 0),   // 10:00 PM
      );
    }
    
    notifyListeners();
  }

  Future<bool> saveUserProfile(UserProfileModel profile) async {
    _isSaving = true;
    notifyListeners();

    try {
      await _databaseService.insertOrUpdateUserProfile(profile);
      _userProfile = profile;
      
      // Update notifications with new settings
      if (profile.notificationsEnabled) {
        await _notificationService.scheduleWaterReminders(profile);
      } else {
        await _notificationService.cancelAllNotifications();
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void updateProfile({
    String? name,
    int? age,
    double? weight,
    int? dailyGoal,
    bool? notificationsEnabled,
    int? notificationInterval,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(
        name: name,
        age: age,
        weight: weight,
        dailyGoal: dailyGoal,
        notificationsEnabled: notificationsEnabled,
        notificationInterval: notificationInterval,
        startTime: startTime,
        endTime: endTime,
      );
      notifyListeners();
    }
  }

  void calculateRecommendedGoal() {
    if (_userProfile != null && _userProfile!.weight > 0) {
      final recommendedGoal = UserProfileModel.calculateRecommendedIntake(_userProfile!.weight);
      _userProfile = _userProfile!.copyWith(dailyGoal: recommendedGoal);
      notifyListeners();
    }
  }

  bool validateProfile() {
    if (_userProfile == null) return false;
    
    return _userProfile!.name.isNotEmpty &&
           _userProfile!.age > 0 &&
           _userProfile!.weight > 0 &&
           _userProfile!.dailyGoal > 0;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null || age < 1 || age > 120) {
      return 'Enter a valid age (1-120)';
    }
    return null;
  }

  String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight is required';
    }
    final weight = double.tryParse(value);
    if (weight == null || weight < 1 || weight > 500) {
      return 'Enter a valid weight (1-500 kg)';
    }
    return null;
  }

  String? validateDailyGoal(String? value) {
    if (value == null || value.isEmpty) {
      return 'Daily goal is required';
    }
    final goal = int.tryParse(value);
    if (goal == null || goal < 500 || goal > 5000) {
      return 'Enter a valid goal (500-5000 ml)';
    }
    return null;
  }

  List<int> getNotificationIntervalOptions() {
    return [15, 30, 45, 60, 90, 120]; // minutes
  }
}
