import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Firebase imports (commented out until Firebase is properly configured)
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/history_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/achievement_viewmodel.dart';
import 'viewmodels/analytics_viewmodel.dart';
import 'views/splash_screen.dart';
import 'utils/app_theme.dart';
import 'utils/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (commented out until proper config is set up)
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  
  // Initialize services
  await NotificationService().initialize();
  
  runApp(const HydrifyApp());
}

class HydrifyApp extends StatelessWidget {
  const HydrifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => HistoryViewModel()),
        ChangeNotifierProvider(create: (_) => AchievementViewModel()),
        ChangeNotifierProvider(create: (_) => AnalyticsViewModel()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'Hydrify',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeManager.themeMode,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
