import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/drink_type_viewmodel.dart';
import '../models/drink_type_model.dart';
import '../widgets/drink_type_widgets.dart';
import '../widgets/gradient_background.dart';
import '../utils/app_theme.dart';

class DrinkTypeManagementScreen extends StatelessWidget {
  const DrinkTypeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DrinkTypeViewModel>(
      builder: (context, drinkTypeVM, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Manage Drink Types'),
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddDrinkTypeDialog(context),
                tooltip: 'Add Custom Drink Type',
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'reset':
                      _showResetConfirmation(context);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.restore, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Reset to Defaults'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: GradientBackground(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics card
                    Card(
                      color: Theme.of(context).cardColor.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.analytics,
                              color: AppColors.primary,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Drink Types Overview',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.titleLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildStatChip(
                                        'Total: ${drinkTypeVM.totalDrinkTypes}',
                                        AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStatChip(
                                        'Custom: ${drinkTypeVM.customDrinkTypes.length}',
                                        AppColors.accent,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Default drink types section
                    Text(
                      'Default Drink Types',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (drinkTypeVM.defaultDrinkTypes.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No default drink types available'),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: drinkTypeVM.defaultDrinkTypes.map((drinkType) => 
                          DrinkTypeInfoCard(
                            drinkType: drinkType,
                            isSelected: drinkTypeVM.selectedDrinkType?.id == drinkType.id,
                            onTap: () => drinkTypeVM.selectDrinkType(drinkType),
                          ),
                        ).toList(),
                      ),

                    const SizedBox(height: 24),

                    // Custom drink types section
                    Row(
                      children: [
                        Text(
                          'Custom Drink Types',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => _showAddDrinkTypeDialog(context),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    Expanded(
                      child: drinkTypeVM.customDrinkTypes.isEmpty
                          ? Card(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      size: 64,
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No Custom Drink Types',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap the "Add" button to create your own custom drink types',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () => _showAddDrinkTypeDialog(context),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add Custom Drink Type'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: drinkTypeVM.customDrinkTypes.length,
                              itemBuilder: (context, index) {
                                final drinkType = drinkTypeVM.customDrinkTypes[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  color: Theme.of(context).cardColor.withOpacity(0.9),
                                  child: ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: drinkType.color.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        drinkType.icon,
                                        color: drinkType.color,
                                        size: 24,
                                      ),
                                    ),
                                    title: Text(
                                      drinkType.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).textTheme.titleLarge?.color,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Water content: ${(drinkType.multiplier * 100).toInt()}%',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (drinkTypeVM.selectedDrinkType?.id == drinkType.id)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.success.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Selected',
                                              style: TextStyle(
                                                color: AppColors.success,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        IconButton(
                                          icon: Icon(Icons.edit, color: AppColors.primary),
                                          onPressed: () => _showEditDrinkTypeDialog(context, drinkType),
                                          tooltip: 'Edit',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _showDeleteConfirmation(context, drinkType),
                                          tooltip: 'Delete',
                                        ),
                                      ],
                                    ),
                                    onTap: () => drinkTypeVM.selectDrinkType(drinkType),
                                  ),
                                );
                              },
                            ),
                    ),

                    // Error display
                    if (drinkTypeVM.error != null)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                drinkTypeVM.error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: drinkTypeVM.clearError,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${drinkType.name}"?'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final drinkTypeVM = Provider.of<DrinkTypeViewModel>(context, listen: false);
              final success = await drinkTypeVM.deleteDrinkType(drinkType.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Drink type deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will delete all custom drink types and keep only the default ones.'),
            SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final drinkTypeVM = Provider.of<DrinkTypeViewModel>(context, listen: false);
              await drinkTypeVM.resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reset to defaults completed'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class DrinkTypeInfoCard extends StatelessWidget {
  final DrinkTypeModel drinkType;
  final bool isSelected;
  final VoidCallback? onTap;

  const DrinkTypeInfoCard({
    super.key,
    required this.drinkType,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? drinkType.color.withOpacity(0.2) : Theme.of(context).cardColor.withOpacity(0.9),
          border: Border.all(
            color: isSelected ? drinkType.color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(
              color: drinkType.color.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: drinkType.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                drinkType.icon,
                color: drinkType.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              drinkType.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? drinkType.color : Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            Text(
              '${(drinkType.multiplier * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? drinkType.color.withOpacity(0.8) : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
