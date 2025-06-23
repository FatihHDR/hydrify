import '../models/analytics_model.dart';
import '../models/water_intake_model.dart';
import 'database_service.dart';

class AnalyticsService {
  final DatabaseService _databaseService = DatabaseService();

  Future<AnalyticsData> generateAnalytics({
    int? days,
    DateTime? startDate,
    DateTime? endDate,
    int? dailyGoal,
  }) async {
    final now = DateTime.now();
    final analysisStartDate = startDate ?? now.subtract(Duration(days: days ?? 30));
    final analysisEndDate = endDate ?? now;
    final userDailyGoal = dailyGoal ?? 2000;

    // Get all water intake data for the period
    final allIntakes = await _getIntakesForPeriod(analysisStartDate, analysisEndDate);
    
    // Calculate basic statistics
    final dailyStats = await _calculateDailyStats(allIntakes, userDailyGoal);
    final weeklyStats = _calculateWeeklyStats(dailyStats);
    final monthlyStats = _calculateMonthlyStats(dailyStats);
    final hourlyPatterns = _calculateHourlyPatterns(allIntakes);
    final weekdayPatterns = _calculateWeekdayPatterns(allIntakes);
    final streakInfo = _calculateStreakInfo(dailyStats);

    // Calculate summary statistics
    final totalIntake = allIntakes.fold(0, (sum, intake) => sum + intake.amount);
    final totalDays = dailyStats.length;
    final goalReachedDays = dailyStats.where((day) => day.goalReached).length;
    final averageDailyIntake = totalDays > 0 ? totalIntake / totalDays : 0.0;
    final goalCompletionRate = totalDays > 0 ? goalReachedDays / totalDays : 0.0;

    return AnalyticsData(
      averageDailyIntake: averageDailyIntake,
      totalDays: totalDays,
      goalReachedDays: goalReachedDays,
      goalCompletionRate: goalCompletionRate,
      currentStreak: streakInfo.currentStreak,
      longestStreak: streakInfo.longestStreak,
      totalIntake: totalIntake,
      weeklyStats: weeklyStats,
      monthlyStats: monthlyStats,
      hourlyPatterns: hourlyPatterns,
      weekdayPatterns: weekdayPatterns,
      streakInfo: streakInfo,
    );
  }

  Future<List<ComparisonData>> generateComparisonData(int dailyGoal) async {
    final now = DateTime.now();
    final comparisons = <ComparisonData>[];

    // Week comparison
    final thisWeekIntakes = await _getIntakesForPeriod(
      now.subtract(const Duration(days: 7)),
      now,
    );
    final lastWeekIntakes = await _getIntakesForPeriod(
      now.subtract(const Duration(days: 14)),
      now.subtract(const Duration(days: 7)),
    );

    final thisWeekAvg = _calculateAverageIntake(thisWeekIntakes, 7);
    final lastWeekAvg = _calculateAverageIntake(lastWeekIntakes, 7);
    final weekChange = _calculatePercentageChange(lastWeekAvg, thisWeekAvg);

    comparisons.add(ComparisonData(
      period: 'week',
      currentPeriodAverage: thisWeekAvg,
      previousPeriodAverage: lastWeekAvg,
      percentageChange: weekChange,
      isImprovement: weekChange >= 0,
    ));

    // Month comparison
    final thisMonthIntakes = await _getIntakesForPeriod(
      DateTime(now.year, now.month, 1),
      now,
    );
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 1).subtract(const Duration(days: 1));
    final lastMonthIntakes = await _getIntakesForPeriod(lastMonthStart, lastMonthEnd);

    final thisMonthAvg = _calculateAverageIntake(thisMonthIntakes, now.day);
    final lastMonthAvg = _calculateAverageIntake(lastMonthIntakes, lastMonthEnd.day);
    final monthChange = _calculatePercentageChange(lastMonthAvg, thisMonthAvg);

    comparisons.add(ComparisonData(
      period: 'month',
      currentPeriodAverage: thisMonthAvg,
      previousPeriodAverage: lastMonthAvg,
      percentageChange: monthChange,
      isImprovement: monthChange >= 0,
    ));

