import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart' hide Barcode;

/// Generates/renders Code128 barcodes for order items and decodes them back via [BarcodeScannerView].
class BarcodeService {
  const BarcodeService();

  /// The Code128 value for an order item.
  String valueForOrderItem(String orderItemId) => orderItemId;

  /// A displayable / printable Code128 barcode widget for [value].
  Widget buildBarcode(
    String value, {
    double? width,
    double height = 96,
    bool drawText = true,
  }) {
    return BarcodeWidget(
      barcode: Barcode.code128(),
      data: value,
      width: width,
      height: height,
      drawText: drawText,
    );
  }

  Widget buildQr(String value, {double size = 200}) {
    return BarcodeWidget(
      barcode: Barcode.qrCode(),
      data: value,
      width: size,
      height: size,
      drawText: false,
    );
  }
}

final barcodeServiceProvider = Provider<BarcodeService>(
  (ref) => const BarcodeService(),
);

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({
    required this.onDetected,
    this.onRaw,
    this.formats = const [BarcodeFormat.code128],
    super.key,
  });

  final ValueChanged<String> onDetected;

  /// Fires for every raw detection (any format) — diagnostic aid.
  final ValueChanged<String>? onRaw;

  /// Formats to detect.
  final List<BarcodeFormat> formats;

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  late final MobileScannerController _controller = MobileScannerController(
    formats: widget.formats,
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw != null && raw.isNotEmpty) {
        widget.onRaw?.call(raw);
        if (!_handled) {
          _handled = true;
          widget.onDetected(raw);
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(controller: _controller, onDetect: _onDetect);
  }
}
