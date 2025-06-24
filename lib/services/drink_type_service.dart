import 'package:sqflite/sqflite.dart';
import '../models/drink_type_model.dart';
import 'database_service.dart';

class DrinkTypeService {
  static const String tableName = 'drink_types';
  final DatabaseService _databaseService = DatabaseService();

  // Initialize the drink types table and default data
  Future<void> initialize() async {
    final db = await _databaseService.database;
    
    // Create table if not exists
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon INTEGER NOT NULL,
        color INTEGER NOT NULL,
        multiplier REAL NOT NULL DEFAULT 1.0,
        isDefault INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER
      )
    ''');

    // Check if default drink types exist
    final count = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName WHERE isDefault = 1');
    final defaultCount = count.first['count'] as int;

    // Insert default drink types if they don't exist
    if (defaultCount == 0) {
      await _insertDefaultDrinkTypes();
    }
  }

  // Insert default drink types
  Future<void> _insertDefaultDrinkTypes() async {
    final defaultDrinkTypes = DrinkTypeModel.getDefaultDrinkTypes();
    for (final drinkType in defaultDrinkTypes) {
      await addDrinkType(drinkType);
    }
  }

  // Add a new drink type
  Future<bool> addDrinkType(DrinkTypeModel drinkType) async {
    try {
      final db = await _databaseService.database;
      await db.insert(
        tableName,
        drinkType.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print('Error adding drink type: $e');
      return false;
    }
  }

  // Get all drink types
  Future<List<DrinkTypeModel>> getAllDrinkTypes() async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        orderBy: 'isDefault DESC, name ASC',
      );

      return List.generate(maps.length, (i) {
        return DrinkTypeModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting drink types: $e');
      return [];
    }
  }

  // Get default drink types
  Future<List<DrinkTypeModel>> getDefaultDrinkTypes() async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'isDefault = ?',
        whereArgs: [1],
        orderBy: 'name ASC',
      );

      return List.generate(maps.length, (i) {
        return DrinkTypeModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting default drink types: $e');
      return [];
    }
  }

  // Get custom drink types
  Future<List<DrinkTypeModel>> getCustomDrinkTypes() async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'isDefault = ?',
        whereArgs: [0],
        orderBy: 'createdAt DESC',
      );

      return List.generate(maps.length, (i) {
        return DrinkTypeModel.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error getting custom drink types: $e');
      return [];
    }
  }

  // Get drink type by ID
  Future<DrinkTypeModel?> getDrinkTypeById(String id) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return DrinkTypeModel.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting drink type by ID: $e');
      return null;
    }
  }

  // Update drink type
  Future<bool> updateDrinkType(DrinkTypeModel drinkType) async {
    try {
      final db = await _databaseService.database;
      final result = await db.update(
        tableName,
        drinkType.toMap(),
        where: 'id = ?',
        whereArgs: [drinkType.id],
      );
      return result > 0;
    } catch (e) {
      print('Error updating drink type: $e');
      return false;
    }
  }

  // Delete drink type (only custom ones)
  Future<bool> deleteDrinkType(String id) async {
    try {
      final db = await _databaseService.database;
      final result = await db.delete(
        tableName,
        where: 'id = ? AND isDefault = ?',
        whereArgs: [id, 0], // Only delete custom drink types
      );
      return result > 0;
    } catch (e) {
      print('Error deleting drink type: $e');
      return false;
    }
  }

  // Check if drink type name already exists
  Future<bool> isDrinkTypeNameExists(String name, {String? excludeId}) async {
    try {
      final db = await _databaseService.database;
      String whereClause = 'LOWER(name) = ?';
      List<dynamic> whereArgs = [name.toLowerCase()];

      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }

      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        where: whereClause,
        whereArgs: whereArgs,
        limit: 1,
      );

      return maps.isNotEmpty;
    } catch (e) {
      print('Error checking drink type name: $e');
      return false;
    }
  }

  // Generate unique ID for new drink type
  String generateDrinkTypeId() {
    return 'custom_${DateTime.now().millisecondsSinceEpoch}';
  }
}
