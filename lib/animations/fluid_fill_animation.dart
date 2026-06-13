import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'pulse_glow_animation.dart';

class FluidFillAnimation extends StatefulWidget {
  final double width;
  final double height;
  final double cornerRadius;
  final int batteryLevel;
  final bool isCharging;

  const FluidFillAnimation({
    super.key,
    required this.width,
    required this.height,
    required this.cornerRadius,
    required this.batteryLevel,
    required this.isCharging,
  });

  @override
  State<FluidFillAnimation> createState() => _FluidFillAnimationState();
}

class _FluidFillAnimationState extends State<FluidFillAnimation>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _levelController;
  late AnimationController _shimmerController;
  late Animation<double> _levelAnimation;

  double _targetLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _targetLevel = widget.batteryLevel / 100.0;

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _levelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _levelAnimation = Tween<double>(begin: _targetLevel, end: _targetLevel)
        .animate(CurvedAnimation(parent: _levelController, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(FluidFillAnimation old) {
    super.didUpdateWidget(old);
    if (old.batteryLevel != widget.batteryLevel) {
      final currentValue = _levelAnimation.value;
      _targetLevel = widget.batteryLevel / 100.0;
      _levelAnimation = Tween<double>(begin: currentValue, end: _targetLevel)
          .animate(CurvedAnimation(parent: _levelController, curve: Curves.easeInOut));
      _levelController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _levelController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_waveController, _levelAnimation, _shimmerController]),
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(widget.cornerRadius),
            border: Border.all(
              color: kCyan.withOpacity(0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: kCyan.withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.cornerRadius - 1),
            child: Stack(
              children: [
                // Wave fill layer
                Positioned.fill(
                  child: CustomPaint(
                    painter: _WavePainter(
                      wavePhase: _waveController.value,
                      fillLevel: _levelAnimation.value,
                      isCharging: widget.isCharging,
                    ),
                  ),
                ),
                // Shimmer overlay
                if (widget.isCharging)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ShimmerPainter(progress: _shimmerController.value),
                    ),
                  ),
                // Content
                Positioned.fill(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            widget.isCharging ? Icons.bolt : Icons.battery_full_rounded,
            color: Colors.white,
            size: 20,
          ),
          Text(
            '${widget.batteryLevel}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            widget.isCharging ? 'Charging' : 'Battery',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double wavePhase;
  final double fillLevel;
  final bool isCharging;

  _WavePainter({
    required this.wavePhase,
    required this.fillLevel,
    required this.isCharging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillY = size.height * (1 - fillLevel);
    final waveAmplitude = isCharging ? 4.0 : 2.0;
    final waveFrequency = 2.0 * math.pi / size.width;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = fillY +
          waveAmplitude *
              math.sin((x * waveFrequency) + (wavePhase * 2 * math.pi)) +
          waveAmplitude * 0.5 *
              math.sin((x * waveFrequency * 2) + (wavePhase * 2 * math.pi * 1.3));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    final color1 = isCharging ? kCyan : kCyan.withOpacity(0.6);
    final color2 = isCharging ? kGreen : kGreen.withOpacity(0.4);

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [color1.withOpacity(0.75), color2.withOpacity(0.55)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);

    // Second wave (slightly offset)
    final path2 = Path();
    path2.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final y = fillY +
          waveAmplitude * 0.7 *
              math.sin((x * waveFrequency) + (wavePhase * 2 * math.pi) + math.pi * 0.6) +
          3.0;
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width, size.height);
    path2.close();

    final paint2 = Paint()
      ..color = kGreen.withOpacity(0.3);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_WavePainter old) => true;
}

class _ShimmerPainter extends CustomPainter {
  final double progress;

  _ShimmerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final shimmerX = progress * (size.width + 80) - 40;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(shimmerX - 40, 0, 80, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}
