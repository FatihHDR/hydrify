import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/preferences_service.dart';
import '../viewmodels/profile_viewmodel.dart';
// Temporarily commented out until Firebase is configured
// import '../viewmodels/auth_viewmodel.dart';
import 'onboarding_screen.dart';
import 'main_screen.dart';
// import 'login_screen.dart';
import '../utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animationController.forward();
    _initializeApp();
  }  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    
    // Temporarily skip Firebase auth check until Firebase is properly configured
    final preferencesService = PreferencesService();
    final isFirstRun = await preferencesService.isFirstRun();
    
    if (isFirstRun) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      // Initialize profile view model
      final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
      await profileViewModel.initialize();
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
    
    // TODO: Enable this when Firebase is properly configured
    // final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    // if (authViewModel.isAuthenticated) {
    //   // User is signed in logic...
    // } else {
    //   // Show login screen
    //   Navigator.of(context).pushReplacement(
    //     MaterialPageRoute(builder: (_) => const LoginScreen()),
    //   );
    // }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            
            // Modern minimalist logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.waterBlue.withOpacity(0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: const Icon(
                Icons.water_drop_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Clean typography
            Text(
              'Hydrify',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppColors.textPrimary,
                fontSize: 40,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Stay hydrated, stay healthy',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
            
            const Spacer(flex: 2),
            
            // Minimal loading indicator
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.waterBlue),
                backgroundColor: AppColors.waterBlue.withOpacity(0.1),
              ),
            ),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
