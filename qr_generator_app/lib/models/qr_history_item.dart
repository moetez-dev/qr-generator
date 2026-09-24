import 'dart:convert';

class QrHistoryItem {
  final String id;
  final String data;
  final DateTime createdAt;
  final int fgColor;
  final int bgColor;
  final int errorCorrectionLevel; // 0=L, 1=M, 2=Q, 3=H
  final double size;
  final int margin;

  QrHistoryItem({
    required this.id,
    required this.data,
    required this.createdAt,
    this.fgColor = 0xFF000000,
    this.bgColor = 0xFFFFFFFF,
    this.errorCorrectionLevel = 1,
    this.size = 280.0,
    this.margin = 4,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'fgColor': fgColor,
        'bgColor': bgColor,
        'errorCorrectionLevel': errorCorrectionLevel,
        'size': size,
        'margin': margin,
      };

  factory QrHistoryItem.fromJson(Map<String, dynamic> json) => QrHistoryItem(
        id: json['id'] as String,
        data: json['data'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        fgColor: json['fgColor'] as int,
        bgColor: json['bgColor'] as int,
        errorCorrectionLevel: json['errorCorrectionLevel'] as int,
        size: (json['size'] as num).toDouble(),
        margin: json['margin'] as int,
      );

  String toJsonString() => jsonEncode(toJson());

  factory QrHistoryItem.fromJsonString(String jsonString) =>
      QrHistoryItem.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  QrHistoryItem copyWith({
    String? id,
    String? data,
    DateTime? createdAt,
    int? fgColor,
    int? bgColor,
    int? errorCorrectionLevel,
    double? size,
    int? margin,
  }) {
    return QrHistoryItem(
      id: id ?? this.id,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      fgColor: fgColor ?? this.fgColor,
      bgColor: bgColor ?? this.bgColor,
      errorCorrectionLevel: errorCorrectionLevel ?? this.errorCorrectionLevel,
      size: size ?? this.size,
      margin: margin ?? this.margin,
    );
  }
}
