class UserProfileModel {
  final String name;
  final int age;
  final double weight; // in kg
  final int dailyGoal; // in ml
  final bool notificationsEnabled;
  final int notificationInterval; // in minutes
  final DateTime startTime;
  final DateTime endTime;

  UserProfileModel({
    required this.name,
    required this.age,
    required this.weight,
    required this.dailyGoal,
    this.notificationsEnabled = true,
    this.notificationInterval = 60,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'weight': weight,
      'dailyGoal': dailyGoal,
      'notificationsEnabled': notificationsEnabled ? 1 : 0,
      'notificationInterval': notificationInterval,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      weight: map['weight']?.toDouble() ?? 0.0,
      dailyGoal: map['dailyGoal'] ?? 2000,
      notificationsEnabled: map['notificationsEnabled'] == 1,
      notificationInterval: map['notificationInterval'] ?? 60,
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
    );
  }

  UserProfileModel copyWith({
    String? name,
    int? age,
    double? weight,
    int? dailyGoal,
    bool? notificationsEnabled,
    int? notificationInterval,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationInterval: notificationInterval ?? this.notificationInterval,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  // Calculate recommended daily water intake based on weight
  static int calculateRecommendedIntake(double weight) {
    // Basic formula: 35ml per kg of body weight
    return (weight * 35).round();
  }
}
