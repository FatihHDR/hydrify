class UserProfileModel {
  final String name;
  final int age;
  final double weight; // in kg
  final int dailyGoal; // in ml
  final bool notificationsEnabled;
  final int notificationInterval; // in minutes
  final DateTime startTime;
  final DateTime endTime;
  final String? email; // Firebase email
  final String? firebaseUid; // Firebase user ID

  UserProfileModel({
    required this.name,
    required this.age,
    required this.weight,
    required this.dailyGoal,
    this.notificationsEnabled = true,
    this.notificationInterval = 60,
    required this.startTime,
    required this.endTime,
    this.email,
    this.firebaseUid,
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
      'email': email,
      'firebaseUid': firebaseUid,
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
      email: map['email'],
      firebaseUid: map['firebaseUid'],
    );
  }
  
  // JSON serialization for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'weight': weight,
      'dailyGoal': dailyGoal,
      'notificationsEnabled': notificationsEnabled,
      'notificationInterval': notificationInterval,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'email': email,
      'firebaseUid': firebaseUid,
    };
  }
  
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      weight: json['weight']?.toDouble() ?? 0.0,
      dailyGoal: json['dailyGoal'] ?? 2000,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      notificationInterval: json['notificationInterval'] ?? 60,
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      email: json['email'],
      firebaseUid: json['firebaseUid'],
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
    String? email,
    String? firebaseUid,
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
      email: email ?? this.email,
      firebaseUid: firebaseUid ?? this.firebaseUid,
    );
  }

  // Calculate recommended daily water intake based on weight
  static int calculateRecommendedIntake(double weight) {
    // Basic formula: 35ml per kg of body weight
    return (weight * 35).round();
  }
}
