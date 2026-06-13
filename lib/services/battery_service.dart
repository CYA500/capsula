import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';

class BatteryService extends ChangeNotifier {
  final Battery _battery = Battery();
  int _batteryLevel = 0;
  bool _isCharging = false;
  StreamSubscription<BatteryState>? _stateSubscription;

  int get batteryLevel => _batteryLevel;
  bool get isCharging => _isCharging;

  BatteryService() {
    _init();
  }

  Future<void> _init() async {
    _batteryLevel = await _battery.batteryLevel;
    final state = await _battery.batteryState;
    _isCharging = state == BatteryState.charging || state == BatteryState.full;
    notifyListeners();

    _stateSubscription = _battery.onBatteryStateChanged.listen((state) async {
      _isCharging = state == BatteryState.charging || state == BatteryState.full;
      _batteryLevel = await _battery.batteryLevel;
      notifyListeners();
    });

    // Poll battery level every 30 seconds to keep percentage fresh
    Timer.periodic(const Duration(seconds: 30), (_) async {
      _batteryLevel = await _battery.batteryLevel;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }
}
