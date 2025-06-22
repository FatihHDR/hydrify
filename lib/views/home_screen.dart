import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/common_widgets.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hydrify'),
        backgroundColor: AppColors.waterBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<HomeViewModel>(context, listen: false).refreshData();
            },
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const LoadingWidget();
          }

          if (viewModel.userProfile == null) {
            return const EmptyStateWidget(
              title: 'Profile Setup Required',
              subtitle: 'Please complete your profile setup to start tracking your water intake.',
              icon: Icons.person_add,
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.refreshData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(viewModel),
                  const SizedBox(height: 20),
                  _buildProgressCard(viewModel),
                  const SizedBox(height: 20),
                  _buildQuickAddSection(viewModel),
                  const SizedBox(height: 20),
                  _buildMotivationalMessage(viewModel),
                  const SizedBox(height: 20),
                  _buildTodayIntakes(viewModel),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return FloatingActionButton(
            onPressed: () => _showAddWaterDialog(context, viewModel),
            backgroundColor: AppColors.waterBlue,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(HomeViewModel viewModel) {
    final profile = viewModel.userProfile!;
    final now = DateTime.now();
    String greeting = 'Good morning';
    
    if (now.hour >= 12 && now.hour < 17) {
      greeting = 'Good afternoon';
    } else if (now.hour >= 17) {
      greeting = 'Good evening';
    }

    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.waterBlueLight.withOpacity(0.1),
              AppColors.waterBlue.withOpacity(0.1),
            ],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, ${profile.name}!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s stay hydrated today!',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.waterBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.water_drop,
                color: AppColors.waterBlue,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(HomeViewModel viewModel) {
    return WaterProgressCard(
      currentAmount: viewModel.todayTotal,
      targetAmount: viewModel.userProfile!.dailyGoal,
      title: 'Today\'s Progress',
    );
  }

  Widget _buildQuickAddSection(HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Add',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.getQuickAddAmounts().length,
            itemBuilder: (context, index) {
              final amount = viewModel.getQuickAddAmounts()[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: QuickAddButton(
                  amount: amount,
                  onTap: () => viewModel.addWaterIntake(amount),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalMessage(HomeViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.successGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              viewModel.getMotivationalMessage(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayIntakes(HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Intake',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${viewModel.todayIntakes.length} entries',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (viewModel.todayIntakes.isEmpty)
          const EmptyStateWidget(
            title: 'No water intake today',
            subtitle: 'Start by adding your first glass of water!',
            icon: Icons.local_drink,
          )
        else
          Column(
            children: viewModel.todayIntakes.map((intake) {
              return WaterIntakeListItem(
                time: intake.timestamp,
                amount: intake.amount,
                onDelete: () => _showDeleteConfirmation(context, viewModel, intake),
                onEdit: () => _showEditWaterDialog(context, viewModel, intake),
              );
            }).toList(),
          ),
      ],
    );
  }

  Future<void> _showAddWaterDialog(BuildContext context, HomeViewModel viewModel) async {
    final TextEditingController controller = TextEditingController();
    int selectedAmount = 250;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Water Intake'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (ml)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final amount = int.tryParse(value);
                      if (amount != null) {
                        selectedAmount = amount;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Quick Select:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [200, 250, 300, 500, 750].map((amount) {
                      return ActionChip(
                        label: Text('${amount}ml'),
                        onPressed: () {
                          setState(() {
                            selectedAmount = amount;
                            controller.text = amount.toString();
                          });
                        },
                        backgroundColor: selectedAmount == amount 
                            ? AppColors.waterBlue 
                            : null,
                        labelStyle: TextStyle(
                          color: selectedAmount == amount 
                              ? Colors.white 
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final amount = int.tryParse(controller.text) ?? selectedAmount;
                    if (amount > 0) {
                      viewModel.addWaterIntake(amount);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditWaterDialog(BuildContext context, HomeViewModel viewModel, intake) async {
    final TextEditingController controller = TextEditingController(
      text: intake.amount.toString(),
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Water Intake'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (ml)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(controller.text);
                if (amount != null && amount > 0) {
                  final updatedIntake = intake.copyWith(amount: amount);
                  viewModel.updateWaterIntake(updatedIntake);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, HomeViewModel viewModel, intake) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: Text('Are you sure you want to delete this ${WaterCalculator.formatAmount(intake.amount)} entry?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                viewModel.removeWaterIntake(intake);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
