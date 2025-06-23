import 'package:flutter_test/flutter_test.dart';
import 'package:hydrify/models/achievement_model.dart';
import 'package:hydrify/services/database_service.dart';

void main() {
  group('Achievement System Tests', () {
    late DatabaseService databaseService;

    setUp(() {
      databaseService = DatabaseService();
    });

    test('Should create default achievements', () {
      final achievements = Achievement.getDefaultAchievements();
      expect(achievements, isNotEmpty);
      expect(achievements.length, greaterThan(5));
      
      // Check if first glass achievement exists
      final firstGlass = achievements.firstWhere(
        (a) => a.id == 'first_glass',
        orElse: () => throw Exception('First glass achievement not found'),
      );
      expect(firstGlass.title, equals('First Drop'));
    });

    test('Should have proper achievement types', () {
      final achievements = Achievement.getDefaultAchievements();
      
      final hasStreak = achievements.any((a) => a.type == AchievementType.streak);
      final hasTotalIntake = achievements.any((a) => a.type == AchievementType.totalIntake);
      final hasMilestone = achievements.any((a) => a.type == AchievementType.milestone);
      
      expect(hasStreak, isTrue);
      expect(hasTotalIntake, isTrue);
      expect(hasMilestone, isTrue);
    });
  });
}
