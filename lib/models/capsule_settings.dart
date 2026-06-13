import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AnimationType { pulseGlow, fluidFill, orbitParticles }

class CapsuleSettings extends ChangeNotifier {
  double _positionX = 100.0;
  double _positionY = 200.0;
  double _width = 200.0;
  double _height = 56.0;
  double _cornerRadius = 28.0;
  double _opacity = 0.9;
  AnimationType _animationType = AnimationType.pulseGlow;

  double get positionX => _positionX;
  double get positionY => _positionY;
  double get width => _width;
  double get height => _height;
  double get cornerRadius => _cornerRadius;
  double get opacity => _opacity;
  AnimationType get animationType => _animationType;

  void updatePosition(double x, double y) {
    _positionX = x;
    _positionY = y;
    notifyListeners();
    _save();
  }

  void updateSize(double width, double height) {
    _width = width.clamp(120.0, 320.0);
    _height = height.clamp(40.0, 100.0);
    notifyListeners();
    _save();
  }

  void updateCornerRadius(double radius) {
    _cornerRadius = radius.clamp(0.0, 50.0);
    notifyListeners();
    _save();
  }

  void updateOpacity(double opacity) {
    _opacity = opacity.clamp(0.2, 1.0);
    notifyListeners();
    _save();
  }

  void updateAnimationType(AnimationType type) {
    _animationType = type;
    notifyListeners();
    _save();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _positionX = prefs.getDouble('posX') ?? 100.0;
    _positionY = prefs.getDouble('posY') ?? 200.0;
    _width = prefs.getDouble('width') ?? 200.0;
    _height = prefs.getDouble('height') ?? 56.0;
    _cornerRadius = prefs.getDouble('cornerRadius') ?? 28.0;
    _opacity = prefs.getDouble('opacity') ?? 0.9;
    _animationType = AnimationType.values[prefs.getInt('animationType') ?? 0];
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('posX', _positionX);
    await prefs.setDouble('posY', _positionY);
    await prefs.setDouble('width', _width);
    await prefs.setDouble('height', _height);
    await prefs.setDouble('cornerRadius', _cornerRadius);
    await prefs.setDouble('opacity', _opacity);
    await prefs.setInt('animationType', _animationType.index);
  }
}
