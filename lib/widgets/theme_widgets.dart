import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_manager.dart';
import '../utils/app_theme.dart';

class AnimatedThemeToggle extends StatefulWidget {
  final double size;
  final Color? lightModeColor;
  final Color? darkModeColor;
  final VoidCallback? onToggle;

  const AnimatedThemeToggle({
    super.key,
    this.size = 24.0,
    this.lightModeColor,
    this.darkModeColor,
    this.onToggle,
  });

  @override
  State<AnimatedThemeToggle> createState() => _AnimatedThemeToggleState();
}

class _AnimatedThemeToggleState extends State<AnimatedThemeToggle>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleToggle(ThemeManager themeManager) async {
    // Scale down animation
    await _scaleController.forward();
    
    // Rotate animation
    _rotationController.forward().then((_) {
      _rotationController.reset();
    });
    
    // Toggle theme
    await themeManager.toggleTheme();
    
    // Scale back up
    _scaleController.reverse();
    
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        final isDarkMode = themeManager.isDarkMode;
        
        return GestureDetector(
          onTap: () => _handleToggle(themeManager),
          child: AnimatedBuilder(
            animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: widget.size + 16,
                    height: widget.size + 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular((widget.size + 16) / 2),
                      color: isDarkMode
                          ? AppColors.surfaceVariantDark.withOpacity(0.8)
                          : AppColors.surfaceVariant.withOpacity(0.8),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return RotationTransition(
                            turns: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          key: ValueKey(isDarkMode),
                          size: widget.size,
                          color: isDarkMode
                              ? (widget.darkModeColor ?? AppColors.textPrimaryDark)
                              : (widget.lightModeColor ?? AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  final String? tooltip;
  final VoidCallback? onPressed;

  const ThemeToggleButton({
    super.key,
    this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return IconButton(
          tooltip: tooltip ?? (themeManager.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'),
          onPressed: () {
            themeManager.toggleTheme();
            onPressed?.call();
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: Icon(
              themeManager.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              key: ValueKey(themeManager.isDarkMode),
              color: themeManager.isDarkMode
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimary,
            ),
          ),
        );
      },
    );
  }
}

class ThemeToggleSwitch extends StatelessWidget {
  final double scale;
  final Color? activeColor;
  final Color? inactiveColor;

  const ThemeToggleSwitch({
    super.key,
    this.scale = 1.0,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return Transform.scale(
          scale: scale,
          child: Switch.adaptive(
            value: themeManager.isDarkMode,
            onChanged: (_) => themeManager.toggleTheme(),
            activeColor: activeColor ?? AppColors.primary,
            inactiveThumbColor: inactiveColor ?? AppColors.textSecondary,
            activeTrackColor: (activeColor ?? AppColors.primary).withOpacity(0.3),
            inactiveTrackColor: (inactiveColor ?? AppColors.textSecondary).withOpacity(0.3),
          ),
        );
      },
    );
  }
}

class AnimatedThemeContainer extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedThemeContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        return AnimatedContainer(
          duration: duration,
          curve: curve,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: this.child,
        );
      },
    );
  }
}

class ThemeTransitionOverlay extends StatefulWidget {
  final Widget child;
  
  const ThemeTransitionOverlay({
    super.key,
    required this.child,
  });

  @override
  State<ThemeTransitionOverlay> createState() => _ThemeTransitionOverlayState();
}

class _ThemeTransitionOverlayState extends State<ThemeTransitionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _showOverlay = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showTransition() async {
    setState(() {
      _showOverlay = true;
    });
    
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _controller.reverse();
    
    setState(() {
      _showOverlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        // Show transition overlay when theme is animating
        if (themeManager.isAnimating && !_showOverlay) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showTransition();
          });
        }
        
        return Stack(
          children: [
            widget.child,
            if (_showOverlay)
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Container(
                    color: Colors.black.withOpacity(_fadeAnimation.value),
                    child: const Center(
                      child: Icon(
                        Icons.brightness_6,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
