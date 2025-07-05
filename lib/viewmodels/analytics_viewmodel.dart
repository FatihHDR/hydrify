import 'package:flutter/material.dart';
import '../models/analytics_model.dart';
import '../models/user_profile_model.dart';
import '../services/analytics_service.dart';
import '../services/database_service.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();
  final DatabaseService _databaseService = DatabaseService();

  AnalyticsData? _analyticsData;
  List<ComparisonData> _comparisons = [];
  TrendData? _trendData;
  List<GoalInsight> _insights = [];
  bool _isLoading = false;
  String? _error;
  
  // Analysis period settings
  int _analysisDays = 30;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  String _selectedPeriod = '30days'; // '7days', '30days', '90days', 'custom'

  // Getters
  AnalyticsData? get analyticsData => _analyticsData;
  List<ComparisonData> get comparisons => _comparisons;
  TrendData? get trendData => _trendData;
  List<GoalInsight> get insights => _insights;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get analysisDays => _analysisDays;
  String get selectedPeriod => _selectedPeriod;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;

  // Computed properties
  bool get hasData => _analyticsData != null;
  double get improvementPercentage {
    if (_comparisons.isEmpty) return 0.0;
    final weekComparison = _comparisons.firstWhere(
      (c) => c.period == 'week',
      orElse: () => ComparisonData(
        period: 'week',
        currentPeriodAverage: 0,
        previousPeriodAverage: 0,
        percentageChange: 0,
        isImprovement: false,
      ),
    );
    return weekComparison.percentageChange;
  }

  String get trendDescription {
    if (_trendData == null) return 'No trend data available';
    return _trendData!.description;
  }

  List<GoalInsight> get priorityInsights {
    return _insights.where((insight) => insight.relevanceScore >= 0.7).toList();
  }

  Future<void> loadAnalytics({int? dailyGoal}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userProfile = await _getUserProfile();
      final goal = dailyGoal ?? userProfile?.dailyGoal ?? 2000;

      DateTime? startDate = _customStartDate;
      DateTime? endDate = _customEndDate;
      int? days = _analysisDays;

      if (_selectedPeriod == 'custom' && startDate != null && endDate != null) {
        days = null;
      } else {
        startDate = null;
        endDate = null;
        switch (_selectedPeriod) {
          case '7days':
            days = 7;
            break;
          case '30days':
            days = 30;
            break;
          case '90days':
            days = 90;
            break;
          default:
            days = 30;
        }
      }

      // Load main analytics data
      _analyticsData = await _analyticsService.generateAnalytics(
        days: days,
        startDate: startDate,
        endDate: endDate,
        dailyGoal: goal,
      );

      // Load comparison data
      _comparisons = await _analyticsService.generateComparisonData(goal);

      // Load trend data
      _trendData = await _analyticsService.calculateTrend(days ?? 30);

      // Generate insights
      if (_analyticsData != null) {
        _insights = await _analyticsService.generateInsights(_analyticsData!, goal);
      }      _error = null;
    } catch (e, stackTrace) {
      if (e.toString().contains('FormatException')) {
        _error = 'Data format error. Please check your water intake records.';
      } else if (e.toString().contains('database')) {
        _error = 'Database error. Please try refreshing the data.';
      } else {
        _error = 'Failed to load analytics: ${e.toString()}';
      }
      debugPrint('Analytics loading error: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAnalytics() async {
    await loadAnalytics();
  }

  void setAnalysisPeriod(String period) {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      switch (period) {
        case '7days':
          _analysisDays = 7;
          break;
        case '30days':
          _analysisDays = 30;
          break;
        case '90days':
          _analysisDays = 90;
          break;
      }
      notifyListeners();
      loadAnalytics();
    }
  }

  void setCustomDateRange(DateTime startDate, DateTime endDate) {
    _customStartDate = startDate;
    _customEndDate = endDate;
    _selectedPeriod = 'custom';
    notifyListeners();
    loadAnalytics();
  }

  void clearCustomDateRange() {
    _customStartDate = null;
    _customEndDate = null;
    _selectedPeriod = '30days';
    _analysisDays = 30;
    notifyListeners();
    loadAnalytics();
  }

  // Helper methods for UI
  String getFormattedAverage() {
    if (_analyticsData == null) return '0 ml';
    return '${_analyticsData!.averageDailyIntake.toInt()} ml';
  }

  String getFormattedGoalRate() {
    if (_analyticsData == null) return '0%';
    return '${(_analyticsData!.goalCompletionRate * 100).toInt()}%';
  }

  String getFormattedStreak() {
    if (_analyticsData == null) return '0 days';
    return '${_analyticsData!.currentStreak} days';
  }

  String getFormattedTotalIntake() {
    if (_analyticsData == null) return '0 L';
    final liters = _analyticsData!.totalIntake / 1000;
    return '${liters.toStringAsFixed(1)} L';
  }

  Color getStreakColor() {
    if (_analyticsData == null) return Colors.grey;
    final streak = _analyticsData!.currentStreak;
    if (streak >= 7) return Colors.green;
    if (streak >= 3) return Colors.orange;
    return Colors.red;
  }

  Color getTrendColor() {
    if (_trendData == null) return Colors.grey;
    switch (_trendData!.trendType) {
      case 'increasing':
        return Colors.green;
      case 'decreasing':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData getTrendIcon() {
    if (_trendData == null) return Icons.trending_flat;
    switch (_trendData!.trendType) {
      case 'increasing':
        return Icons.trending_up;
      case 'decreasing':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  String getBestDay() {
    if (_analyticsData == null || _analyticsData!.weekdayPatterns.isEmpty) {
      return 'No data';
    }
    
    final bestEntry = _analyticsData!.weekdayPatterns.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    
    return bestEntry.key;
  }

  String getWorstDay() {
    if (_analyticsData == null || _analyticsData!.weekdayPatterns.isEmpty) {
      return 'No data';
    }
    
    final worstEntry = _analyticsData!.weekdayPatterns.entries.reduce(
      (a, b) => a.value < b.value ? a : b,
    );
    
    return worstEntry.key;
  }

  double getWeekdayPerformance(String weekday) {
    if (_analyticsData == null) return 0.0;
    final intake = _analyticsData!.weekdayPatterns[weekday] ?? 0;
    final maxIntake = _analyticsData!.weekdayPatterns.values.isNotEmpty
        ? _analyticsData!.weekdayPatterns.values.reduce((a, b) => a > b ? a : b)
        : 1;
    return maxIntake > 0 ? intake / maxIntake : 0.0;
  }

  List<DailyStats> getRecentDays(int count) {
    if (_analyticsData == null) return [];
    final recent = _analyticsData!.weeklyStats;
    return recent.length > count ? recent.sublist(recent.length - count) : recent;
  }

  Future<UserProfileModel?> _getUserProfile() async {
    try {
      return await _databaseService.getUserProfile();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      return null;
    }
  }

}
