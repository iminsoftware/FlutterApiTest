import 'package:flutter/services.dart';

/// Camera Scan API for iMin devices
///
/// Provides camera-based barcode/QR code scanning functionality using ZXing
class CameraScanApi {
  static const MethodChannel _channel = MethodChannel('imin_hardware_plugin');

  /// Scan a barcode or QR code using the camera
  ///
  /// Parameters:
  /// - [formats]: List of barcode formats to scan (optional)
  ///   Supported formats: QR_CODE, EAN_13, EAN_8, UPC_A, UPC_E, CODE_128, CODE_39, CODE_93,
  ///   CODABAR, ITF, RSS_14, RSS_EXPANDED, DATA_MATRIX, PDF_417, AZTEC
  /// - [prompt]: Message to display to the user (default: "Scan a barcode")
  /// - [useFlash]: Whether to turn on the flash (default: false)
  /// - [beepEnabled]: Whether to play a beep sound on successful scan (default: true)
  /// - [timeout]: Timeout in milliseconds (0 = no timeout)
  ///
  /// Returns a Map with:
  /// - code: The scanned barcode/QR code content
  /// - format: The barcode format (e.g., "QR_CODE", "EAN_13")
  /// - rawBytes: Raw bytes (currently null)
  ///
  /// Throws:
  /// - PlatformException if scan fails or is canceled
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

  /// Scan only barcodes (EAN, UPC, CODE_128)
  static Future<String> scanBarcode({String? prompt}) async {
    final result = await scan(
      formats: ['EAN_13', 'EAN_8', 'UPC_A', 'UPC_E', 'CODE_128'],
      prompt: prompt ?? 'Scan a Barcode',
    );
    return result['code'] as String;
  }

  /// Scan all supported formats
  static Future<Map<String, dynamic>> scanAll({String? prompt}) async {
    return await scan(
      formats: [
        'QR_CODE',
        'EAN_13',
        'EAN_8',
        'UPC_A',
        'UPC_E',
        'CODE_128',
        'CODE_39',
        'CODE_93',
        'CODABAR',
        'ITF',
        'RSS_14',
        'RSS_EXPANDED',
        'DATA_MATRIX',
        'PDF_417',
        'AZTEC',
      ],
      prompt: prompt,
    );
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
  static const List<String> defaultFormats = [
    qrCode,
    upcA,
    ean13,
    code128,
  ];

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
