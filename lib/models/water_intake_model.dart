class WaterIntakeModel {
  final int? id;
  final DateTime date;
  final int amount; // in ml
  final DateTime timestamp;

  WaterIntakeModel({
    this.id,
    required this.date,
    required this.amount,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WaterIntakeModel.fromMap(Map<String, dynamic> map) {
    return WaterIntakeModel(
      id: map['id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  WaterIntakeModel copyWith({
    int? id,
    DateTime? date,
    int? amount,
    DateTime? timestamp,
  }) {
    return WaterIntakeModel(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
