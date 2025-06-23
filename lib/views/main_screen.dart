import 'package:flutter/material.dart';
import '../widgets/advanced_widgets.dart';
import '../widgets/gradient_background.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'achievement_screen.dart';
import 'analytics_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isNavBarVisible = true;
  late AnimationController _navBarController;
  late AnimationController _pageController;
  late Animation<Offset> _navBarAnimation;
  late Animation<double> _fadeAnimation;
    final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const AnalyticsScreen(),
    const AchievementScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    
    // Animation controller for navigation bar
    _navBarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Animation controller for page transitions
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Slide animation for navigation bar
    _navBarAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _navBarController,
      curve: Curves.easeInOut,
    ));
    
    // Fade animation for page transitions
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _navBarController.forward();
    _pageController.forward();
  }

  @override
  void dispose() {
    _navBarController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      
      // Restart page animation for smooth transition
      _pageController.reset();
      _pageController.forward();
    }
  }

  void _toggleNavBar() {
    setState(() {
      _isNavBarVisible = !_isNavBarVisible;
    });
    
    if (_isNavBarVisible) {
      _navBarController.forward();
    } else {
      _navBarController.reverse();
    }
  }  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make scaffold transparent to show gradient
        body: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            // Hide/show navbar based on scroll direction
            if (scrollNotification is ScrollUpdateNotification) {
              if (scrollNotification.scrollDelta! > 0) {
                // Scrolling down - hide navbar
                if (_isNavBarVisible) {
                  _toggleNavBar();
                }
              } else if (scrollNotification.scrollDelta! < 0) {
                // Scrolling up - show navbar
                if (!_isNavBarVisible) {
                  _toggleNavBar();
                }
              }
            }
            return false;
          },
          child: Stack(
            children: [
              // Page content with fade animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: _screens[_currentIndex],
              ),
              // Animated Bottom Navigation Bar
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: SlideTransition(
                  position: _navBarAnimation,
                  child: FloatingBottomNavBar(
                    currentIndex: _currentIndex,
                    onTap: _onTabTapped,
                    items: const [
                      FloatingNavItem(icon: Icons.home, label: 'Home'),
                      FloatingNavItem(icon: Icons.history, label: 'History'),
                      FloatingNavItem(icon: Icons.emoji_events, label: 'Achievements'),
                      FloatingNavItem(icon: Icons.person, label: 'Profile'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
