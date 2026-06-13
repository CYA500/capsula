import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'pulse_glow_animation.dart';

class OrbitParticlesAnimation extends StatefulWidget {
  final double width;
  final double height;
  final double cornerRadius;
  final int batteryLevel;
  final bool isCharging;

  const OrbitParticlesAnimation({
    super.key,
    required this.width,
    required this.height,
    required this.cornerRadius,
    required this.batteryLevel,
    required this.isCharging,
  });

  @override
  State<OrbitParticlesAnimation> createState() => _OrbitParticlesAnimationState();
}

class _OrbitParticlesAnimationState extends State<OrbitParticlesAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _particles = _generateParticles();
  }

  List<_Particle> _generateParticles() {
    final rng = math.Random(42);
    final colors = [
      kCyan,
      kGreen,
      const Color(0xFFFFFFFF),
      const Color(0xFF9B59FF),
      const Color(0xFFFF6B9D),
    ];
    return List.generate(12, (i) {
      return _Particle(
        orbitRadius: 28.0 + rng.nextDouble() * 20.0,
        speed: 0.4 + rng.nextDouble() * 0.8,
        startAngle: rng.nextDouble() * 2 * math.pi,
        size: 2.5 + rng.nextDouble() * 3.0,
        color: colors[rng.nextInt(colors.length)],
        verticalOffset: (rng.nextDouble() - 0.5) * 0.6,
        trailLength: 3 + rng.nextInt(5),
      );
    });
  }

  @override
  void didUpdateWidget(OrbitParticlesAnimation old) {
    super.didUpdateWidget(old);
    if (old.isCharging != widget.isCharging) {
      if (widget.isCharging) {
        _controller.repeat();
      } else {
        _controller.animateTo(1.0, duration: const Duration(milliseconds: 800))
            .then((_) => _controller.stop());
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(widget.cornerRadius),
            border: Border.all(
              color: kCyan.withOpacity(0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: kGreen.withOpacity(0.15),
                blurRadius: 16,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: kCyan.withOpacity(0.1),
                blurRadius: 28,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.cornerRadius - 1),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Particle layer (outside clipping via overflow)
                Positioned.fill(
                  child: OverflowBox(
                    maxWidth: widget.width + 60,
                    maxHeight: widget.height + 60,
                    child: CustomPaint(
                      painter: _ParticlePainter(
                        particles: _particles,
                        progress: _controller.value,
                        isCharging: widget.isCharging,
                        capsuleWidth: widget.width,
                        capsuleHeight: widget.height,
                      ),
                      size: Size(widget.width + 60, widget.height + 60),
                    ),
                  ),
                ),
                // Content
                Positioned.fill(child: _buildContent()),
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
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isCharging ? 'Charging' : 'Battery',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${widget.batteryLevel}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    '%',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          if (widget.isCharging)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kCyan.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kCyan.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, color: kCyan, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    'Live',
                    style: TextStyle(
                      color: kCyan,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Particle {
  final double orbitRadius;
  final double speed;
  final double startAngle;
  final double size;
  final Color color;
  final double verticalOffset;
  final int trailLength;

  const _Particle({
    required this.orbitRadius,
    required this.speed,
    required this.startAngle,
    required this.size,
    required this.color,
    required this.verticalOffset,
    required this.trailLength,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final bool isCharging;
  final double capsuleWidth;
  final double capsuleHeight;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.isCharging,
    required this.capsuleWidth,
    required this.capsuleHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isCharging) return;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final halfW = capsuleWidth / 2;
    final halfH = capsuleHeight / 2;

    for (final p in particles) {
      final angle = p.startAngle + progress * p.speed * 2 * math.pi;

      // Elliptical orbit following the capsule shape
      final orbitX = halfW + p.orbitRadius;
      final orbitY = halfH + p.orbitRadius * 0.4;
      final px = cx + orbitX * math.cos(angle);
      final py = cy + orbitY * math.sin(angle) + p.verticalOffset * halfH;

      // Trail
      for (int t = 1; t <= p.trailLength; t++) {
        final trailAngle = angle - (t * 0.06);
        final tpx = cx + orbitX * math.cos(trailAngle);
        final tpy = cy + orbitY * math.sin(trailAngle) + p.verticalOffset * halfH;
        final trailOpacity = (1 - t / p.trailLength) * 0.35;
        canvas.drawCircle(
          Offset(tpx, tpy),
          p.size * (1 - t / (p.trailLength + 1)) * 0.7,
          Paint()..color = p.color.withOpacity(trailOpacity),
        );
      }

      // Main particle dot with glow
      final glowPaint = Paint()
        ..color = p.color.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(px, py), p.size * 1.8, glowPaint);

      final dotPaint = Paint()..color = p.color.withOpacity(0.92);
      canvas.drawCircle(Offset(px, py), p.size, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}
