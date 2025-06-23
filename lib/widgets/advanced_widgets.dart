import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/app_theme.dart';

// 1. Simple Progress Wave Effect for Cards
class ProgressWaveEffect extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double width;
  final double height;
  final Color waveColor;
  final Color backgroundColor;

  const ProgressWaveEffect({
    super.key,
    required this.progress,
    this.width = 200,
    this.height = 20,
    this.waveColor = AppColors.waterBlue,
    this.backgroundColor = Colors.transparent,
  });

  @override
  State<ProgressWaveEffect> createState() => _ProgressWaveEffectState();
}

class _ProgressWaveEffectState extends State<ProgressWaveEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            painter: ProgressWavePainter(
              animationValue: _animationController.value,
              progress: widget.progress,
              waveColor: widget.waveColor,
              backgroundColor: widget.backgroundColor,
            ),
          );
        },
      ),
    );
  }
}

class ProgressWavePainter extends CustomPainter {
  final double animationValue;
  final double progress;
  final Color waveColor;
  final Color backgroundColor;

  ProgressWavePainter({
    required this.animationValue,
    required this.progress,
    required this.waveColor,
    required this.backgroundColor,
  });
  @override
  void paint(Canvas canvas, Size size) {
    print("Drawing wave effect: size=${size.width}x${size.height}, progress=$progress");
    
    // Draw background
    if (backgroundColor != Colors.transparent) {
      final bgPaint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill;
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(10),
      );
      canvas.drawRRect(bgRect, bgPaint);
    }    // Always show wave effect for visibility
    final progressWidth = size.width; // Use full width instead of progress-based width
    
    final path = Path();    // Enhanced wave amplitude for maximum visibility
    const waveAmplitude = 15.0; // Much larger amplitude for visibility
    const waveFrequency = 0.02; // Lower frequency for smoother waves
    
    // Start from left
    for (double x = 0; x <= progressWidth; x += 1) {
      final waveHeight = waveAmplitude * math.sin(
        (x * waveFrequency) + (animationValue * 2 * math.pi)
      );
      
      final y = (size.height * 0.3) + waveHeight; // Position wave at 30% height instead of center
      
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    // Complete the filled area
    path.lineTo(progressWidth, size.height);
    path.lineTo(0, size.height);
    path.close();    // Draw the wave with high visibility
    final wavePaint = Paint()
      ..color = waveColor.withOpacity(1.0) // Full opacity since color already has opacity
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, wavePaint);

    // Add a more visible border
    final borderPaint = Paint()
      ..color = waveColor.withOpacity(1.0) // Full opacity
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2; // Increased from 1 to 2
    
    final borderRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(10),
    );
    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 2. Animated Water Wave Progress Widget (keeping the original for other uses)
