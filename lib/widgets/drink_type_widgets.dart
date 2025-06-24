import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drink_type_model.dart';
import '../viewmodels/drink_type_viewmodel.dart';
import '../utils/app_theme.dart';

class DrinkTypeSelector extends StatelessWidget {
  final Function(DrinkTypeModel)? onDrinkTypeSelected;
  final bool showAddButton;
  final bool isCompact;

  const DrinkTypeSelector({
    super.key,
    this.onDrinkTypeSelected,
    this.showAddButton = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DrinkTypeViewModel>(
      builder: (context, drinkTypeVM, child) {
        if (drinkTypeVM.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCompact) ...[
              Text(
                'Select Drink Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Default drink types
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...drinkTypeVM.defaultDrinkTypes.map((drinkType) => 
                  DrinkTypeChip(
                    drinkType: drinkType,
                    isSelected: drinkTypeVM.selectedDrinkType?.id == drinkType.id,
                    onTap: () {
                      drinkTypeVM.selectDrinkType(drinkType);
                      onDrinkTypeSelected?.call(drinkType);
                    },
                  ),
                ),
                
                // Custom drink types
                ...drinkTypeVM.customDrinkTypes.map((drinkType) => 
                  DrinkTypeChip(
                    drinkType: drinkType,
                    isSelected: drinkTypeVM.selectedDrinkType?.id == drinkType.id,
                    isCustom: true,
                    onTap: () {
                      drinkTypeVM.selectDrinkType(drinkType);
                      onDrinkTypeSelected?.call(drinkType);
                    },
                    onEdit: () => _showEditDrinkTypeDialog(context, drinkType),
                    onDelete: () => _showDeleteConfirmation(context, drinkType),
                  ),
                ),
                
                // Add custom drink type button
                if (showAddButton)
                  GestureDetector(
                    onTap: () => _showAddDrinkTypeDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.5),
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.transparent,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Add Custom',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            
            if (drinkTypeVM.error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        drinkTypeVM.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: drinkTypeVM.clearError,
                      color: Colors.red,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _showAddDrinkTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddEditDrinkTypeDialog(),
    );
  }

  void _showEditDrinkTypeDialog(BuildContext context, DrinkTypeModel drinkType) {
    showDialog(
      context: context,
      builder: (context) => AddEditDrinkTypeDialog(drinkType: drinkType),
    );
  }

  void _showDeleteConfirmation(BuildContext context, DrinkTypeModel drinkType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Drink Type'),
        content: Text('Are you sure you want to delete "${drinkType.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final drinkTypeVM = Provider.of<DrinkTypeViewModel>(context, listen: false);
              await drinkTypeVM.deleteDrinkType(drinkType.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class DrinkTypeChip extends StatelessWidget {
  final DrinkTypeModel drinkType;
  final bool isSelected;
  final bool isCustom;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DrinkTypeChip({
    super.key,
    required this.drinkType,
    this.isSelected = false,
    this.isCustom = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: isCustom ? () => _showCustomOptions(context) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? drinkType.color : Colors.transparent,
          border: Border.all(
            color: isSelected ? drinkType.color : drinkType.color.withOpacity(0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [
            BoxShadow(
              color: drinkType.color.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              drinkType.icon,
              size: 18,
              color: isSelected ? Colors.white : drinkType.color,
            ),
            const SizedBox(width: 6),
            Text(
              drinkType.name,
              style: TextStyle(
                color: isSelected ? Colors.white : drinkType.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (drinkType.multiplier != 1.0) ...[
              const SizedBox(width: 4),
              Text(
                '${(drinkType.multiplier * 100).toInt()}%',
                style: TextStyle(
                  color: isSelected ? Colors.white70 : drinkType.color.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
            if (isCustom) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.edit,
                size: 14,
                color: isSelected ? Colors.white70 : drinkType.color.withOpacity(0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCustomOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              drinkType.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                onEdit?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AddEditDrinkTypeDialog extends StatefulWidget {
  final DrinkTypeModel? drinkType;

  const AddEditDrinkTypeDialog({super.key, this.drinkType});

  @override
  State<AddEditDrinkTypeDialog> createState() => _AddEditDrinkTypeDialogState();
}

class _AddEditDrinkTypeDialogState extends State<AddEditDrinkTypeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _multiplierController = TextEditingController();
  
  IconData _selectedIcon = Icons.local_drink;
  Color _selectedColor = const Color(0xFF2196F3);
  bool _isLoading = false;

  final List<IconData> _availableIcons = [
    Icons.local_drink,
    Icons.coffee,
    Icons.emoji_food_beverage,
    Icons.wine_bar,
    Icons.local_bar,
    Icons.liquor,
    Icons.sports_bar,
    Icons.free_breakfast,
    Icons.nightlife,
    Icons.local_cafe,
    Icons.restaurant,
    Icons.fastfood,
  ];

  final List<Color> _availableColors = [
    const Color(0xFF2196F3), // Blue
    const Color(0xFF795548), // Brown
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF9800), // Orange
    const Color(0xFFE91E63), // Pink
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFF44336), // Red
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFF3F51B5), // Indigo
    const Color(0xFF009688), // Teal
    const Color(0xFF8BC34A), // Light Green
    const Color(0xFFFFEB3B), // Yellow
  ];

  @override
  void initState() {
    super.initState();
    if (widget.drinkType != null) {
      _nameController.text = widget.drinkType!.name;
      _multiplierController.text = (widget.drinkType!.multiplier * 100).toInt().toString();
      _selectedIcon = widget.drinkType!.icon;
      _selectedColor = widget.drinkType!.color;
    } else {
      _multiplierController.text = '100';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _multiplierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.drinkType != null ? 'Edit Drink Type' : 'Add Drink Type'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter drink type name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Water content percentage
              TextFormField(
                controller: _multiplierController,
                decoration: const InputDecoration(
                  labelText: 'Water Content (%)',
                  hintText: 'Enter water content percentage',
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter water content percentage';
                  }
                  final percentage = int.tryParse(value.trim());
                  if (percentage == null || percentage < 1 || percentage > 100) {
                    return 'Please enter a valid percentage (1-100)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Icon selection
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Select Icon:', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableIcons.map((icon) => 
                  GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedIcon == icon ? _selectedColor : Colors.transparent,
                        border: Border.all(
                          color: _selectedIcon == icon ? _selectedColor : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: _selectedIcon == icon ? Colors.white : Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ).toList(),
              ),

              const SizedBox(height: 20),

              // Color selection
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Select Color:', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableColors.map((color) => 
                  GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == color ? 
                          Border.all(color: Colors.black, width: 3) : 
                          Border.all(color: Colors.grey, width: 1),
                      ),
                      child: _selectedColor == color ? 
                        const Icon(Icons.check, color: Colors.white, size: 16) : 
                        null,
                    ),
                  ),
                ).toList(),
              ),

              const SizedBox(height: 16),

              // Preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Text('Preview: '),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_selectedIcon, size: 18, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            _nameController.text.isNotEmpty ? _nameController.text : 'Custom Drink',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveDrinkType,
          child: _isLoading ? 
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ) :
            Text(widget.drinkType != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Future<void> _saveDrinkType() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final drinkTypeVM = Provider.of<DrinkTypeViewModel>(context, listen: false);
      final name = _nameController.text.trim();
      final multiplier = int.parse(_multiplierController.text.trim()) / 100.0;

      bool success;
      if (widget.drinkType != null) {
        // Update existing drink type
        success = await drinkTypeVM.updateDrinkType(
          id: widget.drinkType!.id,
          name: name,
          icon: _selectedIcon,
          color: _selectedColor,
          multiplier: multiplier,
        );
      } else {
        // Add new drink type
        success = await drinkTypeVM.addCustomDrinkType(
          name: name,
          icon: _selectedIcon,
          color: _selectedColor,
          multiplier: multiplier,
        );
      }

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.drinkType != null ? 
                'Drink type updated successfully' : 
                'Drink type added successfully'
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        // Error is handled by the view model and shown in the UI
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
