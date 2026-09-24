import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_generator/models/qr_history_item.dart';

void main() {
  group('QrHistoryItem', () {
    test('should create with default values', () {
      final item = QrHistoryItem(
        id: 'test-id',
        data: 'https://example.com',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(item.id, 'test-id');
      expect(item.data, 'https://example.com');
      expect(item.fgColor, 0xFF000000);
      expect(item.bgColor, 0xFFFFFFFF);
      expect(item.errorCorrectionLevel, 1);
      expect(item.size, 280.0);
      expect(item.margin, 4);
    });

    test('should create with custom values', () {
      final item = QrHistoryItem(
        id: 'test-id',
        data: 'Hello World',
        createdAt: DateTime(2024, 6, 15),
        fgColor: 0xFFFF0000,
        bgColor: 0xFF00FF00,
        errorCorrectionLevel: 3,
        size: 350.0,
        margin: 6,
      );

      expect(item.fgColor, 0xFFFF0000);
      expect(item.bgColor, 0xFF00FF00);
      expect(item.errorCorrectionLevel, 3);
      expect(item.size, 350.0);
      expect(item.margin, 6);
    });

    test('should serialize to JSON correctly', () {
      final item = QrHistoryItem(
        id: 'test-id',
        data: 'https://example.com',
        createdAt: DateTime(2024, 1, 1, 12, 30),
        fgColor: 0xFF000000,
        bgColor: 0xFFFFFFFF,
        errorCorrectionLevel: 2,
        size: 300.0,
        margin: 5,
      );

      final json = item.toJson();

      expect(json['id'], 'test-id');
      expect(json['data'], 'https://example.com');
      expect(json['createdAt'], '2024-01-01T12:30:00.000');
      expect(json['fgColor'], 0xFF000000);
      expect(json['bgColor'], 0xFFFFFFFF);
      expect(json['errorCorrectionLevel'], 2);
      expect(json['size'], 300.0);
      expect(json['margin'], 5);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'data': 'Hello World',
        'createdAt': '2024-06-15T10:00:00.000',
        'fgColor': 0xFFFF0000,
        'bgColor': 0xFF00FF00,
        'errorCorrectionLevel': 3,
        'size': 350.0,
        'margin': 6,
      };

      final item = QrHistoryItem.fromJson(json);

      expect(item.id, 'test-id');
      expect(item.data, 'Hello World');
      expect(item.createdAt, DateTime(2024, 6, 15, 10, 0));
      expect(item.fgColor, 0xFFFF0000);
      expect(item.bgColor, 0xFF00FF00);
      expect(item.errorCorrectionLevel, 3);
      expect(item.size, 350.0);
      expect(item.margin, 6);
    });

    test('should round-trip serialize/deserialize via JSON string', () {
      final original = QrHistoryItem(
        id: 'roundtrip-id',
        data: 'https://flutter.dev',
        createdAt: DateTime(2024, 3, 10, 8, 45),
        fgColor: 0xFF0000FF,
        bgColor: 0xFFFFFF00,
        errorCorrectionLevel: 0,
        size: 200.0,
        margin: 2,
      );

      final jsonString = original.toJsonString();
      final restored = QrHistoryItem.fromJsonString(jsonString);

      expect(restored.id, original.id);
      expect(restored.data, original.data);
      expect(restored.createdAt, original.createdAt);
      expect(restored.fgColor, original.fgColor);
      expect(restored.bgColor, original.bgColor);
      expect(restored.errorCorrectionLevel, original.errorCorrectionLevel);
      expect(restored.size, original.size);
      expect(restored.margin, original.margin);
    });

    test('should handle list serialization for SharedPreferences storage', () {
      final items = [
        QrHistoryItem(
          id: 'item-1',
          data: 'First',
          createdAt: DateTime(2024, 1, 1),
        ),
        QrHistoryItem(
          id: 'item-2',
          data: 'Second',
          createdAt: DateTime(2024, 1, 2),
        ),
      ];

      final jsonString = jsonEncode(items.map((e) => e.toJson()).toList());
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      final restored = decoded
          .map((e) => QrHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(restored.length, 2);
      expect(restored[0].id, 'item-1');
      expect(restored[1].id, 'item-2');
    });

    test('copyWith should create a new instance with overridden values', () {
      final original = QrHistoryItem(
        id: 'original-id',
        data: 'Original data',
        createdAt: DateTime(2024, 1, 1),
      );

      final modified = original.copyWith(
        data: 'Modified data',
        fgColor: 0xFFFF0000,
      );

      expect(modified.id, 'original-id'); // unchanged
      expect(modified.data, 'Modified data'); // changed
      expect(modified.fgColor, 0xFFFF0000); // changed
      expect(modified.bgColor, 0xFFFFFFFF); // unchanged default
    });
  });
}
