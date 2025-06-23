import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/user_profile_model.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../utils/theme_manager.dart';
import '../widgets/common_widgets.dart';
import '../widgets/gradient_background.dart';
import 'login_screen.dart';
import 'debug_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      viewModel.initialize().then((_) {
        _populateForm(viewModel.userProfile);
      });
    });
  }

  void _populateForm(UserProfileModel? profile) {
    if (profile != null) {
      _nameController.text = profile.name;
      _ageController.text = profile.age.toString();
      _weightController.text = profile.weight.toString();
      _goalController.text = profile.dailyGoal.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _goalController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
          elevation: 0,actions: [
          // Dark mode toggle button
          Consumer<ThemeManager>(
            builder: (context, themeManager, child) {
              return IconButton(
                icon: Icon(
                  themeManager.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeManager.toggleTheme();
                },
                tooltip: themeManager.isDarkMode ? 'Light Mode' : 'Dark Mode',
              );
            },
          ),
          // Debug button
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DebugScreen()),
              );
            },
          ),
          Consumer<ProfileViewModel>(
            builder: (context, viewModel, child) {              return TextButton(
                onPressed: viewModel.isSaving ? null : _saveProfile,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: viewModel.isSaving 
                        ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5)
                        : Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const LoadingWidget();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(viewModel),
                  const SizedBox(height: 24),                  _buildPersonalInfoSection(viewModel),
                  const SizedBox(height: 24),
                  _buildGoalsSection(viewModel),
                  const SizedBox(height: 24),
                  _buildNotificationSection(viewModel),
                  const SizedBox(height: 24),
                  _buildStatisticsSection(viewModel),
                  const SizedBox(height: 24),
                  _buildAccountSection(),
                  const SizedBox(height: 80), // Extra space for bottom padding
                ],
              ),
            ),
          );        },
      ),
    ),
    );
  }

  Widget _buildProfileHeader(ProfileViewModel viewModel) {
    final profile = viewModel.userProfile;
    
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppColors.primaryGradient,
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Daily Goal: ${profile != null ? WaterCalculator.formatAmount(profile.dailyGoal) : "Not set"}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(ProfileViewModel viewModel) {
    return _buildSection(
      title: 'Personal Information',
      icon: Icons.person,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter your name',
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator: viewModel.validateName,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  hintText: 'Years',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: viewModel.validateAge,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight',
                  hintText: 'kg',
                  prefixIcon: Icon(Icons.fitness_center_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: viewModel.validateWeight,
                onChanged: (_) => _calculateRecommendedGoal(viewModel),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalsSection(ProfileViewModel viewModel) {
    return _buildSection(
      title: 'Daily Water Goal',
      icon: Icons.local_drink,
      children: [
        TextFormField(
          controller: _goalController,
          decoration: const InputDecoration(
            labelText: 'Daily Goal',
            hintText: 'ml',
            prefixIcon: Icon(Icons.local_drink_outlined),
            suffixText: 'ml',
          ),
          keyboardType: TextInputType.number,
          validator: viewModel.validateDailyGoal,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.waterBlueLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.waterBlueLight),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.info, color: AppColors.waterBlue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Recommended: 35ml per kg of body weight',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _calculateRecommendedGoal(viewModel),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.waterBlue),
                  ),
                  child: const Text('Use Recommended Goal'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSection(ProfileViewModel viewModel) {
    final profile = viewModel.userProfile;
    if (profile == null) return const SizedBox.shrink();

    return _buildSection(
      title: 'Notifications',
      icon: Icons.notifications,
      children: [
        SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Get reminded to drink water'),
          value: profile.notificationsEnabled,
          onChanged: (value) {
            viewModel.updateProfile(notificationsEnabled: value);
          },
          activeColor: AppColors.waterBlue,
          contentPadding: EdgeInsets.zero,
        ),
        if (profile.notificationsEnabled) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: profile.notificationInterval,
            decoration: const InputDecoration(
              labelText: 'Reminder Interval',
              prefixIcon: Icon(Icons.timer_outlined),
            ),
            items: viewModel.getNotificationIntervalOptions().map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('Every $value minutes'),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                viewModel.updateProfile(notificationInterval: value);
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: const Text('Start Time'),
                  subtitle: Text(DateTimeUtils.formatTime(profile.startTime)),
                  leading: const Icon(Icons.access_time),
                  contentPadding: EdgeInsets.zero,
                  onTap: () => _selectTime(context, viewModel, true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ListTile(
                  title: const Text('End Time'),
                  subtitle: Text(DateTimeUtils.formatTime(profile.endTime)),
                  leading: const Icon(Icons.access_time),
                  contentPadding: EdgeInsets.zero,
                  onTap: () => _selectTime(context, viewModel, false),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatisticsSection(ProfileViewModel viewModel) {
    final profile = viewModel.userProfile;
    if (profile == null) return const SizedBox.shrink();

    final recommendedIntake = UserProfileModel.calculateRecommendedIntake(profile.weight);
    final currentGoal = profile.dailyGoal;
    final isOptimal = currentGoal >= recommendedIntake * 0.8 && currentGoal <= recommendedIntake * 1.2;

    return _buildSection(
      title: 'Health Metrics',
      icon: Icons.health_and_safety,
      children: [
        _buildMetricCard(
          'Recommended Intake',
          WaterCalculator.formatAmount(recommendedIntake),
          Icons.recommend,
          AppColors.info,
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          'Current Goal',
          WaterCalculator.formatAmount(currentGoal),
          Icons.flag,
          isOptimal ? AppColors.success : AppColors.warning,
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          'BMI Range',
          '${profile.age} years, ${profile.weight}kg',
          Icons.person,
          AppColors.waterBlue,
        ),
        if (!isOptimal) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: AppColors.warning),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    currentGoal < recommendedIntake
                        ? 'Your goal is below the recommended intake. Consider increasing it.'
                        : 'Your goal is above the recommended intake. Make sure it\'s comfortable for you.',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.waterBlue),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _calculateRecommendedGoal(ProfileViewModel viewModel) {
    final weight = double.tryParse(_weightController.text);
    if (weight != null && weight > 0) {
      final recommendedGoal = UserProfileModel.calculateRecommendedIntake(weight);
      _goalController.text = recommendedGoal.toString();
    }
  }

  Future<void> _selectTime(BuildContext context, ProfileViewModel viewModel, bool isStartTime) async {
    final profile = viewModel.userProfile!;
    final initialTime = isStartTime 
        ? TimeOfDay.fromDateTime(profile.startTime)
        : TimeOfDay.fromDateTime(profile.endTime);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    
    if (picked != null) {
      final now = DateTime.now();
      final dateTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      
      if (isStartTime) {
        viewModel.updateProfile(startTime: dateTime);
      } else {
        viewModel.updateProfile(endTime: dateTime);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    final currentProfile = viewModel.userProfile;
    
    if (currentProfile == null) return;

    final updatedProfile = currentProfile.copyWith(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text),
      weight: double.parse(_weightController.text),
      dailyGoal: int.parse(_goalController.text),
    );    final success = await viewModel.saveUserProfile(updatedProfile);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Profile saved successfully!' : 'Error saving profile'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Widget _buildAccountSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_circle,
                  color: AppColors.waterBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),                Text(
                  'Account',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _handleSignOut,
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      await authViewModel.signOut();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
