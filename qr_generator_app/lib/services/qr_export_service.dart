import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class QrExportService {
  /// Capture the QR widget to PNG bytes using a RepaintBoundary key
  static Future<Uint8List?> captureQrImage(GlobalKey repaintKey) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing QR image: $e');
      return null;
    }
  }

  /// Save QR image to device gallery
  static Future<bool> saveToGallery(Uint8List imageBytes) async {
    try {
      // Request permission
      if (Platform.isAndroid) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          // Try storage permission for older Android versions
          final storageStatus = await Permission.storage.request();
          if (!storageStatus.isGranted) {
            return false;
          }
        }
      } else if (Platform.isIOS) {
        final status = await Permission.photos.request();
        if (!status.isGranted) return false;
      }

      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        quality: 100,
        name: 'QR_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result is Map) {
        return result['isSuccess'] == true;
      }
      return result != null;
    } catch (e) {
      debugPrint('Error saving to gallery: $e');
      return false;
    }
  }

  /// Share QR image via native share sheet
  static Future<void> shareQrImage(Uint8List imageBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/QR_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(imageBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'QR Code',
        ),
      );
    } catch (e) {
      debugPrint('Error sharing QR image: $e');
    }
  }
}
