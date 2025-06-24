import 'package:flutter/material.dart';
import '../models/drink_type_model.dart';
import '../services/drink_type_service.dart';

class DrinkTypeViewModel extends ChangeNotifier {
  final DrinkTypeService _drinkTypeService = DrinkTypeService();
  
  List<DrinkTypeModel> _drinkTypes = [];
  List<DrinkTypeModel> _defaultDrinkTypes = [];
  List<DrinkTypeModel> _customDrinkTypes = [];
  DrinkTypeModel? _selectedDrinkType;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<DrinkTypeModel> get drinkTypes => _drinkTypes;
  List<DrinkTypeModel> get defaultDrinkTypes => _defaultDrinkTypes;
  List<DrinkTypeModel> get customDrinkTypes => _customDrinkTypes;
  DrinkTypeModel? get selectedDrinkType => _selectedDrinkType;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCustomDrinkTypes => _customDrinkTypes.isNotEmpty;
  int get totalDrinkTypes => _drinkTypes.length;

  // Initialize the service and load data
  Future<void> initialize() async {
    await _drinkTypeService.initialize();
    await loadDrinkTypes();
    
    // Set default selected drink type to water if none selected
    if (_selectedDrinkType == null && _drinkTypes.isNotEmpty) {
      _selectedDrinkType = _drinkTypes.firstWhere(
        (dt) => dt.id == 'water',
        orElse: () => _drinkTypes.first,
      );
      notifyListeners();
    }
  }

  // Load all drink types
  Future<void> loadDrinkTypes() async {
    _setLoading(true);
    _setError(null);

    try {
      _drinkTypes = await _drinkTypeService.getAllDrinkTypes();
      _defaultDrinkTypes = await _drinkTypeService.getDefaultDrinkTypes();
      _customDrinkTypes = await _drinkTypeService.getCustomDrinkTypes();
    } catch (e) {
      _setError('Failed to load drink types: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add new custom drink type
  Future<bool> addCustomDrinkType({
    required String name,
    required IconData icon,
    required Color color,
    required double multiplier,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Check if name already exists
      final nameExists = await _drinkTypeService.isDrinkTypeNameExists(name);
      if (nameExists) {
        _setError('Drink type with this name already exists');
        return false;
      }

      final drinkType = DrinkTypeModel(
        id: _drinkTypeService.generateDrinkTypeId(),
        name: name.trim(),
        icon: icon,
        color: color,
        multiplier: multiplier,
        isDefault: false,
        createdAt: DateTime.now(),
      );

      final success = await _drinkTypeService.addDrinkType(drinkType);
      if (success) {
        await loadDrinkTypes();
        return true;
      } else {
        _setError('Failed to add drink type');
        return false;
      }
    } catch (e) {
      _setError('Error adding drink type: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update existing drink type
  Future<bool> updateDrinkType({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
    required double multiplier,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Check if name already exists (excluding current drink type)
      final nameExists = await _drinkTypeService.isDrinkTypeNameExists(name, excludeId: id);
      if (nameExists) {
        _setError('Drink type with this name already exists');
        return false;
      }

      final existingDrinkType = await _drinkTypeService.getDrinkTypeById(id);
      if (existingDrinkType == null) {
        _setError('Drink type not found');
        return false;
      }

      final updatedDrinkType = existingDrinkType.copyWith(
        name: name.trim(),
        icon: icon,
        color: color,
        multiplier: multiplier,
      );

      final success = await _drinkTypeService.updateDrinkType(updatedDrinkType);
      if (success) {
        await loadDrinkTypes();
        
        // Update selected drink type if it was the one being updated
        if (_selectedDrinkType?.id == id) {
          _selectedDrinkType = updatedDrinkType;
          notifyListeners();
        }
        
        return true;
      } else {
        _setError('Failed to update drink type');
        return false;
      }
    } catch (e) {
      _setError('Error updating drink type: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete custom drink type
  Future<bool> deleteDrinkType(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final drinkType = await _drinkTypeService.getDrinkTypeById(id);
      if (drinkType == null) {
        _setError('Drink type not found');
        return false;
      }

      if (drinkType.isDefault) {
        _setError('Cannot delete default drink types');
        return false;
      }

      final success = await _drinkTypeService.deleteDrinkType(id);
      if (success) {
        await loadDrinkTypes();
          // If deleted drink type was selected, select water as default
        if (_selectedDrinkType?.id == id) {
          if (_drinkTypes.isNotEmpty) {
            _selectedDrinkType = _drinkTypes.firstWhere(
              (dt) => dt.id == 'water',
              orElse: () => _drinkTypes.first,
            );
          } else {
            _selectedDrinkType = null;
          }
          notifyListeners();
        }
        
        return true;
      } else {
        _setError('Failed to delete drink type');
        return false;
      }
    } catch (e) {
      _setError('Error deleting drink type: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Select drink type
  void selectDrinkType(DrinkTypeModel drinkType) {
    _selectedDrinkType = drinkType;
    notifyListeners();
  }

  // Get drink type by ID
  DrinkTypeModel? getDrinkTypeById(String id) {
    try {
      return _drinkTypes.firstWhere((dt) => dt.id == id);
    } catch (e) {
      return null;
    }
  }

  // Calculate effective water amount based on drink type multiplier
  double calculateEffectiveWaterAmount(double amount, String? drinkTypeId) {
    if (drinkTypeId == null) return amount;
    
    final drinkType = getDrinkTypeById(drinkTypeId);
    if (drinkType == null) return amount;
    
    return amount * drinkType.multiplier;
  }

  // Clear error
  void clearError() {
    _setError(null);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Reset to defaults (for testing/debugging)
  Future<void> resetToDefaults() async {
    _setLoading(true);
    try {
      // Delete all custom drink types
      for (final drinkType in _customDrinkTypes) {
        await _drinkTypeService.deleteDrinkType(drinkType.id);
      }
      await loadDrinkTypes();
    } catch (e) {
      _setError('Error resetting to defaults: $e');
    } finally {
      _setLoading(false);
    }
  }
}