class AnimatedWaterWaveProgress extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double width;
  final double height;
  final Color waveColor;
  final Color backgroundColor;
  final String? centerText;
  final bool isCircular; // New parameter to control shape

  const AnimatedWaterWaveProgress({
    super.key,
    required this.progress,
    this.width = 200,
    this.height = 200,
    this.waveColor = AppColors.waterBlue,
    this.backgroundColor = AppColors.background,
    this.centerText,
    this.isCircular = true, // Default to circular for backward compatibility
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
        builder: (context, child) {          return CustomPaint(
            painter: WaterWavePainter(
              animationValue: _animationController.value,
              progress: _progressAnimation.value,
              waveColor: widget.waveColor,
              backgroundColor: widget.backgroundColor,
              isCircular: widget.isCircular,
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
  final bool isCircular;

  WaterWavePainter({
    required this.animationValue,
    required this.progress,
    required this.waveColor,
    required this.backgroundColor,
    required this.isCircular,
  });  @override
  void paint(Canvas canvas, Size size) {
    if (isCircular) {
      _paintCircularWave(canvas, size);
    } else {
      _paintRectangularWave(canvas, size);
    }
  }

  void _paintCircularWave(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Create smooth wave animation for circular shape
    final waterLevel = size.height * (1 - progress);

    final path = Path();
    
    // Enhanced wave parameters for more natural look
    const baseWaveAmplitude = 6.0;
    const waveFrequency1 = 0.02;
    const waveFrequency2 = 0.035;
    const waveFrequency3 = 0.055;
    
    for (double i = 0; i <= size.width + 2; i += 1) {
      double waveHeight = 0;
      
      // Layer multiple sine waves for natural ocean-like movement
      waveHeight += baseWaveAmplitude * 0.6 * math.sin(
          (i * waveFrequency1) + (animationValue * 2.0 * math.pi)
      );
      
      waveHeight += baseWaveAmplitude * 0.25 * math.sin(
          (i * waveFrequency2) - (animationValue * 2.8 * math.pi) + math.pi / 3
      );
      
      waveHeight += baseWaveAmplitude * 0.15 * math.sin(
          (i * waveFrequency3) + (animationValue * 4.2 * math.pi) + math.pi / 6
      );
      
      waveHeight += baseWaveAmplitude * 0.1 * math.sin(
          (i * 0.08) + (animationValue * 1.5 * math.pi)
      );
      
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

    // Clip to circle and draw water
    canvas.save();
    final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius - 1));
    canvas.clipPath(clipPath);
    canvas.drawPath(path, Paint()..color = waveColor..style = PaintingStyle.fill);
    canvas.restore();

    // Draw circle border
    final borderPaint = Paint()
      ..color = waveColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    // Add inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius - 3, highlightPaint);
  }

  void _paintRectangularWave(Canvas canvas, Size size) {
    // Draw background
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(10),
    );
    canvas.drawRRect(bgRect, bgPaint);

    // Create smooth wave for rectangular progress bar
    final waterLevel = size.height * (1 - progress);
    
    if (progress <= 0) return;

    final path = Path();
    
    // Smaller wave amplitude for progress bar
    const baseWaveAmplitude = 2.0;
    const waveFrequency1 = 0.04;
    const waveFrequency2 = 0.07;
    
    for (double i = 0; i <= size.width; i += 0.5) {
      double waveHeight = 0;
      
      // Subtle waves for progress bar
      waveHeight += baseWaveAmplitude * 0.7 * math.sin(
          (i * waveFrequency1) + (animationValue * 2.0 * math.pi)
      );
      
      waveHeight += baseWaveAmplitude * 0.3 * math.sin(
          (i * waveFrequency2) - (animationValue * 3.0 * math.pi) + math.pi / 4
      );
      
      final y = (waterLevel + waveHeight).clamp(0.0, size.height);
      
      if (i == 0) {
        path.moveTo(i, y);
      } else {
        path.lineTo(i, y);
      }
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Clip to rounded rectangle and draw water
    canvas.save();
    final clipPath = Path()..addRRect(bgRect);
    canvas.clipPath(clipPath);
    
    // Gradient water effect for progress bar
    final waterGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        waveColor.withOpacity(0.7),
        waveColor,
      ],
    );
    
    final waterPaint = Paint()
      ..shader = waterGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, waterPaint);
    canvas.restore();

    // Draw border
    final borderPaint = Paint()
      ..color = waveColor.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(bgRect, borderPaint);
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
  });  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5;

    // More realistic bottle proportions
    final bottleWidth = size.width * 0.65;
    final bottleHeight = size.height * 0.75;
    final neckWidth = size.width * 0.22;
    final neckHeight = size.height * 0.18;
    final shoulderHeight = size.height * 0.12;

    // Bottle coordinates
    final left = (size.width - bottleWidth) / 2;
    final right = left + bottleWidth;
    final bottom = size.height - 8;
    final top = size.height - bottleHeight;
    final shoulderTop = top - shoulderHeight;

    // Neck coordinates
    final neckLeft = (size.width - neckWidth) / 2;
    final neckRight = neckLeft + neckWidth;

    // Draw realistic bottle shape with rounded bottom
    final bottlePath = Path();
    
    // Start from bottom left, create rounded bottom
    bottlePath.moveTo(left + 8, bottom);
    bottlePath.quadraticBezierTo(left, bottom, left, bottom - 8);
    
    // Left side with slight curve
    bottlePath.lineTo(left, top + 25);
    bottlePath.quadraticBezierTo(left, top + 15, left + 8, top + 10);
    
    // Shoulder transition to neck
    bottlePath.quadraticBezierTo(left + 20, shoulderTop + 5, neckLeft + 2, shoulderTop);
    bottlePath.lineTo(neckLeft, shoulderTop - 2);
    
    // Neck
    bottlePath.lineTo(neckLeft, neckHeight + 8);
    bottlePath.quadraticBezierTo(neckLeft, neckHeight + 3, neckLeft + 3, neckHeight);
    
    // Bottle mouth/rim
    bottlePath.lineTo(neckRight - 3, neckHeight);
    bottlePath.quadraticBezierTo(neckRight, neckHeight + 3, neckRight, neckHeight + 8);
    
    // Right neck
    bottlePath.lineTo(neckRight, shoulderTop - 2);
    bottlePath.lineTo(neckRight - 2, shoulderTop);
    
    // Right shoulder
    bottlePath.quadraticBezierTo(right - 20, shoulderTop + 5, right - 8, top + 10);
    
    // Right side
    bottlePath.quadraticBezierTo(right, top + 15, right, top + 25);
    bottlePath.lineTo(right, bottom - 8);
    
    // Rounded bottom right
    bottlePath.quadraticBezierTo(right, bottom, right - 8, bottom);
    bottlePath.close();

    // Draw bottle cap with more detail
    final capPath = Path();
    capPath.moveTo(neckLeft - 3, neckHeight + 8);
    capPath.lineTo(neckLeft - 3, 8);
    capPath.quadraticBezierTo(neckLeft - 3, 3, neckLeft + 2, 2);
    capPath.lineTo(neckRight - 2, 2);
    capPath.quadraticBezierTo(neckRight + 3, 3, neckRight + 3, 8);
    capPath.lineTo(neckRight + 3, neckHeight + 8);
    capPath.close();

    // Add cap ridges for realism
    final capRidge1 = Path();
    capRidge1.moveTo(neckLeft - 1, 12);
    capRidge1.lineTo(neckRight + 1, 12);
    
    final capRidge2 = Path();
    capRidge2.moveTo(neckLeft - 1, 16);
    capRidge2.lineTo(neckRight + 1, 16);

    // Draw bottle with gradient effect
    paint.color = bottleColor.withOpacity(0.8);
    canvas.drawPath(bottlePath, paint);
    
    // Draw cap
    paint.color = bottleColor;
    canvas.drawPath(capPath, paint);
    
    // Draw cap ridges
    paint.strokeWidth = 1;
    canvas.drawPath(capRidge1, paint);
    canvas.drawPath(capRidge2, paint);
    
    paint.strokeWidth = 2.5;    // Draw water with realistic bottle-following shape
    if (fillPercentage > 0) {
      final maxWaterHeight = bottleHeight - 30; // Account for bottle curves
      final waterHeight = maxWaterHeight * fillPercentage;
      final waterTop = bottom - 8 - waterHeight;

      final waterPaint = Paint()
        ..color = waterColor.withOpacity(0.7)
        ..style = PaintingStyle.fill;

      final waterPath = Path();
      
      // Start from bottom, matching bottle contours
      waterPath.moveTo(left + 8, bottom - 8);
      waterPath.quadraticBezierTo(left + 3, bottom - 8, left + 3, bottom - 12);
      
      if (waterTop > top + 25) {
        // Water is in main body only
        waterPath.lineTo(left + 3, waterTop);
        
        // Create slightly wavy water surface
        final waveAmplitude = 2.0;
        final segments = 8;
        final segmentWidth = (bottleWidth - 16) / segments;
        
        for (int i = 0; i <= segments; i++) {
          final x = left + 8 + (i * segmentWidth);
          final waveOffset = waveAmplitude * math.sin(i * 0.8);
          final y = waterTop + waveOffset;
          
          if (i == 0) {
            waterPath.lineTo(x, y);
          } else {
            waterPath.lineTo(x, y);
          }
        }
        
        waterPath.lineTo(right - 3, waterTop);
      } else if (waterTop > shoulderTop) {
        // Water reaches shoulder area
        waterPath.lineTo(left + 3, top + 25);
        waterPath.quadraticBezierTo(left + 3, top + 18, left + 10, top + 15);
        waterPath.lineTo(left + 18, waterTop);
        waterPath.lineTo(right - 18, waterTop);
        waterPath.lineTo(right - 10, top + 15);
        waterPath.quadraticBezierTo(right - 3, top + 18, right - 3, top + 25);
      } else {
        // Water reaches neck area
        waterPath.lineTo(left + 3, top + 25);
        waterPath.quadraticBezierTo(left + 3, top + 18, left + 10, top + 15);
        waterPath.quadraticBezierTo(left + 18, shoulderTop + 8, neckLeft + 4, shoulderTop + 3);
        waterPath.lineTo(neckLeft + 4, waterTop);
        waterPath.lineTo(neckRight - 4, waterTop);
        waterPath.lineTo(neckRight - 4, shoulderTop + 3);
        waterPath.quadraticBezierTo(right - 18, shoulderTop + 8, right - 10, top + 15);
        waterPath.quadraticBezierTo(right - 3, top + 18, right - 3, top + 25);
      }
      
      // Complete water shape
      waterPath.lineTo(right - 3, bottom - 12);
      waterPath.quadraticBezierTo(right - 3, bottom - 8, right - 8, bottom - 8);
      waterPath.close();

      canvas.drawPath(waterPath, waterPaint);

      // Add realistic water surface with light reflection
      final surfaceReflectionPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.fill;

      if (waterTop > top + 25) {
        // Main body water surface reflection
        final reflectionPath = Path();
        final reflectionWidth = bottleWidth - 20;
        
        // Create elliptical reflection
        reflectionPath.addOval(
          Rect.fromCenter(
            center: Offset(size.width / 2, waterTop - 1),
            width: reflectionWidth,
            height: 4,
          ),
        );
        canvas.drawPath(reflectionPath, surfaceReflectionPaint);
      }
      
      // Add water shimmer effect
      final shimmerPaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill;
        
      final shimmerPath = Path();
      shimmerPath.addOval(
        Rect.fromLTWH(
          left + 12, 
          waterTop + (waterHeight * 0.3), 
          8, 
          waterHeight * 0.4
        ),
      );
      canvas.drawPath(shimmerPath, shimmerPaint);
    }

    // Add realistic bottle highlights and shadows
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Main body highlight (left side)
    final highlightPath = Path();
    highlightPath.moveTo(left + 6, bottom - 15);
    highlightPath.quadraticBezierTo(left + 6, bottom - 20, left + 8, bottom - 22);
    highlightPath.lineTo(left + 8, top + 30);
    highlightPath.quadraticBezierTo(left + 8, top + 22, left + 12, top + 18);
    highlightPath.quadraticBezierTo(left + 16, shoulderTop + 12, neckLeft + 6, shoulderTop + 8);

    canvas.drawPath(highlightPath, highlightPaint);
    
    // Add subtle shadow on right side
    final shadowPaint = Paint()
      ..color = bottleColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final shadowPath = Path();
    shadowPath.moveTo(right - 4, bottom - 15);
    shadowPath.lineTo(right - 4, top + 30);
    canvas.drawPath(shadowPath, shadowPaint);

    // Cap highlight
    final capHighlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
      
    final capHighlight = Path();
    capHighlight.moveTo(neckLeft + 2, 6);
    capHighlight.lineTo(neckLeft + 2, neckHeight + 6);
    canvas.drawPath(capHighlight, capHighlightPaint);
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
  });  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isDark 
                  ? AppColors.surfaceVariantDark.withOpacity(0.3)
                  : AppColors.textLight.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.waterBlue.withOpacity(0.9)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppColors.waterBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: isSelected ? 1.1 : 1.0,
                        child: Icon(
                          item.icon,
                          color: isSelected 
                              ? Colors.white 
                              : isDark 
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textLight,
                          size: 26,
                        ),
                      ),
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
