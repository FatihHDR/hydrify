import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/achievement_viewmodel.dart';
import '../models/achievement_model.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AchievementViewModel>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: AppColors.waterBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unlocked'),
            Tab(text: 'Locked'),
          ],
        ),
      ),
      body: Consumer<AchievementViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const LoadingWidget(message: 'Loading achievements...');
          }

          return Column(
            children: [
              _buildProgressHeader(viewModel),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllAchievements(viewModel),
                    _buildUnlockedAchievements(viewModel),
                    _buildLockedAchievements(viewModel),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressHeader(AchievementViewModel viewModel) {
    final percentage = viewModel.completionPercentage;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${viewModel.totalUnlocked}/${viewModel.totalAchievements}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '${(percentage * 100).toInt()}% Complete',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllAchievements(AchievementViewModel viewModel) {
    final grouped = _groupAchievementsByType(viewModel.achievements);
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final type = grouped.keys.elementAt(index);
        final achievements = grouped[type]!;
        
        return _buildAchievementSection(
          title: _getTypeTitle(type),
          achievements: achievements,
        );
      },
    );
  }

  Widget _buildUnlockedAchievements(AchievementViewModel viewModel) {
    if (viewModel.unlockedAchievements.isEmpty) {
      return const EmptyStateWidget(
        title: 'No Achievements Yet',
        subtitle: 'Keep drinking water to unlock your first achievement!',
        icon: Icons.emoji_events,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.unlockedAchievements.length,
      itemBuilder: (context, index) {
        final achievement = viewModel.unlockedAchievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildLockedAchievements(AchievementViewModel viewModel) {
    if (viewModel.lockedAchievements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_open,
              size: 80,
              color: AppColors.success,
            ),
            SizedBox(height: 16),
            Text(
              'All Achievements Unlocked!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Congratulations on your hydration mastery!',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.lockedAchievements.length,
      itemBuilder: (context, index) {
        final achievement = viewModel.lockedAchievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  Widget _buildAchievementSection({
    required String title,
    required List<Achievement> achievements,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        ...achievements.map((achievement) => _buildAchievementCard(achievement)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: achievement.isUnlocked ? 4 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: achievement.isUnlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      achievement.color.withOpacity(0.1),
                      achievement.color.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? achievement.color.withOpacity(0.2)
                      : AppColors.textLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  achievement.icon,
                  size: 28,
                  color: achievement.isUnlocked
                      ? achievement.color
                      : AppColors.textLight,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: achievement.isUnlocked
                                  ? AppColors.textPrimary
                                  : AppColors.textLight,
                            ),
                          ),
                        ),
                        if (achievement.isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Unlocked',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: achievement.isUnlocked
                            ? AppColors.textSecondary
                            : AppColors.textLight,
                      ),
                    ),
                    if (achievement.isUnlocked && achievement.unlockedDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Unlocked on ${_formatDate(achievement.unlockedDate!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: achievement.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<AchievementType, List<Achievement>> _groupAchievementsByType(List<Achievement> achievements) {
    final Map<AchievementType, List<Achievement>> grouped = {};
    
    for (final achievement in achievements) {
      if (!grouped.containsKey(achievement.type)) {
        grouped[achievement.type] = [];
      }
      grouped[achievement.type]!.add(achievement);
    }
    
    return grouped;
  }

  String _getTypeTitle(AchievementType type) {
    switch (type) {
      case AchievementType.streak:
        return 'Streak Achievements';
      case AchievementType.totalIntake:
        return 'Total Intake';
      case AchievementType.dailyGoal:
        return 'Daily Goals';
      case AchievementType.earlyBird:
        return 'Early Bird';
      case AchievementType.nightOwl:
        return 'Night Owl';
      case AchievementType.consistency:
        return 'Consistency';
      case AchievementType.milestone:
        return 'Milestones';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
