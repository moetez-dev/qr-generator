import 'package:flutter/material.dart';
import '../models/qr_history_item.dart';
import '../services/history_service.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryService _historyService = HistoryService();
  List<QrHistoryItem> _items = [];
  bool _isLoaded = false;

  List<QrHistoryItem> get items => _items;
  bool get isLoaded => _isLoaded;
  bool get isEmpty => _items.isEmpty;

  Future<void> loadHistory() async {
    _items = await _historyService.getAll();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addItem(QrHistoryItem item) async {
    await _historyService.add(item);
    _items.insert(0, item);
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    await _historyService.delete(id);
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _historyService.clearAll();
    _items.clear();
    notifyListeners();
  }
}
