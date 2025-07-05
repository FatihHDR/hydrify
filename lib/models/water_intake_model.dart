class WaterIntakeModel {
  final int? id;
  final DateTime date;
  final int amount; // in ml
  final DateTime timestamp;
  final String? drinkTypeId; // Reference to drink type
  final int? effectiveAmount; // Actual water content after applying multiplier

  WaterIntakeModel({
    this.id,
    required this.date,
    required this.amount,
    required this.timestamp,
    this.drinkTypeId,
    this.effectiveAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'drinkTypeId': drinkTypeId,
      'effectiveAmount': effectiveAmount,
    };
  }

  factory WaterIntakeModel.fromMap(Map<String, dynamic> map) {
    return WaterIntakeModel(
      id: map['id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      timestamp: DateTime.parse(map['timestamp']),
      drinkTypeId: map['drinkTypeId'],
      effectiveAmount: map['effectiveAmount'],
    );
  }
  
  // JSON serialization for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0], // Store date as YYYY-MM-DD
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'drinkTypeId': drinkTypeId,
      'effectiveAmount': effectiveAmount,
    };
  }
  
  factory WaterIntakeModel.fromJson(Map<String, dynamic> json) {
    return WaterIntakeModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      amount: json['amount'],
      timestamp: DateTime.parse(json['timestamp']),
      drinkTypeId: json['drinkTypeId'],
      effectiveAmount: json['effectiveAmount'],
    );
  }

  WaterIntakeModel copyWith({
    int? id,
    DateTime? date,
    int? amount,
    DateTime? timestamp,
    String? drinkTypeId,
    int? effectiveAmount,
  }) {
    return WaterIntakeModel(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      drinkTypeId: drinkTypeId ?? this.drinkTypeId,
      effectiveAmount: effectiveAmount ?? this.effectiveAmount,
    );
  }
}
