import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/water_intake_model.dart';
import '../models/user_profile_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'hydrify.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE water_intake (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        amount INTEGER NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        weight REAL NOT NULL,
        dailyGoal INTEGER NOT NULL,
        notificationsEnabled INTEGER NOT NULL,
        notificationInterval INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL
      )
    ''');
  }

  // Water Intake CRUD operations
  Future<int> insertWaterIntake(WaterIntakeModel intake) async {
    final db = await database;
    return await db.insert('water_intake', intake.toMap());
  }

  Future<List<WaterIntakeModel>> getWaterIntakeByDate(DateTime date) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'water_intake',
      where: 'date LIKE ?',
      whereArgs: ['$dateString%'],
      orderBy: 'timestamp ASC',
    );

    return maps.map((map) => WaterIntakeModel.fromMap(map)).toList();
  }

  Future<List<WaterIntakeModel>> getWaterIntakeHistory(int days) async {
    final db = await database;
    final startDate = DateTime.now().subtract(Duration(days: days));
    final List<Map<String, dynamic>> maps = await db.query(
      'water_intake',
      where: 'timestamp >= ?',
      whereArgs: [startDate.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => WaterIntakeModel.fromMap(map)).toList();
  }

  Future<int> updateWaterIntake(WaterIntakeModel intake) async {
    final db = await database;
    return await db.update(
      'water_intake',
      intake.toMap(),
      where: 'id = ?',
      whereArgs: [intake.id],
    );
  }

  Future<int> deleteWaterIntake(int id) async {
    final db = await database;
    return await db.delete(
      'water_intake',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // User Profile CRUD operations
  Future<int> insertOrUpdateUserProfile(UserProfileModel profile) async {
    final db = await database;
    return await db.insert(
      'user_profile',
      {...profile.toMap(), 'id': 1},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfileModel?> getUserProfile() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps.isNotEmpty) {
      return UserProfileModel.fromMap(maps.first);
    }
    return null;
  }

  Future<Map<String, int>> getDailyIntakeStats(DateTime date) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        COALESCE(SUM(amount), 0) as totalAmount,
        COUNT(*) as totalEntries
      FROM water_intake 
      WHERE date LIKE ?
    ''', ['$dateString%']);

    return {
      'totalAmount': result.first['totalAmount'] ?? 0,
      'totalEntries': result.first['totalEntries'] ?? 0,
    };
  }

  Future<List<Map<String, dynamic>>> getWeeklyStats() async {
    final db = await database;
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        DATE(timestamp) as date,
        SUM(amount) as totalAmount
      FROM water_intake 
      WHERE timestamp >= ?
      GROUP BY DATE(timestamp)
      ORDER BY date ASC
    ''', [sevenDaysAgo.toIso8601String()]);

    return result;
  }
}
