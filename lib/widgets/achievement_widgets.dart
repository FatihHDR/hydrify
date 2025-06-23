import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../utils/app_theme.dart';

class AchievementUnlockedDialog extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onClose;

  const AchievementUnlockedDialog({
    super.key,
    required this.achievement,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated trophy icon
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: achievement.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Icon(
                      achievement.icon,
                      size: 40,
                      color: achievement.color,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Achievement unlocked text
            const Text(
              'Achievement Unlocked!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Achievement title
            Text(
              achievement.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Achievement description
            Text(
              achievement.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onClose?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: achievement.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Awesome!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  static void show(BuildContext context, Achievement achievement, {VoidCallback? onClose}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AchievementUnlockedDialog(
        achievement: achievement,
        onClose: onClose,
      ),
    );
  }

  static void showMultiple(BuildContext context, List<Achievement> achievements, {VoidCallback? onClose}) {
    if (achievements.length == 1) {
      show(context, achievements.first, onClose: onClose);
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => MultipleAchievementsDialog(
          achievements: achievements,
          onClose: onClose,
        ),
      );
    }
  }
}

// Widget untuk menampilkan multiple achievements yang di-unlock sekaligus
class MultipleAchievementsDialog extends StatefulWidget {
  final List<Achievement> achievements;
  final VoidCallback? onClose;

  const MultipleAchievementsDialog({
    super.key,
    required this.achievements,
    this.onClose,
  });

  @override
  State<MultipleAchievementsDialog> createState() => _MultipleAchievementsDialogState();
}

class _MultipleAchievementsDialogState extends State<MultipleAchievementsDialog> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Achievements Unlocked!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  '${_currentPage + 1}/${widget.achievements.length}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // PageView for achievements
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: widget.achievements.length,
                itemBuilder: (context, index) {
                  final achievement = widget.achievements[index];
                  return _buildAchievementPage(achievement);
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Navigation buttons
            Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < widget.achievements.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.of(context).pop();
                        widget.onClose?.call();
                      }
                    },
                    child: Text(
                      _currentPage < widget.achievements.length - 1 ? 'Next' : 'Done',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementPage(Achievement achievement) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated icon
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: achievement.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  achievement.icon,
                  size: 50,
                  color: achievement.color,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // Achievement title
        Text(
          achievement.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        // Achievement description
        Text(
          achievement.description,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),      ],
    );
  }
}
