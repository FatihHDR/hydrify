import 'package:flutter/foundation.dart';
import '../models/water_intake_model.dart';
import '../services/database_service.dart';

class HistoryViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<WaterIntakeModel> _history = [];
  List<Map<String, dynamic>> _weeklyStats = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  // Getters
  List<WaterIntakeModel> get history => _history;
  List<Map<String, dynamic>> get weeklyStats => _weeklyStats;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadHistory();
      await _loadWeeklyStats();
    } catch (e) {
      debugPrint('Error initializing HistoryViewModel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadHistory() async {
    _history = await _databaseService.getWaterIntakeHistory(30); // Last 30 days
    notifyListeners();
  }

  Future<void> _loadWeeklyStats() async {
    _weeklyStats = await _databaseService.getWeeklyStats();
    notifyListeners();
  }

  Future<void> loadHistoryForDate(DateTime date) async {
    _selectedDate = date;
    _isLoading = true;
    notifyListeners();

    try {
      _history = await _databaseService.getWaterIntakeByDate(date);
    } catch (e) {
      debugPrint('Error loading history for date: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteIntake(WaterIntakeModel intake) async {
    if (intake.id != null) {
      try {
        await _databaseService.deleteWaterIntake(intake.id!);
        await _loadHistory();
        await _loadWeeklyStats();
      } catch (e) {
        debugPrint('Error deleting intake: $e');
      }
    }
  }

  Map<String, dynamic> getDailyStats(DateTime date) {
    final dayIntakes = _history.where((intake) {
      return intake.date.year == date.year &&
             intake.date.month == date.month &&
             intake.date.day == date.day;
    }).toList();

    final totalAmount = dayIntakes.fold(0, (sum, intake) => sum + intake.amount);
    
    return {
      'totalAmount': totalAmount,
      'totalIntakes': dayIntakes.length,
      'intakes': dayIntakes,
    };
  }

  List<Map<String, dynamic>> getGroupedHistory() {
    final grouped = <String, List<WaterIntakeModel>>{};
    
    for (final intake in _history) {
      final dateKey = '${intake.date.year}-${intake.date.month.toString().padLeft(2, '0')}-${intake.date.day.toString().padLeft(2, '0')}';
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(intake);
    }

    return grouped.entries.map((entry) {
      final totalAmount = entry.value.fold(0, (sum, intake) => sum + intake.amount);
      return {
        'date': entry.key,
        'intakes': entry.value,
        'totalAmount': totalAmount,
        'totalIntakes': entry.value.length,
      };    }).toList()
      ..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String)); // Sort by date descending
  }

  double getAverageIntake(int days) {
    if (_history.isEmpty) return 0.0;
    
    final recentHistory = _history.where((intake) {
      return intake.timestamp.isAfter(DateTime.now().subtract(Duration(days: days)));
    }).toList();

    if (recentHistory.isEmpty) return 0.0;

    final totalAmount = recentHistory.fold(0, (sum, intake) => sum + intake.amount);
    final uniqueDays = recentHistory.map((intake) {
      return '${intake.date.year}-${intake.date.month}-${intake.date.day}';
    }).toSet().length;

    return uniqueDays > 0 ? totalAmount / uniqueDays : 0.0;
  }

  Map<String, int> getWeeklyTotals() {
    final weeklyTotals = <String, int>{};
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final dayIntakes = _history.where((intake) {
        return intake.date.year == date.year &&
               intake.date.month == date.month &&
               intake.date.day == date.day;
      }).toList();
      
      weeklyTotals[dateKey] = dayIntakes.fold(0, (sum, intake) => sum + intake.amount);
    }
    
    return weeklyTotals;
  }

  Future<void> refreshHistory() async {
    await initialize();
  }
}
