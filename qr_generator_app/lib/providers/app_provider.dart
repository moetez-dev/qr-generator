import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  // Theme
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  // Input
  String _inputText = '';
  String get inputText => _inputText;

  // QR generated state
  bool _qrGenerated = false;
  bool get qrGenerated => _qrGenerated;

  String _qrData = '';
  String get qrData => _qrData;

  // Customization
  double _qrSize = 280.0;
  double get qrSize => _qrSize;

  Color _foregroundColor = Colors.black;
  Color get foregroundColor => _foregroundColor;

  Color _backgroundColor = Colors.white;
  Color get backgroundColor => _backgroundColor;

  int _errorCorrectionLevel = 1; // 0=L, 1=M, 2=Q, 3=H
  int get errorCorrectionLevel => _errorCorrectionLevel;

  int _margin = 4;
  int get margin => _margin;

  static const String _themeKey = 'theme_mode';

  AppProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  void setInputText(String text) {
    _inputText = text;
  }

  void generateQr(String data) {
    _qrData = data;
    _qrGenerated = true;
    notifyListeners();
  }

  void clearQr() {
    _inputText = '';
    _qrData = '';
    _qrGenerated = false;
    _qrSize = 280.0;
    _foregroundColor = Colors.black;
    _backgroundColor = Colors.white;
    _errorCorrectionLevel = 1;
    _margin = 4;
    notifyListeners();
  }

  void setQrSize(double size) {
    _qrSize = size;
    notifyListeners();
  }

  void setForegroundColor(Color color) {
    _foregroundColor = color;
    notifyListeners();
  }

  void setBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }

  void setErrorCorrectionLevel(int level) {
    _errorCorrectionLevel = level;
    notifyListeners();
  }

  void setMargin(int newMargin) {
    _margin = newMargin;
    notifyListeners();
  }

  String get errorCorrectionLabel {
    switch (_errorCorrectionLevel) {
      case 0:
        return 'L (Low ~7%)';
      case 1:
        return 'M (Medium ~15%)';
      case 2:
        return 'Q (Quartile ~25%)';
      case 3:
        return 'H (High ~30%)';
      default:
        return 'M (Medium ~15%)';
    }
  }

  /// Load a history item into the generator
  void loadFromHistory({
    required String data,
    required int fgColor,
    required int bgColor,
    required int errorCorrectionLevel,
    required double size,
    required int margin,
  }) {
    _inputText = data;
    _qrData = data;
    _qrGenerated = true;
    _foregroundColor = Color(fgColor);
    _backgroundColor = Color(bgColor);
    _errorCorrectionLevel = errorCorrectionLevel;
    _qrSize = size;
    _margin = margin;
    notifyListeners();
  }
}
