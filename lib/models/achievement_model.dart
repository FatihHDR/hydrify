import 'package:flutter/material.dart';

enum AchievementType {
  streak,
  totalIntake,
  dailyGoal, 
  earlyBird,
  nightOwl,
  consistency,
  milestone
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int requiredValue;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final AchievementType type;
  final Color color;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredValue,
    this.isUnlocked = false,
    this.unlockedDate,
    required this.type,
    required this.color,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    int? requiredValue,
    bool? isUnlocked,
    DateTime? unlockedDate,
    AchievementType? type,
    Color? color,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      requiredValue: requiredValue ?? this.requiredValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      type: type ?? this.type,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon.codePoint,
      'requiredValue': requiredValue,
      'isUnlocked': isUnlocked ? 1 : 0,
      'unlockedDate': unlockedDate?.toIso8601String(),
      'type': type.index,
      'color': color.value,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      requiredValue: map['requiredValue'],
      isUnlocked: map['isUnlocked'] == 1,
      unlockedDate: map['unlockedDate'] != null 
          ? DateTime.parse(map['unlockedDate']) 
          : null,
      type: AchievementType.values[map['type']],
      color: Color(map['color']),
    );
  }

  // Predefined achievements
  static List<Achievement> getDefaultAchievements() {
    return [
      // Streak Achievements
      const Achievement(
        id: 'streak_3',
        title: 'Getting Started',
        description: 'Drink water for 3 consecutive days',
        icon: Icons.local_fire_department,
        requiredValue: 3,
        type: AchievementType.streak,
        color: Colors.orange,
      ),
      const Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain hydration streak for 7 days',
        icon: Icons.whatshot,
        requiredValue: 7,
        type: AchievementType.streak,
        color: Colors.deepOrange,
      ),
      const Achievement(
        id: 'streak_30',
        title: 'Hydration Master',
        description: 'Achieve 30-day hydration streak',
        icon: Icons.military_tech,
        requiredValue: 30,
        type: AchievementType.streak,
        color: Colors.red,
      ),
      
      // Total Intake Achievements
      const Achievement(
        id: 'total_100l',
        title: 'Century Club',
        description: 'Drink 100 liters of water total',
        icon: Icons.water_drop,
        requiredValue: 100000, // in ml
        type: AchievementType.totalIntake,
        color: Colors.blue,
      ),
      const Achievement(
        id: 'total_500l',
        title: 'Hydration Hero',
        description: 'Reach 500 liters lifetime intake',
        icon: Icons.waves,
        requiredValue: 500000, // in ml
        type: AchievementType.totalIntake,
        color: Colors.cyan,
      ),
      const Achievement(
        id: 'total_1000l',
        title: 'Ocean Explorer',
        description: 'Achieve 1000 liters lifetime milestone',
        icon: Icons.pool,
        requiredValue: 1000000, // in ml
        type: AchievementType.totalIntake,
        color: Colors.teal,
      ),
      
      // Daily Goal Achievements
      const Achievement(
        id: 'goal_7',
        title: 'Goal Getter',
        description: 'Meet daily goal 7 times',
        icon: Icons.flag,
        requiredValue: 7,
        type: AchievementType.dailyGoal,
        color: Colors.green,
      ),
      const Achievement(
        id: 'goal_30',
        title: 'Consistent Champion',
        description: 'Reach daily goal 30 times',
        icon: Icons.emoji_events,
        requiredValue: 30,
        type: AchievementType.dailyGoal,
        color: Colors.lightGreen,
      ),
      
      // Time-based Achievements
      const Achievement(
        id: 'early_bird',
        title: 'Early Bird',
        description: 'Drink water before 8 AM for 7 days',
        icon: Icons.wb_sunny,
        requiredValue: 7,
        type: AchievementType.earlyBird,
        color: Colors.amber,
      ),
      const Achievement(
        id: 'night_owl',
        title: 'Night Owl',
        description: 'Stay hydrated after 10 PM for 5 days',
        icon: Icons.nightlight,
        requiredValue: 5,
        type: AchievementType.nightOwl,
        color: Colors.indigo,
      ),
      
      // Milestone Achievements
      const Achievement(
        id: 'first_glass',
        title: 'First Drop',
        description: 'Log your first glass of water',
        icon: Icons.star,
        requiredValue: 1,
        type: AchievementType.milestone,
        color: Colors.purple,
      ),
      const Achievement(
        id: 'perfectionist',
        title: 'Perfectionist',
        description: 'Exceed daily goal by 50% in one day',
        icon: Icons.star_border,
        requiredValue: 150, // percentage
        type: AchievementType.milestone,
        color: Colors.pink,
      ),
    ];
  }
}
