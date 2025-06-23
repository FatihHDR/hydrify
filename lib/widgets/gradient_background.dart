import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/theme_manager.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final Duration animationDuration;
  final Curve animationCurve;
  
  const GradientBackground({
    super.key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return AnimatedContainer(
          duration: animationDuration,
          curve: animationCurve,
          decoration: BoxDecoration(
            gradient: themeManager.isDarkMode 
                ? AppColors.backgroundGradientDark
                : AppColors.backgroundGradientLight,
          ),
          child: this.child,
        );
      },
    );
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;
  final Curve animationCurve;
  
  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeInOutCubic,
  });

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        // Trigger animation when theme changes
        if (themeManager.isAnimating) {
          _controller.forward().then((_) {
            _controller.reverse();
          });
        }
        
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getInterpolatedColors(themeManager.isDarkMode, _animation.value),
                ),
              ),
              child: widget.child,
            );
          },
        );
      },
    );
  }
  
  List<Color> _getInterpolatedColors(bool isDarkMode, double animationValue) {
    final lightColors = [
      const Color(0xFFF0F9FF), // Light blue
      const Color(0xFFE0F2FE), // Lighter blue
      const Color(0xFFBAE6FD), // Very light blue
    ];
    
    final darkColors = [
      const Color(0xFF0F172A), // Dark slate
      const Color(0xFF1E293B), // Slate 800
      const Color(0xFF334155), // Slate 700
    ];
    
    if (isDarkMode) {
      return darkColors;
    } else {
      return lightColors;
    }
  }
}