    return comparisons;
  }

  Future<TrendData> calculateTrend(int days) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final intakes = await _getIntakesForPeriod(startDate, now);
    final dailyStats = await _calculateDailyStats(intakes, 2000);

    final dataPoints = dailyStats.map((day) => day.totalIntake.toDouble()).toList();
    
    if (dataPoints.length < 3) {
      return TrendData(
        trendType: 'stable',
        trendValue: 0,
        description: 'Insufficient data for trend analysis',
        dataPoints: dataPoints,
      );
    }

    // Simple linear regression to calculate trend
    final trend = _calculateLinearTrend(dataPoints);
    String trendType;
    String description;

    if (trend > 10) {
      trendType = 'increasing';
      description = 'Your water intake is trending upward! Keep up the great work.';
    } else if (trend < -10) {
      trendType = 'decreasing';
      description = 'Your water intake has been declining. Consider setting reminders.';
    } else {
      trendType = 'stable';
      description = 'Your water intake is relatively stable.';
    }

    return TrendData(
      trendType: trendType,
      trendValue: trend,
      description: description,
      dataPoints: dataPoints,
    );
  }

  Future<List<GoalInsight>> generateInsights(AnalyticsData analytics, int dailyGoal) async {
    final insights = <GoalInsight>[];

    // Goal completion insight
    if (analytics.goalCompletionRate < 0.5) {
      insights.add(GoalInsight(
        insightType: 'goal_completion',
        title: 'Goal Achievement Opportunity',
        description: 'You\'re reaching your daily goal ${(analytics.goalCompletionRate * 100).toInt()}% of the time.',
        recommendation: 'Try setting smaller, more achievable goals or increase reminder frequency.',
        relevanceScore: 0.9,
      ));
    }

    // Streak insight
    if (analytics.currentStreak == 0 && analytics.longestStreak > 3) {
      insights.add(GoalInsight(
        insightType: 'streak',
        title: 'Streak Recovery',
        description: 'Your longest streak was ${analytics.longestStreak} days, but you\'re currently at 0.',
        recommendation: 'Focus on consistency. Start with just meeting 50% of your goal daily.',
        relevanceScore: 0.8,
      ));
    }

    // Best performance day insight
    final bestDay = _findBestPerformanceDay(analytics.weekdayPatterns);
    if (bestDay != null) {
      insights.add(GoalInsight(
        insightType: 'performance_pattern',
        title: 'Best Performance Day',
        description: 'You perform best on ${bestDay}s with higher water intake.',
        recommendation: 'Try to replicate your ${bestDay} routine on other days.',
        relevanceScore: 0.7,
      ));
    }

    // Hydration timing insight
    final peakHour = analytics.hourlyPatterns.isNotEmpty
        ? analytics.hourlyPatterns.reduce((a, b) => a.averageIntake > b.averageIntake ? a : b)
        : null;
    
    if (peakHour != null && peakHour.hour > 16) {
      insights.add(GoalInsight(
        insightType: 'timing',
        title: 'Late Day Hydration',
        description: 'Most of your water intake happens in the evening (${peakHour.timeLabel}).',
        recommendation: 'Try drinking more water earlier in the day for better hydration distribution.',
        relevanceScore: 0.6,
      ));
    }

    return insights..sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
  }

  // Private helper methods
  Future<List<WaterIntakeModel>> _getIntakesForPeriod(DateTime start, DateTime end) async {
    final allIntakes = <WaterIntakeModel>[];
    DateTime currentDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final dayIntakes = await _databaseService.getWaterIntakeByDate(currentDate);
      allIntakes.addAll(dayIntakes);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return allIntakes;
  }

  Future<List<DailyStats>> _calculateDailyStats(List<WaterIntakeModel> intakes, int dailyGoal) async {
    final dailyMap = <String, List<WaterIntakeModel>>{};
    
    for (final intake in intakes) {
      final dateKey = '${intake.date.year}-${intake.date.month}-${intake.date.day}';
      dailyMap[dateKey] ??= [];
      dailyMap[dateKey]!.add(intake);
    }

    return dailyMap.entries.map((entry) {
      final date = DateTime.parse('${entry.key} 00:00:00');
      final dayIntakes = entry.value;
      final totalIntake = dayIntakes.fold(0, (sum, intake) => sum + intake.amount);
      final goalReached = totalIntake >= dailyGoal;
      final completionPercentage = totalIntake / dailyGoal;

      return DailyStats(
        date: date,
        totalIntake: totalIntake,
        goalAmount: dailyGoal,
        goalReached: goalReached,
        intakeCount: dayIntakes.length,
        completionPercentage: completionPercentage,
      );
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  List<DailyStats> _calculateWeeklyStats(List<DailyStats> dailyStats) {
    // Return last 7 days for weekly view
    return dailyStats.length > 7 
        ? dailyStats.sublist(dailyStats.length - 7)
        : dailyStats;
  }

  List<MonthlyStats> _calculateMonthlyStats(List<DailyStats> dailyStats) {
    final monthlyMap = <String, List<DailyStats>>{};
    
    for (final day in dailyStats) {
      final monthKey = '${day.date.year}-${day.date.month}';
      monthlyMap[monthKey] ??= [];
      monthlyMap[monthKey]!.add(day);
    }

    const monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return monthlyMap.entries.map((entry) {
      final parts = entry.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final monthDays = entry.value;
      
      final totalIntake = monthDays.fold(0, (sum, day) => sum + day.totalIntake);
      final goalReachedDays = monthDays.where((day) => day.goalReached).length;
      final averageDailyIntake = totalIntake / monthDays.length;
      final completionRate = goalReachedDays / monthDays.length;

      return MonthlyStats(
        year: year,
        month: month,
        monthName: monthNames[month],
        totalIntake: totalIntake,
        averageDailyIntake: averageDailyIntake,
        goalReachedDays: goalReachedDays,
        totalDays: monthDays.length,
        completionRate: completionRate,
      );
    }).toList()..sort((a, b) => a.year == b.year ? a.month.compareTo(b.month) : a.year.compareTo(b.year));
  }

  List<HourlyPattern> _calculateHourlyPatterns(List<WaterIntakeModel> intakes) {
    final hourlyMap = <int, List<int>>{};
    
    for (final intake in intakes) {
      final hour = intake.timestamp.hour;
      hourlyMap[hour] ??= [];
      hourlyMap[hour]!.add(intake.amount);
    }

    final patterns = <HourlyPattern>[];
    for (int hour = 0; hour < 24; hour++) {
      final amounts = hourlyMap[hour] ?? [];
      final averageIntake = amounts.isNotEmpty 
          ? amounts.reduce((a, b) => a + b) ~/ amounts.length 
          : 0;
      final frequency = amounts.length;
      
      String timeLabel;
      if (hour == 0) timeLabel = '12 AM';
      else if (hour < 12) timeLabel = '$hour AM';
      else if (hour == 12) timeLabel = '12 PM';
      else timeLabel = '${hour - 12} PM';

      patterns.add(HourlyPattern(
        hour: hour,
        averageIntake: averageIntake,
        frequency: frequency,
        timeLabel: timeLabel,
      ));
    }

    return patterns;
  }

  Map<String, int> _calculateWeekdayPatterns(List<WaterIntakeModel> intakes) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final weekdayMap = <String, int>{};
    
    for (final weekday in weekdays) {
      weekdayMap[weekday] = 0;
    }

    for (final intake in intakes) {
      final weekday = weekdays[intake.date.weekday - 1];
      weekdayMap[weekday] = weekdayMap[weekday]! + intake.amount;
    }

    return weekdayMap;
  }

  StreakInfo _calculateStreakInfo(List<DailyStats> dailyStats) {
    if (dailyStats.isEmpty) {
      return StreakInfo(
        currentStreak: 0,
        longestStreak: 0,
        streakHistory: [],
      );
    }

    int currentStreak = 0;
    int longestStreak = 0;
    DateTime? currentStreakStart;
    DateTime? longestStreakStart;
    DateTime? longestStreakEnd;
    final streakHistory = <StreakPeriod>[];

    // Calculate current streak (from the end)
    for (int i = dailyStats.length - 1; i >= 0; i--) {
      if (dailyStats[i].goalReached) {
        currentStreak++;
        currentStreakStart ??= dailyStats[i].date;
      } else {
        break;
      }
    }

    // Calculate longest streak and streak history
    int tempStreak = 0;
    DateTime? tempStart;
    
    for (final day in dailyStats) {
      if (day.goalReached) {
        if (tempStreak == 0) {
          tempStart = day.date;
        }
        tempStreak++;
        
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
          longestStreakStart = tempStart;
          longestStreakEnd = day.date;
        }
      } else {
        if (tempStreak > 0) {
          streakHistory.add(StreakPeriod(
            startDate: tempStart!,
            endDate: dailyStats[dailyStats.indexOf(day) - 1].date,
            days: tempStreak,
          ));
        }
        tempStreak = 0;
        tempStart = null;
      }
    }

    // Add final streak if it exists
    if (tempStreak > 0) {
      streakHistory.add(StreakPeriod(
        startDate: tempStart!,
        endDate: dailyStats.last.date,
        days: tempStreak,
      ));
    }

    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      longestStreakStart: longestStreakStart,
      longestStreakEnd: longestStreakEnd,
      currentStreakStart: currentStreakStart,
      streakHistory: streakHistory,
    );
  }

  double _calculateAverageIntake(List<WaterIntakeModel> intakes, int days) {
    if (intakes.isEmpty || days == 0) return 0.0;
    final total = intakes.fold(0, (sum, intake) => sum + intake.amount);
    return total / days;
  }

  double _calculatePercentageChange(double previous, double current) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous) * 100;
  }

  double _calculateLinearTrend(List<double> dataPoints) {
    if (dataPoints.length < 2) return 0.0;
    
    final n = dataPoints.length;
    final xSum = (n * (n - 1)) / 2; // Sum of indices 0,1,2...n-1
    final ySum = dataPoints.reduce((a, b) => a + b);
    final xySum = dataPoints.asMap().entries
        .map((entry) => entry.key * entry.value)
        .reduce((a, b) => a + b);
    final xSquaredSum = (n * (n - 1) * (2 * n - 1)) / 6; // Sum of squares of indices

    final slope = (n * xySum - xSum * ySum) / (n * xSquaredSum - xSum * xSum);
    return slope;
  }

  String? _findBestPerformanceDay(Map<String, int> weekdayPatterns) {
    if (weekdayPatterns.isEmpty) return null;
    
    final bestEntry = weekdayPatterns.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    
    return bestEntry.value > 0 ? bestEntry.key : null;
  }
}
