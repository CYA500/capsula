import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:provider/provider.dart';
import 'models/capsule_settings.dart';
import 'services/battery_service.dart';
import 'screens/home_screen.dart';
import 'widgets/capsule_widget.dart';

/// Entry point for the overlay window (called by flutter_overlay_window)
@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BatteryService()),
        ChangeNotifierProvider(create: (_) => CapsuleSettings()..load()),
      ],
      child: const _OverlayApp(),
    ),
  );
}

class _OverlayApp extends StatelessWidget {
  const _OverlayApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: const _OverlayRoot(),
    );
  }
}

class _OverlayRoot extends StatelessWidget {
  const _OverlayRoot();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [CapsuleWidget(draggable: true)],
      ),
    );
  }
}

// --- MAIN APP ENTRY POINT ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final settings = CapsuleSettings();
  await settings.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) => BatteryService()),
      ],
      child: const CapsulaApp(),
    ),
  );
}

class CapsulaApp extends StatelessWidget {
  const CapsulaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capsula',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3FCAFC),
          secondary: Color(0xFF5CFF7A),
          surface: Color(0xFF0A0A0A),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF080808),
        fontFamily: 'Roboto',
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  bool _overlayActive = false;

  @override
  void initState() {
    super.initState();
    _checkOverlayPermission();
  }

  Future<void> _checkOverlayPermission() async {
    final hasPermission = await FlutterOverlayWindow.isPermissionGranted();
    if (mounted) setState(() => _overlayActive = hasPermission);
  }

  Future<void> _toggleOverlay() async {
    final hasPermission = await FlutterOverlayWindow.isPermissionGranted();
    if (!hasPermission) {
      await FlutterOverlayWindow.requestPermission();
      return;
    }

    if (_overlayActive) {
      await FlutterOverlayWindow.closeOverlay();
    } else {
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: 'Capsula',
        overlayContent: 'Battery overlay active',
        flag: OverlayFlag.defaultFlag,
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.auto,
        height: WindowSize.matchParent,
        width: WindowSize.matchParent,
      );
    }
    if (mounted) setState(() => _overlayActive = !_overlayActive);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Column(
        children: [
          const Expanded(child: HomeScreen()),
          _OverlayToggleBar(isActive: _overlayActive, onToggle: _toggleOverlay),
        ],
      ),
    );
  }
}

class _OverlayToggleBar extends StatelessWidget {
  final bool isActive;
  final VoidCallback onToggle;

  const _OverlayToggleBar({required this.isActive, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.07))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onToggle,
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive
                ? const Color(0xFF5CFF7A).withOpacity(0.15)
                : const Color(0xFF3FCAFC).withOpacity(0.15),
            foregroundColor:
                isActive ? const Color(0xFF5CFF7A) : const Color(0xFF3FCAFC),
            elevation: 0,
            side: BorderSide(
              color: isActive
                  ? const Color(0xFF5CFF7A).withOpacity(0.4)
                  : const Color(0xFF3FCAFC).withOpacity(0.4),
              width: 1.5,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive
                    ? Icons.stop_circle_outlined
                    : Icons.play_circle_outline,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isActive ? 'Stop Overlay' : 'Launch Overlay',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
