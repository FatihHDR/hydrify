class AnalyticsData {
  final double averageDailyIntake;
  final int totalDays;
  final int goalReachedDays;
  final double goalCompletionRate;
  final int currentStreak;
  final int longestStreak;
  final int totalIntake;
  final List<DailyStats> weeklyStats;
  final List<MonthlyStats> monthlyStats;
  final List<HourlyPattern> hourlyPatterns;
  final Map<String, int> weekdayPatterns;
  final StreakInfo streakInfo;

  AnalyticsData({
    required this.averageDailyIntake,
    required this.totalDays,
    required this.goalReachedDays,
    required this.goalCompletionRate,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalIntake,
    required this.weeklyStats,
    required this.monthlyStats,
    required this.hourlyPatterns,
    required this.weekdayPatterns,
    required this.streakInfo,
  });
}

class DailyStats {
  final DateTime date;
  final int totalIntake;
  final int goalAmount;
  final bool goalReached;
  final int intakeCount;
  final double completionPercentage;

  DailyStats({
    required this.date,
    required this.totalIntake,
    required this.goalAmount,
    required this.goalReached,
    required this.intakeCount,
    required this.completionPercentage,
  });
}

class MonthlyStats {
  final int year;
  final int month;
  final String monthName;
  final int totalIntake;
  final double averageDailyIntake;
  final int goalReachedDays;
  final int totalDays;
  final double completionRate;

  MonthlyStats({
    required this.year,
    required this.month,
    required this.monthName,
    required this.totalIntake,
    required this.averageDailyIntake,
    required this.goalReachedDays,
    required this.totalDays,
    required this.completionRate,
  });
}

class HourlyPattern {
  final int hour;
  final int averageIntake;
  final int frequency;
  final String timeLabel;

  HourlyPattern({
    required this.hour,
    required this.averageIntake,
    required this.frequency,
    required this.timeLabel,
  });
}

class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final DateTime? longestStreakStart;
  final DateTime? longestStreakEnd;
  final DateTime? currentStreakStart;
  final List<StreakPeriod> streakHistory;

  StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    this.longestStreakStart,
    this.longestStreakEnd,
    this.currentStreakStart,
    required this.streakHistory,
  });
}

class StreakPeriod {
  final DateTime startDate;
  final DateTime endDate;
  final int days;

  StreakPeriod({
    required this.startDate,
    required this.endDate,
    required this.days,
  });
}

class ComparisonData {
  final String period; // 'week', 'month', 'year'
  final double currentPeriodAverage;
  final double previousPeriodAverage;
  final double percentageChange;
  final bool isImprovement;

  ComparisonData({
    required this.period,
    required this.currentPeriodAverage,
    required this.previousPeriodAverage,
    required this.percentageChange,
    required this.isImprovement,
  });
}

class TrendData {
  final String trendType; // 'increasing', 'decreasing', 'stable'
  final double trendValue;
  final String description;
  final List<double> dataPoints;

  TrendData({
    required this.trendType,
    required this.trendValue,
    required this.description,
    required this.dataPoints,
  });
}

class GoalInsight {
  final String insightType;
  final String title;
  final String description;
  final String recommendation;
  final double relevanceScore;

  GoalInsight({
    required this.insightType,
    required this.title,
    required this.description,
    required this.recommendation,
    required this.relevanceScore,
  });
}
