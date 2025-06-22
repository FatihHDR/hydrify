import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/water_models.dart';

class HydrationProvider extends ChangeNotifier {
  List<WaterIntake> _waterIntakes = [];
  DailyGoal? _todayGoal;
  int _defaultDailyGoal = 2000; // 2L in ml

  List<WaterIntake> get waterIntakes => _waterIntakes;
  DailyGoal? get todayGoal => _todayGoal;
  int get defaultDailyGoal => _defaultDailyGoal;

  List<WaterIntake> get todayIntakes {
    final today = DateTime.now();
    return _waterIntakes.where((intake) {
      return intake.date.year == today.year &&
          intake.date.month == today.month &&
          intake.date.day == today.day;
    }).toList();
  }

  int get todayTotal {
    return todayIntakes.fold(0, (sum, intake) => sum + intake.amount);
  }

  double get todayProgress {
    if (_todayGoal == null) return 0.0;
    return (todayTotal / _todayGoal!.targetAmount).clamp(0.0, 1.0);
  }

  HydrationProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load default goal
    _defaultDailyGoal = prefs.getInt('default_daily_goal') ?? 2000;
    
    // Load water intakes
    final intakesJson = prefs.getString('water_intakes');
    if (intakesJson != null) {
      final List<dynamic> intakesList = json.decode(intakesJson);
      _waterIntakes = intakesList.map((e) => WaterIntake.fromJson(e)).toList();
    }
    
    // Create or load today's goal
    await _createTodayGoal();
    
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save default goal
    await prefs.setInt('default_daily_goal', _defaultDailyGoal);
    
    // Save water intakes
    final intakesJson = json.encode(_waterIntakes.map((e) => e.toJson()).toList());
    await prefs.setString('water_intakes', intakesJson);
    
    // Save today's goal
    if (_todayGoal != null) {
      final goalJson = json.encode(_todayGoal!.toJson());
      await prefs.setString('today_goal', goalJson);
    }
  }

  Future<void> _createTodayGoal() async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    
    final prefs = await SharedPreferences.getInstance();
    final goalJson = prefs.getString('today_goal');
    
    if (goalJson != null) {
      final goal = DailyGoal.fromJson(json.decode(goalJson));
      if (goal.date.day == today.day && 
          goal.date.month == today.month && 
          goal.date.year == today.year) {
        _todayGoal = goal;
        _todayGoal!.currentAmount = todayTotal;
        return;
      }
    }
    
    // Create new goal for today
    _todayGoal = DailyGoal(
      targetAmount: _defaultDailyGoal,
      date: todayStart,
      currentAmount: todayTotal,
    );
  }

  Future<void> addWaterIntake(int amount) async {
    final now = DateTime.now();
    final intake = WaterIntake(
      date: now,
      amount: amount,
      time: "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
    );
    
    _waterIntakes.add(intake);
    
    if (_todayGoal != null) {
      _todayGoal!.currentAmount = todayTotal;
    }
    
    await _saveData();
    notifyListeners();
  }

  Future<void> setDailyGoal(int amount) async {
    _defaultDailyGoal = amount;
    
    if (_todayGoal != null) {
      _todayGoal = DailyGoal(
        targetAmount: amount,
        date: _todayGoal!.date,
        currentAmount: _todayGoal!.currentAmount,
      );
    }
    
    await _saveData();
    notifyListeners();
  }

  Future<void> removeWaterIntake(WaterIntake intake) async {
    _waterIntakes.remove(intake);
    
    if (_todayGoal != null) {
      _todayGoal!.currentAmount = todayTotal;
    }
    
    await _saveData();
    notifyListeners();
  }

  List<WaterIntake> getIntakesForDate(DateTime date) {
    return _waterIntakes.where((intake) {
      return intake.date.year == date.year &&
          intake.date.month == date.month &&
          intake.date.day == date.day;
    }).toList();
  }

  Map<DateTime, int> getWeeklyData() {
    final Map<DateTime, int> weeklyData = {};
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayIntakes = getIntakesForDate(dayStart);
      final total = dayIntakes.fold(0, (sum, intake) => sum + intake.amount);
      weeklyData[dayStart] = total;
    }
    
    return weeklyData;
  }
}
