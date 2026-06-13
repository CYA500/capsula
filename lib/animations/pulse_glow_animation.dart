import 'dart:math' as math;
import 'package:flutter/material.dart';

const Color kCyan = Color(0xFF3FCAFC);
const Color kGreen = Color(0xFF5CFF7A);

class PulseGlowAnimation extends StatefulWidget {
  final double width;
  final double height;
  final double cornerRadius;
  final int batteryLevel;
  final bool isCharging;

  const PulseGlowAnimation({
    super.key,
    required this.width,
    required this.height,
    required this.cornerRadius,
    required this.batteryLevel,
    required this.isCharging,
  });

  @override
  State<PulseGlowAnimation> createState() => _PulseGlowAnimationState();
}

class _PulseGlowAnimationState extends State<PulseGlowAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _colorController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _colorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _colorController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _colorAnimation]),
      builder: (context, child) {
        final glowColor = Color.lerp(kCyan, kGreen, _colorAnimation.value)!;
        final glowRadius = widget.isCharging
            ? (16.0 + _pulseAnimation.value * 18.0)
            : 6.0;
        final glowOpacity = widget.isCharging
            ? (0.5 + _pulseAnimation.value * 0.4)
            : 0.2;

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.cornerRadius),
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF0A0A0A), glowColor.withOpacity(0.15), _pulseAnimation.value)!,
                Color.lerp(const Color(0xFF141414), glowColor.withOpacity(0.08), _pulseAnimation.value)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: widget.isCharging
                ? [
                    BoxShadow(
                      color: glowColor.withOpacity(glowOpacity * 0.8),
                      blurRadius: glowRadius,
                      spreadRadius: glowRadius * 0.3,
                    ),
                    BoxShadow(
                      color: glowColor.withOpacity(glowOpacity * 0.3),
                      blurRadius: glowRadius * 2.5,
                      spreadRadius: glowRadius * 0.1,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: kCyan.withOpacity(0.15),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
            border: Border.all(
              color: glowColor.withOpacity(widget.isCharging ? 0.6 + _pulseAnimation.value * 0.3 : 0.25),
              width: 1.2,
            ),
          ),
          child: _buildContent(glowColor),
        );
      },
    );
  }

  Widget _buildContent(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _BatteryIcon(
            level: widget.batteryLevel,
            isCharging: widget.isCharging,
            color: accentColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isCharging ? 'Charging' : 'Battery',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${widget.batteryLevel}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          if (widget.isCharging)
            _LightningBolt(color: accentColor),
        ],
      ),
    );
  }
}

class _BatteryIcon extends StatelessWidget {
  final int level;
  final bool isCharging;
  final Color color;

  const _BatteryIcon({required this.level, required this.isCharging, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 14),
      painter: _BatteryPainter(level: level, isCharging: isCharging, color: color),
    );
  }
}

class _BatteryPainter extends CustomPainter {
  final int level;
  final bool isCharging;
  final Color color;

  _BatteryPainter({required this.level, required this.isCharging, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 1, size.width - 4, size.height - 2),
      const Radius.circular(2),
    );
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(bodyRect, borderPaint);

    // Terminal nub
    final nubPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - 3.5, size.height / 2 - 3, 3.5, 6),
        const Radius.circular(1),
      ),
      nubPaint,
    );

    // Fill
    final fillWidth = ((size.width - 6) * level / 100).clamp(0.0, size.width - 6);
    final fillColor = level <= 20 ? Colors.red : color;
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1.5, 2.5, fillWidth, size.height - 5),
        const Radius.circular(1),
      ),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_BatteryPainter old) =>
      old.level != level || old.isCharging != isCharging || old.color != color;
}

class _LightningBolt extends StatelessWidget {
  final Color color;
  const _LightningBolt({required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.bolt, color: color, size: 20);
  }
}
