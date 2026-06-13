import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/capsule_settings.dart';
import '../services/battery_service.dart';
import '../widgets/capsule_widget.dart';

/// This screen is displayed as the floating overlay window
/// via flutter_overlay_window's entry point.
class OverlayScreen extends StatelessWidget {
  const OverlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BatteryService()),
        ChangeNotifierProvider(create: (_) => CapsuleSettings()..load()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const _OverlayView(),
      ),
    );
  }
}

class _OverlayView extends StatelessWidget {
  const _OverlayView();

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
