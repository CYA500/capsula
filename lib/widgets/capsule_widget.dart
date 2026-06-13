import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/capsule_settings.dart';
import '../services/battery_service.dart';
import '../animations/pulse_glow_animation.dart';
import '../animations/fluid_fill_animation.dart';
import '../animations/orbit_particles_animation.dart';

class CapsuleWidget extends StatelessWidget {
  final bool draggable;

  const CapsuleWidget({super.key, this.draggable = true});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CapsuleSettings, BatteryService>(
      builder: (context, settings, battery, _) {
        final capsule = _buildCapsule(settings, battery);

        if (!draggable) return capsule;

        return Positioned(
          left: settings.positionX,
          top: settings.positionY,
          child: GestureDetector(
            onPanUpdate: (details) {
              final screenSize = MediaQuery.of(context).size;
              final newX = (settings.positionX + details.delta.dx)
                  .clamp(0.0, screenSize.width - settings.width);
              final newY = (settings.positionY + details.delta.dy)
                  .clamp(0.0, screenSize.height - settings.height);
              settings.updatePosition(newX, newY);
            },
            child: Opacity(
              opacity: settings.opacity,
              child: capsule,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCapsule(CapsuleSettings settings, BatteryService battery) {
    switch (settings.animationType) {
      case AnimationType.pulseGlow:
        return PulseGlowAnimation(
          width: settings.width,
          height: settings.height,
          cornerRadius: settings.cornerRadius,
          batteryLevel: battery.batteryLevel,
          isCharging: battery.isCharging,
        );
      case AnimationType.fluidFill:
        return FluidFillAnimation(
          width: settings.width,
          height: settings.height,
          cornerRadius: settings.cornerRadius,
          batteryLevel: battery.batteryLevel,
          isCharging: battery.isCharging,
        );
      case AnimationType.orbitParticles:
        return OrbitParticlesAnimation(
          width: settings.width,
          height: settings.height,
          cornerRadius: settings.cornerRadius,
          batteryLevel: battery.batteryLevel,
          isCharging: battery.isCharging,
        );
    }
  }
}
