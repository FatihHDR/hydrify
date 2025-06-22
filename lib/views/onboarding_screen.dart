import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile_model.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../services/preferences_service.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  
  int _currentPage = 0;
  
  // Form controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalController = TextEditingController();
  
  bool _notificationsEnabled = true;
  int _notificationInterval = 60;
  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_updateRecommendedGoal);
  }

  void _updateRecommendedGoal() {
    final weight = double.tryParse(_weightController.text);
    if (weight != null && weight > 0) {
      final recommendedGoal = UserProfileModel.calculateRecommendedIntake(weight);
      _goalController.text = recommendedGoal.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _goalController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: [
                    _buildWelcomePage(),
                    _buildPersonalInfoPage(),
                    _buildGoalsPage(),
                    _buildNotificationsPage(),
                    _buildCompletePage(),
                  ],
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(5, (index) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _currentPage ? AppColors.waterBlue : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.waterBlueLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(75),
            ),
            child: const Icon(
              Icons.water_drop,
              size: 80,
              color: AppColors.waterBlue,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome to Hydrify!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your personal hydration companion that helps you stay healthy by tracking your daily water intake.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildFeatureItem(Icons.track_changes, 'Track Water Intake'),
          _buildFeatureItem(Icons.notifications, 'Smart Reminders'),
          _buildFeatureItem(Icons.insights, 'Progress Insights'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.waterBlue, size: 24),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tell us about yourself',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This helps us personalize your experience',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: ValidationUtils.validateName,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      hintText: 'Years',
                      prefixIcon: Icon(Icons.cake),
                    ),
                    keyboardType: TextInputType.number,
                    validator: ValidationUtils.validateAge,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      hintText: 'kg',
                      prefixIcon: Icon(Icons.fitness_center),
                    ),
                    keyboardType: TextInputType.number,
                    validator: ValidationUtils.validateWeight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set your daily goal',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your weight, we recommend a daily water intake',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _goalController,
            decoration: const InputDecoration(
              labelText: 'Daily Water Goal',
              hintText: 'ml',
              prefixIcon: Icon(Icons.local_drink),
              suffixText: 'ml',
            ),
            keyboardType: TextInputType.number,
            validator: ValidationUtils.validateDailyGoal,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.waterBlueLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.waterBlueLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: AppColors.waterBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Recommended intake: 35ml per kg of body weight',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stay reminded',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set up notifications to help you stay hydrated',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get reminded to drink water'),
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
            activeColor: AppColors.waterBlue,
          ),
          if (_notificationsEnabled) ...[
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Reminder Interval'),
              subtitle: Text('Every $_notificationInterval minutes'),
              trailing: DropdownButton<int>(
                value: _notificationInterval,
                items: [15, 30, 45, 60, 90, 120].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value min'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _notificationInterval = value!),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(_startTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context, true),
            ),
            ListTile(
              title: const Text('End Time'),
              subtitle: Text(_endTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context, false),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'You\'re all set!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Start your hydration journey with Hydrify. Remember, small steps lead to big changes!',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                child: const Text('Back'),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentPage == 4 ? _completeOnboarding : _nextPage,
              child: Text(_currentPage == 4 ? 'Get Started' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage == 1 && !_formKey.currentState!.validate()) {
      return;
    }
    
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _completeOnboarding() async {
    if (!_formKey.currentState!.validate()) {
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    
    final now = DateTime.now();
    final startDateTime = DateTime(now.year, now.month, now.day, _startTime.hour, _startTime.minute);
    final endDateTime = DateTime(now.year, now.month, now.day, _endTime.hour, _endTime.minute);
    
    final profile = UserProfileModel(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text),
      weight: double.parse(_weightController.text),
      dailyGoal: int.parse(_goalController.text),
      notificationsEnabled: _notificationsEnabled,
      notificationInterval: _notificationInterval,
      startTime: startDateTime,
      endTime: endDateTime,
    );

    final success = await profileViewModel.saveUserProfile(profile);
    
    if (success) {
      await PreferencesService().setFirstRunComplete();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving profile. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
