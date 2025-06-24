import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/achievement_viewmodel.dart';
import '../viewmodels/drink_type_viewmodel.dart';
import '../widgets/common_widgets.dart';
import '../widgets/advanced_widgets.dart';
import '../widgets/gradient_background.dart';
import '../widgets/water_intake_widgets.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(context, listen: false).initialize();
      Provider.of<AchievementViewModel>(context, listen: false).initialize();
      Provider.of<DrinkTypeViewModel>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,        appBar: AppBar(
        title: const Text('Hydrify'),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
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
          }          return RefreshIndicator(
            onRefresh: viewModel.refreshData,
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // Extra padding for FAB
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(viewModel),
                      const SizedBox(height: 20),
                      _buildProgressCard(viewModel),
                      const SizedBox(height: 20),
                      _buildAchievementSummary(viewModel),
                      const SizedBox(height: 20),
                      _buildQuickAddSection(viewModel),
                      const SizedBox(height: 20),
                      _buildMotivationalMessage(viewModel),
                      const SizedBox(height: 20),
                      _buildTodayIntakes(viewModel),
                    ],
                  ),
                ),
                // Positioned add water button above bottom navigation
                Positioned(
                  bottom: 110, // Position above bottom nav (nav is at bottom: 20, height ~70)
                  right: 20,
                  child: QuickAddWaterButton(
                    onAdd: (amount, drinkType) async {
                      final homeVM = Provider.of<HomeViewModel>(context, listen: false);
                      await homeVM.addWaterIntake(amount, drinkType: drinkType);
                    },
                  ),
                ),
              ],
            ),
          );        },
      ),
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
    }    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),            child: Container(
              padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              // ignore: deprecated_member_use
              AppColors.waterBlueLight.withOpacity(0.15),
              // ignore: deprecated_member_use
              AppColors.waterBlue.withOpacity(0.08),
            ],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [                  Text(
                    '$greeting, ${profile.name}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.waterBlueDark,
                      letterSpacing: -0.5,
                    ),
                  ),                  const SizedBox(height: 8),
                  Text(
                    'Let\'s stay hydrated today!',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.getTextSecondary(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColors.waterBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  // ignore: deprecated_member_use
                  color: AppColors.waterBlue.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.water_drop,
                color: AppColors.waterBlue,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildProgressCard(HomeViewModel viewModel) {
    final progress = viewModel.userProfile!.dailyGoal > 0 
        ? (viewModel.todayTotal / viewModel.userProfile!.dailyGoal).clamp(0.0, 1.0) 
        : 0.0;
    final percentage = (progress * 100).round();    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [              // Wave effect now spans full card width with high visibility
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),              child: ProgressWaveEffect(
                progress: progress,
                width: double.infinity,
                height: double.infinity,
                waveColor: Colors.blue, // Bright blue for testing
                backgroundColor: Colors.transparent,
              ),
            ),          ),
          // Main content
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.waterBlue.withOpacity(0.8), // Semi-transparent solid color instead of gradient
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LocalizedText(
                  'todays_progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // 3D Bottle Visualization
                    Bottle3DVisualization(
                      fillPercentage: progress,
                      width: 80,
                      height: 120,
                      bottleColor: Colors.white.withOpacity(0.7),
                      waterColor: Colors.white,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${(viewModel.todayTotal / 1000).toStringAsFixed(1)}L / ${(viewModel.userProfile!.dailyGoal / 1000).toStringAsFixed(1)}L',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$percentage% completed',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),                          // Simple progress bar
                          Container(
                            width: 150,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddSection(HomeViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [        LocalizedText(
          'quick_add',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 12),        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.getQuickAddAmounts().length,
            itemBuilder: (context, index) {
              final amount = viewModel.getQuickAddAmounts()[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: AccessibleWaterButton(
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
          children: [            Text(
              'Today\'s Intake',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.getTextPrimary(context),
              ),
            ),
            Text(
              '${viewModel.todayIntakes.length} entries',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextSecondary(context),
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
          Builder(
            builder: (context) => Column(
              children: viewModel.todayIntakes.map((intake) {
                return WaterIntakeListItem(
                  time: intake.timestamp,
                  amount: intake.amount,
                  onDelete: () => _showDeleteConfirmation(context, viewModel, intake),
                  onEdit: () => _showEditWaterDialog(context, viewModel, intake),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildAchievementSummary(HomeViewModel viewModel) {
    return Consumer<AchievementViewModel>(
      builder: (context, achievementViewModel, child) {
        final totalUnlocked = achievementViewModel.totalUnlocked;
        final totalAchievements = achievementViewModel.totalAchievements;
        
        if (totalAchievements == 0) return const SizedBox.shrink();
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.waterBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: AppColors.waterBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,                    children: [
                      const Text(
                        'Achievements',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.waterBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalUnlocked of $totalAchievements unlocked',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.waterBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(achievementViewModel.completionPercentage * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );      },
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
