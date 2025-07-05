import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile_model.dart';
import '../models/water_intake_model.dart';
import '../models/achievement_model.dart';
import '../models/drink_type_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // User Profile Operations
  Future<void> saveUserProfile(UserProfileModel profile) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('profile')
          .doc('data')
          .set(profile.toJson());
    } catch (e) {
      throw Exception('Failed to save profile to Firestore: $e');
    }
  }

  Future<UserProfileModel?> getUserProfile() async {
    if (_userId == null) return null;
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('profile')
          .doc('data')
          .get();
          
      if (doc.exists) {
        return UserProfileModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching profile from Firestore: $e');
      return null;
    }
  }

  // Water Intake Operations
  Future<void> saveWaterIntake(WaterIntakeModel intake) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('water_intake')
          .doc(intake.id.toString())
          .set(intake.toJson());
    } catch (e) {
      throw Exception('Failed to save water intake to Firestore: $e');
    }
  }

  Future<void> updateWaterIntake(WaterIntakeModel intake) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('water_intake')
          .doc(intake.id.toString())
          .update(intake.toJson());
    } catch (e) {
      throw Exception('Failed to update water intake in Firestore: $e');
    }
  }

  Future<void> deleteWaterIntake(int intakeId) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('water_intake')
          .doc(intakeId.toString())
          .delete();
    } catch (e) {
      throw Exception('Failed to delete water intake from Firestore: $e');
    }
  }

  Future<List<WaterIntakeModel>> getWaterIntakes({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_userId == null) return [];
    
    try {
      Query query = _firestore
          .collection('users')
          .doc(_userId)
          .collection('water_intake');
          
      if (startDate != null && endDate != null) {
        query = query
            .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String().split('T')[0])
            .where('date', isLessThanOrEqualTo: endDate.toIso8601String().split('T')[0]);
      }
      
      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => WaterIntakeModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching water intakes from Firestore: $e');
      return [];
    }
  }

  // Achievement Operations
  Future<void> saveAchievement(Achievement achievement) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('achievements')
          .doc(achievement.id)
          .set(achievement.toJson());
    } catch (e) {
      throw Exception('Failed to save achievement to Firestore: $e');
    }
  }

  Future<List<Achievement>> getAchievements() async {
    if (_userId == null) return [];
    
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('achievements')
          .get();
          
      return querySnapshot.docs
          .map((doc) => Achievement.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching achievements from Firestore: $e');
      return [];
    }
  }

  // Drink Type Operations
  Future<void> saveDrinkType(DrinkTypeModel drinkType) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('drink_types')
          .doc(drinkType.id)
          .set(drinkType.toJson());
    } catch (e) {
      throw Exception('Failed to save drink type to Firestore: $e');
    }
  }

  Future<void> deleteDrinkType(String drinkTypeId) async {
    if (_userId == null) throw Exception('User not authenticated');
    
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('drink_types')
          .doc(drinkTypeId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete drink type from Firestore: $e');
    }
  }

  Future<List<DrinkTypeModel>> getDrinkTypes() async {
    if (_userId == null) return [];
    
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('drink_types')
          .get();
          
      return querySnapshot.docs
          .map((doc) => DrinkTypeModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching drink types from Firestore: $e');
      return [];
    }
  }

  // Sync Operations
  Future<void> syncDataToFirestore() async {
    if (_userId == null) return;
    
    try {
      // This would sync local SQLite data to Firestore
      // Implementation depends on your specific sync strategy
      print('Syncing data to Firestore...');
    } catch (e) {
      print('Error syncing data to Firestore: $e');
    }
  }

  Future<void> syncDataFromFirestore() async {
    if (_userId == null) return;
    
    try {
      // This would sync Firestore data to local SQLite
      // Implementation depends on your specific sync strategy
      print('Syncing data from Firestore...');
    } catch (e) {
      print('Error syncing data from Firestore: $e');
    }
  }

  // Real-time listeners
  Stream<UserProfileModel?> profileStream() {
    if (_userId == null) return Stream.value(null);
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('profile')
        .doc('data')
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return UserProfileModel.fromJson(doc.data()!);
          }
          return null;
        });
  }

  Stream<List<WaterIntakeModel>> waterIntakeStream() {
    if (_userId == null) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('water_intake')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => WaterIntakeModel.fromJson(doc.data()))
              .toList();
        });
  }
}
