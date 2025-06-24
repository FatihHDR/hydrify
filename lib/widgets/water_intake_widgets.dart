import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/drink_type_model.dart';
import '../viewmodels/drink_type_viewmodel.dart';
import '../widgets/drink_type_widgets.dart';
import '../utils/app_theme.dart';

class AddWaterIntakeDialog extends StatefulWidget {
  final Function(int amount, DrinkTypeModel? drinkType)? onAdd;

  const AddWaterIntakeDialog({super.key, this.onAdd});

  @override
  State<AddWaterIntakeDialog> createState() => _AddWaterIntakeDialogState();
}

class _AddWaterIntakeDialogState extends State<AddWaterIntakeDialog> {
  final _amountController = TextEditingController();
  DrinkTypeModel? _selectedDrinkType;
  bool _isLoading = false;

  final List<int> _quickAmounts = [100, 150, 200, 250, 300, 350, 400, 500];

  @override
  void initState() {
    super.initState();
    _amountController.text = '250'; // Default amount
    
    // Initialize drink type service and select default
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final drinkTypeVM = Provider.of<DrinkTypeViewModel>(context, listen: false);
      if (drinkTypeVM.drinkTypes.isEmpty) {
        await drinkTypeVM.initialize();
      }
      if (drinkTypeVM.selectedDrinkType != null) {
        setState(() {
          _selectedDrinkType = drinkTypeVM.selectedDrinkType;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.add_circle, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text('Add Water Intake'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount input
            const Text(
              'Amount (ml)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter amount in ml',
                suffixText: 'ml',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick amount buttons
            const Text(
              'Quick Select',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((amount) => 
                GestureDetector(
                  onTap: () {
                    _amountController.text = amount.toString();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _amountController.text == amount.toString() 
                          ? AppColors.primary 
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${amount}ml',
                      style: TextStyle(
                        color: _amountController.text == amount.toString() 
                            ? Colors.white 
                            : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Drink type selector
            Consumer<DrinkTypeViewModel>(
              builder: (context, drinkTypeVM, child) {
                if (drinkTypeVM.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                return DrinkTypeSelector(
                  showAddButton: false,
                  isCompact: true,
                  onDrinkTypeSelected: (drinkType) {
                    setState(() {
                      _selectedDrinkType = drinkType;
                    });
                  },
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Water content info
            if (_selectedDrinkType != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedDrinkType!.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _selectedDrinkType!.color.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: _selectedDrinkType!.color,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Water Content Info',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedDrinkType!.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selected: ${_selectedDrinkType!.name}',
                      style: TextStyle(color: _selectedDrinkType!.color),
                    ),
                    Text(
                      'Water content: ${(_selectedDrinkType!.multiplier * 100).toInt()}%',
                      style: TextStyle(color: _selectedDrinkType!.color),
                    ),
                    if (_selectedDrinkType!.multiplier != 1.0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Effective water: ${_calculateEffectiveAmount()}ml',
                        style: TextStyle(
                          color: _selectedDrinkType!.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addWaterIntake,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Add'),
        ),
      ],
    );
  }

  int _calculateEffectiveAmount() {
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (_selectedDrinkType == null) return amount;
    return (amount * _selectedDrinkType!.multiplier).round();
  }

  Future<void> _addWaterIntake() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (amount > 2000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Amount seems too large. Please check.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call the callback with the amount and selected drink type
      widget.onAdd?.call(amount, _selectedDrinkType);
      
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedDrinkType != null 
                ? 'Added ${amount}ml of ${_selectedDrinkType!.name}'
                : 'Added ${amount}ml of water'
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding water intake: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class QuickAddWaterButton extends StatelessWidget {
  final Function(int amount, DrinkTypeModel? drinkType)? onAdd;
  final String? tooltip;

  const QuickAddWaterButton({
    super.key,
    this.onAdd,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AddWaterIntakeDialog(onAdd: onAdd),
        );
      },
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      tooltip: tooltip ?? 'Add Water Intake',
      child: const Icon(Icons.add),
    );
  }
}

class DrinkTypeQuickSelector extends StatelessWidget {
  final Function(DrinkTypeModel)? onDrinkTypeSelected;
  final int maxItems;

  const DrinkTypeQuickSelector({
    super.key,
    this.onDrinkTypeSelected,
    this.maxItems = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DrinkTypeViewModel>(
      builder: (context, drinkTypeVM, child) {
        if (drinkTypeVM.isLoading) {
          return const SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final displayTypes = drinkTypeVM.drinkTypes.take(maxItems).toList();

        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayTypes.length,
            itemBuilder: (context, index) {
              final drinkType = displayTypes[index];
              final isSelected = drinkTypeVM.selectedDrinkType?.id == drinkType.id;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    drinkTypeVM.selectDrinkType(drinkType);
                    onDrinkTypeSelected?.call(drinkType);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? drinkType.color : Colors.transparent,
                      border: Border.all(
                        color: drinkType.color,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          drinkType.icon,
                          size: 20,
                          color: isSelected ? Colors.white : drinkType.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          drinkType.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : drinkType.color,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
