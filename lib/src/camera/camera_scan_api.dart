import 'package:flutter/services.dart';

/// 解码引擎
class DecodeEngine {
  static const int zxing = 0;
  static const int mlkit = 1;
}

/// 多码/多角度扫码配置
class MultiScanOptions {
  /// 要识别的条码格式列表，不传则使用全部格式
  final List<String>? formats;

  /// 是否开启闪光灯，默认 false
  final bool useFlash;

  /// 是否播放提示音，默认 true
  final bool beepEnabled;

  /// 超时时间(毫秒)，0 = 不超时
  final int timeout;

  /// 是否支持多条码同时识别，默认 true
  final bool supportMultiBarcode;

  /// 是否支持多角度识别，默认 true
  final bool supportMultiAngle;

  /// 解码引擎：0=ZXing, 1=MLKit，默认 1
  final int decodeEngine;

  /// 是否全区域扫码，默认 true
  final bool fullAreaScan;

  /// 识别区域比例 0.5~1.0，默认 0.8
  final double areaRectRatio;

  const MultiScanOptions({
    this.formats,
    this.useFlash = false,
    this.beepEnabled = true,
    this.timeout = 0,
    this.supportMultiBarcode = true,
    this.supportMultiAngle = true,
    this.decodeEngine = DecodeEngine.mlkit,
    this.fullAreaScan = true,
    this.areaRectRatio = 0.8,
  });

  Map<String, dynamic> toMap() {
    return {
      if (formats != null && formats!.isNotEmpty) 'formats': formats,
      'useFlash': useFlash,
      'beepEnabled': beepEnabled,
      'timeout': timeout,
      'supportMultiBarcode': supportMultiBarcode,
      'supportMultiAngle': supportMultiAngle,
      'decodeEngine': decodeEngine,
      'fullAreaScan': fullAreaScan,
      'areaRectRatio': areaRectRatio,
    };
  }
}

/// Camera Scan API for iMin devices
///
/// Provides camera-based barcode/QR code scanning functionality
/// Supports ZXing (default) and ML Kit (multi-angle/multi-barcode) engines
class CameraScanApi {
  static const MethodChannel _channel = MethodChannel('imin_hardware_plugin');

  /// Scan a barcode or QR code using the camera (single scan)
  ///
  /// Returns a Map with:
  /// - code: The scanned barcode/QR code content
  /// - format: The barcode format (e.g., "QR_CODE", "EAN_13")
  /// - rawBytes: Raw bytes (currently null)
  static Future<Map<String, dynamic>> scan({
    List<String>? formats,
    String? prompt,
    bool useFlash = false,
    bool beepEnabled = true,
    int timeout = 0,
  }) async {
    try {
      final result = await _channel.invokeMethod<Map>('cameraScan.scan', {
        if (formats != null && formats.isNotEmpty) 'formats': formats,
        if (prompt != null) 'prompt': prompt,
        'useFlash': useFlash,
        'beepEnabled': beepEnabled,
        'timeout': timeout,
      });

      if (result == null) {
        throw Exception('No scan result returned');
      }

      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') {
        throw Exception('Scan was canceled');
      }
      throw Exception('Failed to scan: ${e.message}');
    }
  }

  /// Scan with default settings (QR_CODE, EAN_13, UPC_A, CODE_128)
  static Future<String> scanQuick() async {
    final result = await scan();
    return result['code'] as String;
  }

  /// Scan only QR codes
  static Future<String> scanQRCode({String? prompt}) async {
    final result = await scan(
      formats: ['QR_CODE'],
      prompt: prompt ?? 'Scan a QR Code',
    );
    return result['code'] as String;
  }

  /// Scan only barcodes (all 1D formats)
  static Future<String> scanBarcode({String? prompt}) async {
    final result = await scan(
      formats: BarcodeFormat.oneDimensionalFormats,
      prompt: prompt ?? 'Scan a Barcode',
    );
    return result['code'] as String;
  }

  /// Scan all supported formats
  static Future<Map<String, dynamic>> scanAll({String? prompt}) async {
    return await scan(
      formats: BarcodeFormat.allFormats,
      prompt: prompt,
    );
  }

  /// Multi-barcode / multi-angle scan (ML Kit engine)
  ///
  /// Returns a list of scan results, each containing:
  /// - code: The scanned content
  /// - format: The barcode format
  ///
  /// Supports:
  /// - Multiple barcodes in one frame
  /// - Any-angle barcode recognition (ML Kit)
  /// - Auto fallback to ZXing if ML Kit is unavailable
  static Future<List<Map<String, dynamic>>> scanMulti([
    MultiScanOptions options = const MultiScanOptions(),
  ]) async {
    try {
      final result = await _channel.invokeMethod<List>(
        'cameraScan.scanMulti',
        options.toMap(),
      );

      if (result == null) {
        throw Exception('No scan result returned');
      }

      return result
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') {
        throw Exception('Scan was canceled');
      }
      throw Exception('Failed to scan: ${e.message}');
    }
  }

  /// Check if ML Kit barcode scanning is available at runtime
  ///
  /// Returns true if ML Kit dependency is present, false otherwise.
  /// When ML Kit is unavailable, scanMulti() will auto-fallback to ZXing.
  static Future<bool> isMLKitAvailable() async {
    final result =
        await _channel.invokeMethod<bool>('cameraScan.isMLKitAvailable');
    return result ?? false;
  }
}

/// Supported barcode formats
class BarcodeFormat {
  static const String qrCode = 'QR_CODE';
  static const String ean13 = 'EAN_13';
  static const String ean8 = 'EAN_8';
  static const String upcA = 'UPC_A';
  static const String upcE = 'UPC_E';
  static const String code128 = 'CODE_128';
  static const String code39 = 'CODE_39';
  static const String code93 = 'CODE_93';
  static const String codabar = 'CODABAR';
  static const String itf = 'ITF';
  static const String rss14 = 'RSS_14';
  static const String rssExpanded = 'RSS_EXPANDED';
  static const String dataMatrix = 'DATA_MATRIX';
  static const String pdf417 = 'PDF_417';
  static const String aztec = 'AZTEC';
  static const String maxicode = 'MAXICODE';
  static const String upcEanExtension = 'UPC_EAN_EXTENSION';

  /// Default formats (same as scanlibrary DEFAULT_HINTS)
  static const List<String> defaultFormats = [qrCode, upcA, ean13, code128];

  /// All one-dimensional formats
  static const List<String> oneDimensionalFormats = [
    codabar,
    code39,
    code93,
    code128,
    ean8,
    ean13,
    itf,
    rss14,
    rssExpanded,
    upcA,
    upcE,
    upcEanExtension,
  ];

  /// All two-dimensional formats
  static const List<String> twoDimensionalFormats = [
    aztec,
    dataMatrix,
    maxicode,
    pdf417,
    qrCode,
  ];

  /// All supported formats
  static const List<String> allFormats = [
    ...oneDimensionalFormats,
    ...twoDimensionalFormats,
  ];
}
