import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/capsule_settings.dart';
import '../services/battery_service.dart';
import '../widgets/capsule_widget.dart';
import '../animations/pulse_glow_animation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildPreviewArea(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _AnimationTab(),
                  _SizeTab(),
                  _AppearanceTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<BatteryService>(
      builder: (context, battery, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Capsula',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  Text(
                    'Live Battery Overlay',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _StatusBadge(battery: battery),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              'PREVIEW',
              style: TextStyle(
                color: Colors.white.withOpacity(0.08),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
          ),
          const Center(child: CapsuleWidget(draggable: false)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kCyan.withOpacity(0.3)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: kCyan,
        unselectedLabelColor: Colors.white.withOpacity(0.4),
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Animation'),
          Tab(text: 'Size'),
          Tab(text: 'Appearance'),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BatteryService battery;
  const _StatusBadge({required this.battery});

  @override
  Widget build(BuildContext context) {
    final color = battery.isCharging ? kGreen : kCyan;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            battery.isCharging ? Icons.bolt : Icons.battery_std_rounded,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 5),
          Text(
            '${battery.batteryLevel}%',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// --- ANIMATION TAB ---
class _AnimationTab extends StatelessWidget {
  const _AnimationTab();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<CapsuleSettings>();

    final animations = [
      (AnimationType.pulseGlow, 'Pulse Glow', 'Breathing glow with vibrant colors', Icons.flare),
      (AnimationType.fluidFill, 'Fluid Fill', 'Animated wave matching battery level', Icons.water),
      (AnimationType.orbitParticles, 'Orbit Particles', 'Colorful particles orbiting the capsule', Icons.blur_circular),
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Choose Animation',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        ...animations.map((a) {
          final isSelected = settings.animationType == a.$1;
          return GestureDetector(
            onTap: () => settings.updateAnimationType(a.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? kCyan.withOpacity(0.08) : const Color(0xFF131313),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? kCyan.withOpacity(0.5) : Colors.white.withOpacity(0.07),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? kCyan.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(a.$3, color: isSelected ? kCyan : Colors.white.withOpacity(0.4), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.$2,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.$3.toString(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.$4 == Icons.flare ? a.$2 : a.$3,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: kCyan,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.black, size: 14),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// --- SIZE TAB ---
class _SizeTab extends StatelessWidget {
  const _SizeTab();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<CapsuleSettings>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SliderTile(
          label: 'Width',
          value: settings.width,
          min: 120,
          max: 320,
          unit: 'dp',
          accentColor: kCyan,
          onChanged: (v) => settings.updateSize(v, settings.height),
        ),
        _SliderTile(
          label: 'Height',
          value: settings.height,
          min: 40,
          max: 100,
          unit: 'dp',
          accentColor: kGreen,
          onChanged: (v) => settings.updateSize(settings.width, v),
        ),
        _SliderTile(
          label: 'Corner Radius',
          value: settings.cornerRadius,
          min: 0,
          max: 50,
          unit: 'dp',
          accentColor: const Color(0xFF9B59FF),
          onChanged: settings.updateCornerRadius,
        ),
      ],
    );
  }
}

// --- APPEARANCE TAB ---
class _AppearanceTab extends StatelessWidget {
  const _AppearanceTab();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<CapsuleSettings>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SliderTile(
          label: 'Opacity',
          value: settings.opacity,
          min: 0.2,
          max: 1.0,
          unit: '',
          accentColor: const Color(0xFFFF6B9D),
          onChanged: settings.updateOpacity,
          displayValue: '${(settings.opacity * 100).round()}%',
        ),
        const SizedBox(height: 16),
        _InfoCard(
          icon: Icons.info_outline,
          title: 'Positioning',
          body: 'Drag the capsule in the preview above, or use it on the live overlay screen. '
              'Drag it anywhere on your screen to reposition.',
        ),
        const SizedBox(height: 12),
        _InfoCard(
          icon: Icons.layers_outlined,
          title: 'Overlay Permission',
          body: 'To show the capsule over other apps and on the lock screen, '
              'grant the "Display over other apps" permission in Android Settings.',
        ),
      ],
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final Color accentColor;
  final ValueChanged<double> onChanged;
  final String? displayValue;

  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.accentColor,
    required this.onChanged,
    this.displayValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              Text(
                displayValue ?? '${value.round()}$unit',
                style: TextStyle(color: accentColor, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: accentColor,
              inactiveTrackColor: accentColor.withOpacity(0.15),
              thumbColor: accentColor,
              overlayColor: accentColor.withOpacity(0.15),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(value: value, min: min, max: max, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoCard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.3), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
