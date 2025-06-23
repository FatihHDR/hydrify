import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/app_theme.dart';

// 1. Animated Water Wave Progress Widget
class AnimatedWaterWaveProgress extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double width;
  final double height;
  final Color waveColor;
  final Color backgroundColor;
  final String? centerText;

  const AnimatedWaterWaveProgress({
    super.key,
    required this.progress,
    this.width = 200,
    this.height = 200,
    this.waveColor = AppColors.waterBlue,
    this.backgroundColor = AppColors.background,
    this.centerText,
  });

  @override
  State<AnimatedWaterWaveProgress> createState() => _AnimatedWaterWaveProgressState();
}

class _AnimatedWaterWaveProgressState extends State<AnimatedWaterWaveProgress>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _progressController.forward();
  }

  @override
  void didUpdateWidget(AnimatedWaterWaveProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ));
      _progressController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: Listenable.merge([_animationController, _progressAnimation]),
        builder: (context, child) {
          return CustomPaint(
            painter: WaterWavePainter(
              animationValue: _animationController.value,
              progress: _progressAnimation.value,
              waveColor: widget.waveColor,
              backgroundColor: widget.backgroundColor,
            ),
            child: widget.centerText != null
                ? Center(
                    child: Text(
                      widget.centerText!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}

class WaterWavePainter extends CustomPainter {
  final double animationValue;
  final double progress;
  final Color waveColor;
  final Color backgroundColor;

  WaterWavePainter({
    required this.animationValue,
    required this.progress,
    required this.waveColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw water waves
    final waterLevel = size.height * (1 - progress);
    
    final wavePaint = Paint()
      ..color = waveColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final path = Path();
    
    for (double i = 0; i <= size.width; i++) {
      final waveHeight = 10 * math.sin((i / 50) + (animationValue * 2 * math.pi));
      final y = waterLevel + waveHeight;
      
      if (i == 0) {
        path.moveTo(i, y);
      } else {
        path.lineTo(i, y);
      }
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Clip to circle
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));
    canvas.drawPath(path, wavePaint);

    // Draw circle border
    final borderPaint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 2. 3D Bottle Visualization Widget
class Bottle3DVisualization extends StatefulWidget {
  final double fillPercentage; // 0.0 to 1.0
  final double width;
  final double height;
  final Color bottleColor;
  final Color waterColor;

  const Bottle3DVisualization({
    super.key,
    required this.fillPercentage,
    this.width = 100,
    this.height = 200,
    this.bottleColor = AppColors.textLight,
    this.waterColor = AppColors.waterBlue,
  });

  @override
  State<Bottle3DVisualization> createState() => _Bottle3DVisualizationState();
}

class _Bottle3DVisualizationState extends State<Bottle3DVisualization>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fillAnimation = Tween<double>(
      begin: 0.0,
      end: widget.fillPercentage,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(Bottle3DVisualization oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fillPercentage != widget.fillPercentage) {
      _fillAnimation = Tween<double>(
        begin: _fillAnimation.value,
        end: widget.fillPercentage,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _fillAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: Bottle3DPainter(
              fillPercentage: _fillAnimation.value,
              bottleColor: widget.bottleColor,
              waterColor: widget.waterColor,
            ),
          );
        },
      ),
    );
  }
}

class Bottle3DPainter extends CustomPainter {
  final double fillPercentage;
  final Color bottleColor;
  final Color waterColor;

  Bottle3DPainter({
    required this.fillPercentage,
    required this.bottleColor,
    required this.waterColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2;

    // Bottle outline
    final bottlePath = Path();
    final bottleWidth = size.width * 0.6;
    final bottleHeight = size.height * 0.85;
    final neckWidth = size.width * 0.3;
    final neckHeight = size.height * 0.15;

    // Bottle body
    final left = (size.width - bottleWidth) / 2;
    final right = left + bottleWidth;
    final bottom = size.height;
    final top = size.height - bottleHeight;

    // Create bottle shape
    bottlePath.moveTo(left, bottom);
    bottlePath.lineTo(left, top + 20);
    bottlePath.quadraticBezierTo(left, top, left + 20, top);
    bottlePath.lineTo(right - 20, top);
    bottlePath.quadraticBezierTo(right, top, right, top + 20);
    bottlePath.lineTo(right, bottom);

    // Neck
    final neckLeft = (size.width - neckWidth) / 2;
    final neckRight = neckLeft + neckWidth;
    bottlePath.moveTo(neckLeft, top);
    bottlePath.lineTo(neckLeft, neckHeight);
    bottlePath.quadraticBezierTo(neckLeft, 0, neckLeft + 10, 0);
    bottlePath.lineTo(neckRight - 10, 0);
    bottlePath.quadraticBezierTo(neckRight, 0, neckRight, neckHeight);
    bottlePath.lineTo(neckRight, top);

    // Draw bottle outline
    paint.color = bottleColor;
    canvas.drawPath(bottlePath, paint);

    // Draw water
    if (fillPercentage > 0) {
      final waterHeight = bottleHeight * fillPercentage;
      final waterTop = bottom - waterHeight;

      final waterPaint = Paint()
        ..color = waterColor.withOpacity(0.7)
        ..style = PaintingStyle.fill;

      final waterPath = Path();
      waterPath.moveTo(left + 2, bottom - 2);
      waterPath.lineTo(left + 2, waterTop);
      waterPath.quadraticBezierTo(left + 2, waterTop - 5, left + 15, waterTop - 5);
      waterPath.lineTo(right - 15, waterTop - 5);
      waterPath.quadraticBezierTo(right - 2, waterTop - 5, right - 2, waterTop);
      waterPath.lineTo(right - 2, bottom - 2);
      waterPath.close();

      canvas.drawPath(waterPath, waterPaint);

      // Water surface highlight
      final highlightPaint = Paint()
        ..color = waterColor.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      final ellipse = Path();
      ellipse.addOval(Rect.fromCenter(
        center: Offset(size.width / 2, waterTop - 3),
        width: bottleWidth - 20,
        height: 8,
      ));
      canvas.drawPath(ellipse, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 3. Enhanced Dark Mode Support Widget
class ThemeAwareContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final bool useCardStyle;

  const ThemeAwareContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.useCardStyle = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: useCardStyle 
            ? (isDark ? AppColors.textPrimary.withOpacity(0.1) : AppColors.surface)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: useCardStyle && isDark 
            ? Border.all(color: AppColors.textLight.withOpacity(0.2))
            : null,
        boxShadow: useCardStyle && !isDark
            ? [
                BoxShadow(
                  color: AppColors.textLight.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

// 4. Accessibility Enhanced Widget
class AccessibleWaterButton extends StatefulWidget {
  final int amount;
  final VoidCallback onTap;
  final bool isSelected;

  const AccessibleWaterButton({
    super.key,
    required this.amount,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<AccessibleWaterButton> createState() => _AccessibleWaterButtonState();
}

class _AccessibleWaterButtonState extends State<AccessibleWaterButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Add ${widget.amount}ml of water',
      hint: 'Double tap to add water intake',
      button: true,
      enabled: true,
      child: Focus(
        onFocusChange: (focused) {
          setState(() {
            _isFocused = focused;
          });
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: widget.isSelected 
                  ? AppColors.waterBlue 
                  : (_isFocused ? AppColors.waterBlue.withOpacity(0.2) : AppColors.surface),
              borderRadius: BorderRadius.circular(16),
              border: _isFocused 
                  ? Border.all(color: AppColors.waterBlue, width: 2)
                  : Border.all(color: AppColors.textLight.withOpacity(0.3)),
              boxShadow: widget.isSelected || _isFocused
                  ? [
                      BoxShadow(
                        color: AppColors.waterBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_drink,
                  color: widget.isSelected ? Colors.white : AppColors.waterBlue,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.amount}ml',
                  style: TextStyle(
                    color: widget.isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 5. Floating Bottom Navigation Bar
class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<FloatingNavItem> items;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.textLight.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.waterBlue.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item.icon,
                            color: isSelected ? AppColors.waterBlue : AppColors.textLight,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isSelected ? AppColors.waterBlue : AppColors.textLight,
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class FloatingNavItem {
  final IconData icon;
  final String label;

  const FloatingNavItem({
    required this.icon,
    required this.label,
  });
}

// 6. International Language Support Widget
class LocalizedText extends StatelessWidget {
  final String textKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Map<String, String>? args;

  const LocalizedText(
    this.textKey, {
    super.key,
    this.style,
    this.textAlign,
    this.args,
  });

  @override
  Widget build(BuildContext context) {
    // Simple localization - in production, use flutter_localizations
    String text = _getLocalizedText(textKey, args);
    
    return Text(
      text,
      style: style,
      textAlign: textAlign,
    );
  }

  String _getLocalizedText(String key, Map<String, String>? args) {
    // Simple English-Indonesian translation map
    final Map<String, String> translations = {
      'good_morning': 'Good Morning',
      'good_afternoon': 'Good Afternoon',
      'good_evening': 'Good Evening',
      'lets_stay_hydrated': 'Let\'s stay hydrated today!',
      'todays_progress': 'Today\'s Progress',
      'quick_add': 'Quick Add',
      'achievements': 'Achievements',
      'home': 'Home',
      'history': 'History',
      'profile': 'Profile',
      'add_water': 'Add Water',
      'ml': 'ml',
      'liters': 'L',
      'goal_reached': 'Goal Reached!',
      'keep_going': 'Keep Going!',
      // Add more translations as needed
    };

    String text = translations[key] ?? key;
    
    // Replace arguments if provided
    if (args != null) {
      args.forEach((argKey, argValue) {
        text = text.replaceAll('{$argKey}', argValue);
      });
    }
    
    return text;
  }
}
