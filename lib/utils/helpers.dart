import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }

  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    final difference = today.difference(targetDate).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return formatDate(date);
    }
  }

  static String getDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static List<DateTime> getWeekDates(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }
}

class WaterCalculator {
  static String formatAmount(int amount) {
    if (amount >= 1000) {
      final liters = amount / 1000;
      return '${liters.toStringAsFixed(liters.truncateToDouble() == liters ? 0 : 1)}L';
    }
    return '${amount}ml';
  }

  static int calculateRecommendedIntake(double weight, {int activityLevel = 1}) {
    // Base calculation: 35ml per kg
    int baseIntake = (weight * 35).round();
    
    // Adjust for activity level
    switch (activityLevel) {
      case 0: // Sedentary
        return (baseIntake * 0.9).round();
      case 1: // Lightly active
        return baseIntake;
      case 2: // Moderately active
        return (baseIntake * 1.1).round();
      case 3: // Very active
        return (baseIntake * 1.3).round();
      default:
        return baseIntake;
    }
  }

  static double getProgressPercentage(int current, int target) {
    if (target <= 0) return 0.0;
    return (current / target).clamp(0.0, 1.0);
  }

  static String getProgressText(int current, int target) {
    final percentage = (getProgressPercentage(current, target) * 100).round();
    return '$percentage%';
  }

  static int getRemainingAmount(int current, int target) {
    final remaining = target - current;
    return remaining > 0 ? remaining : 0;
  }

  static List<int> getQuickAddSuggestions() {
    return [200, 250, 300, 500, 750, 1000];
  }
}

class ValidationUtils {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null || age < 1 || age > 120) {
      return 'Enter a valid age (1-120)';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight is required';
    }
    final weight = double.tryParse(value);
    if (weight == null || weight < 1 || weight > 500) {
      return 'Enter a valid weight (1-500 kg)';
    }
    return null;
  }

  static String? validateWaterAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    final amount = int.tryParse(value);
    if (amount == null || amount < 1 || amount > 2000) {
      return 'Enter a valid amount (1-2000 ml)';
    }
    return null;
  }

  static String? validateDailyGoal(String? value) {
    if (value == null || value.isEmpty) {
      return 'Daily goal is required';
    }
    final goal = int.tryParse(value);
    if (goal == null || goal < 500 || goal > 5000) {
      return 'Enter a valid goal (500-5000 ml)';
    }
    return null;
  }
}
