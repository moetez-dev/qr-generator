import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPreviewWidget extends StatelessWidget {
  final GlobalKey repaintKey;
  final String data;
  final double size;
  final Color foregroundColor;
  final Color backgroundColor;
  final int errorCorrectionLevel;
  final int margin;

  const QrPreviewWidget({
    super.key,
    required this.repaintKey,
    required this.data,
    this.size = 280.0,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.errorCorrectionLevel = 1,
    this.margin = 4,
  });

  int get _qrErrorCorrectLevel {
    switch (errorCorrectionLevel) {
      case 0:
        return QrErrorCorrectLevel.L;
      case 1:
        return QrErrorCorrectLevel.M;
      case 2:
        return QrErrorCorrectLevel.Q;
      case 3:
        return QrErrorCorrectLevel.H;
      default:
        return QrErrorCorrectLevel.M;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(margin.toDouble() * 4),
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          size: size,
          errorCorrectionLevel: _qrErrorCorrectLevel,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: foregroundColor,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: foregroundColor,
          ),
          backgroundColor: backgroundColor,
          gapless: true,
          errorStateBuilder: (context, error) {
            return SizedBox(
              width: size,
              height: size,
              child: Center(
                child: Text(
                  'Error generating QR code.\nTry shorter text.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
